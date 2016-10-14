defmodule Elsol do

  use HTTPoison.Base

  # When we just want to pass through a whole url and query_string...(no construction of url required)
  def query(query_arg, timeout \\ 30000), do: _query(query_arg, false, timeout)
  def query!(query_arg, timeout \\ 30000), do: _query(query_arg, true, timeout)

  def _query(query_arg, bang \\ false, timeout \\ 30000) do
    meth = cond do
      bang -> :get!
      !bang -> :get
    end
    query_args = cond do
      is_binary(query_arg) -> [query_arg, [], [recv_timeout: timeout]]
      true -> [build_query(query_arg), [], [recv_timeout: timeout]]
    end
    apply(__MODULE__, meth, query_args)
  end

  @doc """
  Send a list of solr_docs to an update handler using `%Elsol.Query.Update{}` struct,
  e.g. `Elsol.update(%Elsol.Query.Update{url: config_key, name: "/update"})`. See `build_query`
  for more details.

  solr_docs can be:
    - a List of field-value documents (in Map)
    - encoded JSON field-value array string
    - see `https://wiki.apache.org/solr/UpdateJSON`

  Other update message formats such as CSV, XML are currently not supported.

  Raw 'add doc' update messages (atomic updates), and other update commands
  such as 'delete', 'commit' can also be issued as part of the encoded
  JSON string (`solr_docs`) for JSON update handler.

  Direct update commands can also be issued using the `%Elsol.Query.Update{}` struct:
    - `Elsol.update(%Elsol.Query.Update{url: config_key, commit: "true", expungeDeletes: "true"})`
    - `Elsol.update(%Elsol.Query.Update{url: config_key, optimize: "true", maxSegments: 10})`

  """
  def update(struct, docs) when is_list(docs) and is_map(hd docs) do
    { status, json_docs } = Poison.encode docs
    cond do
      status == :ok -> post build_query(struct), json_docs, [{"Content-type", "application/json"}]
      true -> {:error, "Unable to parse solr documents"}
    end
  end
  
  

  def update(struct, docs) when is_binary(docs) do
    post build_query(struct), docs, [{"Content-type", "application/json"}]
  end

  def update(_struct, _docs), do: {:error, "Unknown solr documents"}

  # For direct update commands without solr_docs such as commit, optimize
  def update(struct), do: get build_query(struct), [], [recv_timeout: 30000]
  def update!(struct), do: get! build_query(struct), [], [recv_timeout: 30000]

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

  # decode JSON data for now
  def process_response_body("{\"responseHeader\":{" <> body) do
    Poison.decode! "{\"responseHeader\":{" <> body
  end

  # to fix: decode other types of Solr data, returns iodata for now
  # https://cwiki.apache.org/confluence/display/solr/Response+Writers
  def process_response_body(body) do
    body
  end

end