defmodule Esolr do

  use Jazz
  use HTTPoison.Base

  defstruct url: "url", data_set: "testing", query_string: "", 
    facets: [], facet_limit: 5,
    wanted_fields: "", filters: [], start: 0, rows: 0, date: [], wt: "json"

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

  def create_query( query_struct) do
    query_request(query_struct) <>
    fields(query_struct) <>
    facets(query_struct) <>
    filter_queries(query_struct) <>
    date(query_struct) <>
    start(query_struct) <>
    rows(query_struct) <>
    wt(query_struct)
  end

  def date(%Esolr{date: [date_label, date_start, date_end, gap]}) do
    "&facet.date=#{date_label}" <>
    "&f.#{date_label}.facet.range.start=#{date_start}" <>
    "&f.#{date_label}.facet.range.end=#{date_end}" <>
    "&f.#{date_label}.facet.range.gap=#{gap}"
  end

  def date(%Esolr{date: []}) do
    ""
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

  def fields(%Esolr{wanted_fields: wanted_fields}) do
    "&fl=#{wanted_fields}"
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


end