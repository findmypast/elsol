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

  @doc """
  Build solr query with `%Elsol.Query{}` structs. See `Elsol.Query` for more details.

  Configuring endpoints:
    - default `url` setting in application config (`config :elsol`), in `config/config.exs` or other config files
    - configure multiple Solr endpoints in application config with custom keys

  Using endpoints during runtime:
    - `url` setting in app config is applied by default
    - specify custom key in query struct (`%Elsol.Query{url: config_key}`) for other pre-defined endpoints in app config
    - directly specify any Solr endpoint via `%Elsol.Query{url: "http://solr_endpoint"}`

  Examples
  ... iex doctests to do

  """

  def build_query(%{url: nil} = query_struct) do
    Application.get_env(:elsol, :url) <> Elsol.Query.build(query_struct)
  end

  def build_query(%{url: "http://" <> solr_url } = query_struct) do
     "http://" <> solr_url <> Elsol.Query.build(query_struct)
  end

  def build_query(%{url: config_key} = query_struct) do
    Application.get_env(:elsol, String.to_atom config_key) <> Elsol.Query.build(query_struct)
  end

  def process_response_body(body) do
    reply = JSON.decode!(body)
  end

end