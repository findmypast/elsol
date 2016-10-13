defmodule ElsolSpec.CollectionSpec do

  use ESpec, async: true

  defmodule SharedPathSuccess do
    use ESpec, shared: true
    let_overridable [:subject, :collection_name]

    it "should retrieve the expected path" do
      should eq "/" <> collection_name
    end
  end

  defmodule SharedPathFailure do
    use ESpec, shared: true
    let_overridable [:subject, :collection_name]

    it "should retrieve the expected path" do
      should eq ""
    end
  end

  defmodule SharedPathSuccessForString do
    use ESpec, shared: true
    let_overridable [:subject, :collection_name, :collection_string]
    it "should return the string as-is" do
      should eq collection_string()
    end
  end

  example_group do
    describe "path" do

      let :collection, do: %Elsol.Collection{name: collection_name()}
      let :collection_name, do: "my_collection_name"
      subject do: Elsol.Collection.path(path_arg)

      context "with a Collection struct" do
        let :path_arg, do: collection()
        it_behaves_like SharedPathSuccess

        context "if the collection name is nil" do
          let :collection_name, do: nil
          it_behaves_like SharedPathFailure
        end
      end

      context "with a Query struct" do
        let :path_arg, do: %Elsol.Query{collection: collection()}
        it_behaves_like SharedPathSuccess
        context "if a collection is not specified" do
          let :collection, do: nil
          it_behaves_like SharedPathFailure
        end

        context "if the collection is a string" do
          let :collection_string, do: "/this_collection"
          let :collection, do: collection_string()
          it_behaves_like SharedPathSuccessForString
        end

      end

      context "with a string as an argument" do
        let :collection_string, do: "/this_collection"
        let :path_arg, do: collection_string()
        it_behaves_like SharedPathSuccessForString
      end
      
      context "with nil as an argument" do
        let :path_arg, do: nil
        it_behaves_like SharedPathFailure
      end
      
      context "with an arbitrary struct" do
        context "if the key :collection exists" do
          let :collection, do: %Elsol.Collection{name: collection_name()}
          let :path_arg, do: %{collection: collection()}
          it_behaves_like SharedPathSuccess
        end
        context "if the key :name exists" do
          let :path_arg, do: %{name: "/" <> collection_name()}
          it_behaves_like SharedPathSuccess
        end
      end

    end
  end
end
