defmodule ElsolSpec do

  use ESpec
  
  defmodule SharedQueryExample do
  
    use ESpec, shared: true

    let_overridable [:method, :request_method]

    subject do: apply(Elsol, method(), [arg()])

    before do
      allow Elsol |> to(accept request_method(), fn(_,_,_) -> "retval" end)
    end

    let :expected_url, do: "http://localhost:8983/solr/foo/select?q=*:*&wt=json"

    context "with a string" do
      let :arg, do: expected_url()

      it "should request the URL through HTTPoison" do
        should eql "retval"  # indicates we returned the return value of :get
        expect Elsol |> to(accepted request_method(), [arg(), [], [recv_timeout: 30000]])
      end
    end

    context "with a query struct" do
      let :arg, do: %Elsol.Query{url: "http://localhost:8983/solr",
                                 collection: %Elsol.Collection{name: "foo"},
                                 q: "*:*"}
      it "should request from the correct URL" do
        should eql "retval"
        expect Elsol |> to(accepted request_method(), [expected_url(), [], [recv_timeout: 30000]])
      end
    end
  end
  
  defmodule SharedUpdateExample do

    use ESpec, shared: true
    let_overridable [:method, :struct, :expected_get, :expected_post]

    before do
      allow Elsol |> to(accept expected_post(), fn(_,_,_) -> "posted" end)
      allow Elsol |> to(accept expected_get(), fn(_,_,_) -> "got" end)
    end

    let :expected_url, do: "http://localhost:8983/solr/foo/update?commit=true"
    subject do: apply(Elsol, method(), args())

    context "with docs" do
      let :args, do: [struct(), docs]
      context "doc list" do
        context "head of list is map" do
          let :docs, do: [%{id: "1", name: "foo"}, %{id: 2, name: "bar"}]
          it "should post" do
            should eql "posted"
            {_, json_docs} = Poison.encode(docs)
            expect Elsol |> to(accepted expected_post(), [expected_url(), json_docs, [{"Content-type", "application/json"}]])
          end
        end
        context "head of list is wrong type" do
          let :docs, do: [1]
          it "should not post" do
            subject()
            expect Elsol |> to_not(accepted expected_post())
          end
        end
      end
      context "doc string" do
        let :docs do
          {status, docs} = Poison.encode([%{id: "1", name: "foo"}, %{id: 2, name: "bar"}])
          docs
        end
        it "should pass the doc string correctly" do
          should eql "posted"
          expect Elsol |> to(accepted expected_post(), [expected_url(), docs(), [{"Content-type", "application/json"}]])
        end
      end
    end

    context "without docs" do

    end


  end

  example_group do
    describe "query" do
      let :method, do: :query
      let :request_method, do: :get
      it_behaves_like SharedQueryExample
    end
    
    describe "query!" do
      let :method, do: :query!
      let :request_method, do: :get!
      it_behaves_like SharedQueryExample
    end

    describe "update" do
      let :method, do: :update
      let :expected_get, do: :get
      let :expected_post, do: :post
      let :struct, do: %Elsol.Query.Update{url: "http://localhost:8983/solr", commit: true, collection: %Elsol.Collection{name: "foo"}}

      it_behaves_like SharedUpdateExample
    end
    
    describe "update!" do
      let :method, do: :update!
      let :expected_get, do: :get!
      let :expected_post, do: :post!
      let :struct, do: %Elsol.Query.Update{url: "http://localhost:8983/solr", commit: true, collection: %Elsol.Collection{name: "foo"}}

      it_behaves_like SharedUpdateExample
    end
    
  end
end
