defmodule Esolr do

  use Jazz
  use HTTPoison.Base

  defstruct url: "url", data_set: "testing", query_string: "", 
    facets: [], facet_limit: 5,  facet_range: [], facet_query: [],
    wanted_fields: "", filters: [], start: 0, rows: 0, wt: "json",
    echo_params: "none", highlight: nil, sort: nil

  # When we just want to pass through a whole url and query_string...(no construction of url required)
  def query(solr_query_url) when is_binary(solr_query_url) do
    get(solr_query_url)
  end

  def query(query_struct) do
    solr_query_url = build_url_with_query(query_struct)
    get(solr_query_url)
  end

  def build_url_with_query(query_struct) do
    FigaroElixir.env[query_struct.url] <> "/solr/#{query_struct.data_set}/select?" <> create_query(query_struct)
  end

  def process_response_body(body) do
    reply = JSON.decode!(body)
  end

  def create_query(query_struct) do
    query_request(query_struct) <>
    fields(query_struct) <>
    facets(query_struct) <>
    filter_queries(query_struct) <>
    facet_range(query_struct) <>
    facet_query(query_struct) <>
    start(query_struct) <>
    rows(query_struct) <>
    wt(query_struct) <>
    highlight(query_struct) <>
    sort(query_struct)
  end

  def facet_range(%Esolr{facet_range: [range_field, range_start, range_end, gap]}) do
    "&facet.range=#{range_field}" <>
    "&f.#{range_field}.facet.range.start=#{range_start}" <>
    "&f.#{range_field}.facet.range.end=#{range_end}" <>
    "&f.#{range_field}.facet.range.gap=#{gap}"
  end

  def facet_range(%Esolr{facet_range: [], facet_query: []}) do
    ""
  end
  
  def facet_query(%Esolr{facet_query: facet_query}) do
    "&facet.query=" <> Enum.join(facet_query,"&facet.query=") 
  end

  def query_request(%Esolr{query_string: query_string}) do
    "q=#{query_string}"
  end

  def facets(%Esolr{facets: []}) do
    ""
  end

  def facets(%Esolr{facets: fields, facet_limit: facet_limit}) do
    "&facet=true&facet.limit=#{facet_limit}&facet.field=" <> Enum.join(fields,"&facet.field=")
  end

  def fields(%Esolr{wanted_fields: ""}) do
    ""
  end

  def fields(%Esolr{wanted_fields: wanted_fields, echo_params: echo_params}) do
    "&fl=#{wanted_fields}&echoParams=#{echo_params}"
  end

  def filter_queries(%Esolr{filters: []}) do
    ""
  end

  def filter_queries(%Esolr{filters: filters}) do
    "&fq=" <> Enum.join(filters,"&fq=")
  end

  def start(%Esolr{start: startnum}) do
    "&start=#{startnum}"
  end

  def rows(%Esolr{rows: rowcount}) do
    "&rows=#{rowcount}"
  end

  def wt(%Esolr{wt: wtype}) do
    "&wt=#{wtype}"
  end
  
  def highlight(%Esolr{highlight: nil }) do
     ""
  end
  
  def highlight(%Esolr{highlight: highlight_field }) do
    "&hl=true&hl.fl=#{highlight_field}&hl.fragsize=250&hl.requireFieldMatch=false&hl.tag.pre=%5bb%5d&hl.tag.post=%5b%2fb%5d&hl.useFastVectorHighlighter=true"
  end
  
  def sort(%Esolr{sort: nil }) do
     ""
  end
  
  def sort(%Esolr{sort: sort }) do
    "&sort=#{sort}"
  end
  
end