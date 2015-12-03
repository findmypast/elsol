defmodule Elsol do

  use Jazz
  use HTTPoison.Base

  # When we just want to pass through a whole url and query_string...(no construction of url required)
  def query(solr_query_url) when is_binary(solr_query_url) do
    get(solr_query_url, [],[recv_timeout: 30000])
  end

  def query(query_struct) do
    solr_query_url = build_query(query_struct)
    get(solr_query_url, [],[recv_timeout: 30000])
  end

  def build_query(query_struct) do
    FigaroElixir.env["url"] <> Elsol.Query.build(query_struct)
  end

  def process_response_body(body) do
    reply = JSON.decode!(body)
  end

end