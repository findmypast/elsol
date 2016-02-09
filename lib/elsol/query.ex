defmodule Elsol.Query do

  @moduledoc """
    Example of a simple and extensible Elixir module for building Solr query string
    according to existing syntax, using a single `build` function type with 
    pattern-matching and recursion.

    For sub-parameters (dotted) such as `facet.count`, `facet.range.gap`, substitute `.` 
    with `_` in field keys (atoms), e.g. `facet_count`, `facet_range_gap`.

    Most Solr params are optional (nil) and shall not be rendered unless a value is given.
    Change `name: "/select"` for other custom request handlers.

    ## Examples, use the `%Elsol.Query{}` struct to build a simple query

        iex> Elsol.Query.build(%Elsol.Query{q: "market", rows: 20, fq: ["postcode:1234", "city:london"], fl: "*"})
        "/select?fl=*&fq=postcode:1234&fq=city:london&q=market&rows=20"
    
    ## use the `%Elsol.Query{}` and `%Elsol.Query.Facet` structs to include faceting
        
        iex> Elsol.Query.build( Map.merge %Elsol.Query{q: "{!lucene}*:*"}, %Elsol.Query.Facet{facet_field: ["postcode", "city"]})
        "/select?facet=true&facet.field=postcode&facet.field=city&q={!lucene}*:*"

  """

  defstruct url: nil, name: "/select", q: nil, fq: nil, start: nil, rows: nil, wt: nil, sort: nil, echoParams: nil, fl: nil

  defmodule Facet, do: defstruct facet: true, facet_field: [], facet_query: [], facet_pivot: [],
                                 facet_range: nil, facet_range_start: nil, facet_range_end: nil, facet_range_gap: nil,
                                 facet_limit: nil, facet_mincount: nil, facet_sort: nil

  defmodule Highlight, do: defstruct hl: true, hl_fl: nil, hl_fragsize: nil,
                                     hl_requireFieldMatch: nil, hl_tag_pre: nil,
                                     hl_tag_post: nil, hl_useFastVectorHighlighter: nil

  defmodule Suggest, do: defstruct url: nil, name: "/suggest", suggest: true, suggest_dictionary: [], suggest_q: nil,
                                   suggest_build: nil, suggest_count: nil, suggest_cfq: nil, suggest_build: nil,
                                   suggest_reload: nil, suggest_buildAll: nil, suggest_reloadAll: nil

  defmodule Terms, do: defstruct url: nil, name: "/terms", terms: true,  terms_fl: nil,
                                 terms_limit: nil, terms_lower: nil, terms_lower_incl: nil, terms_mincount: nil,
                                 terms_maxcount: nil, terms_prefix: nil, terms_raw: nil,
                                 terms_regex: nil, terms_regex_flag: nil, terms_sort: nil,
                                 terms_upper: nil, terms_upper_incl: nil

  defmodule Stats, do: defstruct stats: true, stats_field: [], stats_calcdistinct: nil

  def build(params) when is_map(params) do
    cond do
      Map.has_key?(params, :name) -> params.name <> "?" <> build( Map.delete(params, :url) |> Map.delete(:name) |> Map.to_list )
      true -> build( Map.to_list(params) )
    end
  end

  def build([head|tail]) do
    (build(head) <> build(tail)) |> String.rstrip ?&
  end

  def build({k,v}) when is_bitstring(v) or is_integer(v) do
    (Atom.to_string(k) |> String.replace("_","."))  <> "=#{v}&"
  end

  def build({k, v}) when is_boolean(v), do: Atom.to_string(k) <> "=#{v}&"

  def build({k,v}) when is_list(v) and length(v)>0 do
    build({k, hd(v)}) <> build({k, tl(v)})
  end

  def build({:__struct__, _}), do: ""
  def build({_, nil}), do: ""
  def build({_,[]}), do: ""
  def build([]), do: "" 

end
