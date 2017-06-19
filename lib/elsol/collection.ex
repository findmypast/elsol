defmodule Elsol.Collection do

  @moduledoc """
    Defines a collection in Solrcloud.
    This lets us dynamically handle URL management.
  """

  # use 'name' to specify collection/core name, e.g. /solr/name/select?
  # use 'query' to specify common delimited collections in queries, e.g. select?collection=col1,col2
  defstruct name: nil, query: nil

  @doc """
    Returns either an empty string or /:collection_name.
    This is used when constructing a URL in Elsol.Query
    Note that this 
  """
  @spec path(Elsol.Collection) :: String.t
  @spec path(Elsol.Query) :: String.t
  @spec path(Map) :: String.t
  @spec path(Nil) :: String.t
  def path(%Elsol.Collection{} = collection) do
    cond do
      is_bitstring(collection.name) -> "/" <> collection.name
      true -> ""  # nil, for example
    end
  end
  
  def path(%Elsol.Query{} = query) do
    cond do
      Map.has_key?(query, :collection) -> path(query.collection)
      true -> ""
    end
  end

  def path(params) do
    cond do
      is_bitstring(params) -> params
      is_nil(params) -> ""
      is_map(params) ->
        cond do
          Map.has_key?(params, :collection) -> path(params.collection)
          Map.has_key?(params, :name) -> path(params.name)
        end
      true -> ""
    end
  end

end