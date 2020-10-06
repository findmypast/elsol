defmodule Elsol.Query do
  @moduledoc """
    Example of a simple and extensible Elixir module for building Solr query string
    according to existing syntax, using a single `build` function type with
    pattern-matching and recursion.

    For sub-parameters (dotted) such as `facet.count`, `facet.range.gap`, substitute `.`
    with `_` in field keys (atoms), e.g. `facet_count`, `facet_range_gap`.

    Note that because of the nature of how Elixir handles maps and lists,
    query params will naturally be rendered in alphabetical order.

    Most Solr params are optional (nil) and shall not be rendered unless a value is given.
    Change `name: "/select"` for other custom request handlers.

    ## Examples, use the `%Elsol.Query{}` struct to build a simple query

        iex> Elsol.Query.build(%Elsol.Query{q: "market", rows: 20, fq: ["postcode:1234", "city:london"], fl: "*"})
        "/select?fl=*&fq=postcode:1234&fq=city:london&q=market&rows=20"

    ## use the `%Elsol.Query{}` and `%Elsol.Query.Facet` structs to include faceting

        iex> Elsol.Query.build( Map.merge %Elsol.Query{q: "{!lucene}*:*"}, %Elsol.Query.Facet{facet_field: ["postcode", "city"]})
        "/select?facet=true&facet.field=postcode&facet.field=city&q={!lucene}*:*"

  """

  defstruct url: nil,
            name: "/select",
            q: nil,
            fq: nil,
            start: nil,
            rows: nil,
            indent: "off",
            wt: "json",
            tr: nil,
            sort: nil,
            echoParams: nil,
            fl: nil,
            collection: %Elsol.Collection{}

  def build(params) when is_map(params) do
    cond do
      Map.has_key?(params, :name) ->
        # this can be an empty string or /collection_name
        # query params
        Elsol.Collection.path(params.collection) <>
          params.name <>
          "?" <>
          build(Map.drop(params, [:url, :name]) |> Map.to_list())

      true ->
        build(Map.to_list(params))
    end
  end

  def build([head | tail]) do
    (build(head) <> build(tail)) |> String.rstrip(?&)
  end

  def build({k, v}) when is_bitstring(v) or is_integer(v) do
    (Atom.to_string(k) |> String.replace("_", ".")) <> "=#{v}&"
  end

  def build({k, v}) when is_boolean(v),
    do: (Atom.to_string(k) |> String.replace("_", ".")) <> "=#{v}&"

  def build({k, v}) when is_list(v) and length(v) > 0 do
    build({k, hd(v)}) <> build({k, tl(v)})
  end

  def build({:collection, %Elsol.Collection{query: query} = _collection})
      when is_bitstring(query),
      do: "collection=#{query}&"

  def build({:collection, _collection}), do: ""
  def build({:__struct__, _}), do: ""
  def build({_, nil}), do: ""
  def build({_, []}), do: ""
  def build([]), do: ""
end
