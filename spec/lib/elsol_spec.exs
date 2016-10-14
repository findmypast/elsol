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
  
#  defmodule SharedUpdateExample do
#
#    use ESpec, shared: true
#    let_overridable [:method, :request_method]
#
#    subject do: apply(Elsol, method(), args())
#
#  end

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
#
#    describe "update" do
#
#      let :struct, do: %Elsol.Query.Update{commit: true, collection: %Elsol.Collection{name: "foo"}}
#
#      context "with docs" do
#
#      end
#
#      context "without docs" do
#
#      end
#
#    end
    
    
  end
end
