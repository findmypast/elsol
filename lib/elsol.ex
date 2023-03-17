defmodule Elsol do

  use HTTPoison.Base

  # deprecated
  def query(query_arg), do: _query(query_arg, false, [], [recv_timeout: 30000])
  def query!(query_arg), do: _query(query_arg, true, [], [recv_timeout: 30000])
  def query(query_arg, timeout) when is_integer(timeout), do: _query(query_arg, false, [], [recv_timeout: timeout])
  def query!(query_arg, timeout) when is_integer(timeout), do: _query(query_arg, true, [], [recv_timeout: timeout])

  def query(query_arg, headers \\ [], options \\ []), do: _query(query_arg, false, headers, options)
  def query!(query_arg, headers \\ [], options \\ []), do: _query(query_arg, true, headers, options)

  def _query(query_arg, bang \\ false, headers \\ [], options \\ []) do
    meth = cond do
      bang -> :get!
      !bang -> :get
    end
    query_args = cond do
      is_binary(query_arg) -> [query_arg, headers, options]
      true -> [build_query(query_arg), headers, options]
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
  
  def _update(struct, docs \\ [], bang \\ false) do
    {method, {status, json_docs}} = cond do
      is_list(docs) and (length(docs) == 0) -> cond do
          bang -> {:get!, {:ok, []}}
          !bang -> {:get, {:ok, []}}
        end
      bang -> {:post!, _decoded(docs)}
      true -> {:post, _decoded(docs)}
    end

    cond do
      status == :ok -> apply(__MODULE__, method, [build_query(struct), json_docs, [{"Content-type", "application/json"}]])
      true -> {status, json_docs}
    end
  end
  
  def _decoded(docs) do
    cond do
      is_list(docs) and is_map(hd(docs)) -> Poison.encode docs
      is_binary(docs) -> {:ok, docs}
      true -> {:error, "Unknown solr documents"}
    end
  end

  def update(struct, docs \\ []), do: _update(struct, docs, false)
  def update!(struct, docs \\ []), do: _update(struct, docs, true)

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
  def build_query(query_struct) when is_map(query_struct) do
    url = Map.get(query_struct, :url)
    full_url = cond do
      is_bitstring(url) && String.match?(url, ~r/^http(s)?:\/\//) -> url
      is_bitstring(url) -> "http://"  <> url
      is_nil(url) -> Application.get_env(:elsol, :url)
      is_atom(url) -> Application.get_env(:elsol, url)
      true -> ""  # we must just not have a host?
    end
    full_url <> Elsol.Query.build(query_struct)
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