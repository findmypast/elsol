defmodule Esolr do

  use Jazz
  use HTTPoison.Base
#"/solr/select?q=*:*&rows=1000&fl=name&wt=json"

  defstruct query_string: "", facets: [], wanted_fields: "", filters: [], start: 0, rows: 0, date: [], wt: "json"

  def query(query_struct) do
    solr_query_url = FigaroElixir.env["url"] <> "/solr/testing/select?" <> create_query(query_struct)
    {:ok, json} = HTTPoison.get(solr_query_url)
    reply = JSON.decode!(json.body)
    response = reply["response"]
    response["docs"]
  end


  def create_query( query_struct) do
    query_request(query_struct) <> "&wt=json"
#    fields(query_struct[:wanted_fields]) <>
#    facet_fields(query_struct[:facets]) <>
#    filter_queries(query_struct[:filters]) <>
#    date(query_struct[:date]) <>
#    start(query_struct[:start]) <>
#    rows(query_struct[:rows])
  end


  def query_request(%Esolr{query_string: query_string}) do
    "q=#{query_string}"
  end

  def facet_fields(fields) do
    "facet=true&facet_field=" <> Enum.join(fields,"&facet.field=")
  end

  def fields(field_names_string) do
    "&fl=#{field_names_string}"
  end

  def filter_queries(filter_query_list) do
    "&fq=" <> Enum.join(filter_query_list)
  end


  def start(start_number) do
    "&start=#{start_number}"
  end

  def rows(row_count) do
    "&rows=#{row_count}"
  end

  def date([date_label, date_start, date_end, gap]) do
    "&facet.date=#{date_label}" <>
    "&f.#{date_label}.facet.range.start=#{date_start}" <>
    "&f.#{date_label}.facet.range.end=#{date_end}" <>
    "&f.#{date_label}.facet.range.gap=#{gap}"
  end

end
