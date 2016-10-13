defmodule ElsolSpec.QuerySpec do

  use ESpec, async: true

  example_group do
    describe "build" do
      subject do: Elsol.Query.build(param())
      
      context "with a Query struct" do
        let :query_object do
         %Elsol.Query{
           q: "*:*",
           sort: "name asc",
           start: 10,
           rows: 20,
           fl: "id, name",
           fq: "name:bar^10",
           echoParams: true
         }
        end
        let :param do
          query_object()
        end
        it "should correctly prepare the query keys" do
          # the query params are ordered this way because Map.to_list returns with keys alphabetically sorted
          should eq "/select?echoParams=true&fl=id, name&fq=name:bar^10&q=*:*&rows=20&sort=name asc&start=10&wt=json"
        end
        
        context "with a collection defined" do
          let :collection do
            %Elsol.Collection{name: "foo"}
          end
          let :param do
            %Elsol.Query{
              query_object() | collection: collection()
             }
          end
          it "should include collection name before the query name" do
            should eq "/foo/select?echoParams=true&fl=id, name&fq=name:bar^10&q=*:*&rows=20&sort=name asc&start=10&wt=json"
          end
        end
      end
      context "with a struct" do
        let :param do
          %{
            name: "/select",
            q: "*:*",
            sort: "name asc",
            start: 10,
            rows: 20,
            fl: "id, name",
            fq: "name:bar^10",
            echoParams: true,
            collection: "/foo"
          }
        end
        # note we need the name key to correctly process!
        # note as well wt=json is not passed
        # tbh I would not recommend passing a bare struct
        it "should be processed identically to a query object" do
          should eq "/foo/select?echoParams=true&fl=id, name&fq=name:bar^10&q=*:*&rows=20&sort=name asc&start=10"
        end
      end
      context "with a key-value tuple" do
        context "if the tuple has a string value" do
          let :param, do: %{sort: "name asc"}
          it "should turn the tuple into a query param grouping" do
            should eq "sort=name asc"
          end
        end
        context "if the tuple has a boolean value" do
          let :param, do: %{facet: true}
          it "should cast the boolean value to a string" do
            should eq "facet=true"
          end
        end
        context "if the value has a list" do
          context "if the list is not empty" do
            let :param, do: %{fl: ["name", "id"]}
            it "should compose key-value pairs for each field" do
              should eq "fl=name&fl=id"
            end
          end
          context "if the list is empty" do
            let :param, do: %{fl: []}
            it "should be an empty string" do
              should eq ""
            end
          end
        end
        
        context "if the value is nil" do
          let :param, do: %{fl: nil}
          it "should be an empty string" do
            should eq ""
          end
        end
      end
      context "with a list" do
        context "if the list is a size of two or more" do
          
        end
        context "if the list is a size of 1" do
          
        end
        context "if the list is empty" do
          
        end
      end
    end
  end

end
