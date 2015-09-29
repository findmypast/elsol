defmodule Esolr do

  use Jazz
  use HTTPoison.Base
#"/solr/select?q=*:*&rows=1000&fl=name&wt=json"
  def query(query_string) do
    solr_query_url = FigaroElixir.env["url"] <> query_string
    {:ok, json} = HTTPoison.get(solr_query_url)
    reply = JSON.decode!(json.body)
    response = reply["response"]
    response["docs"]
  end

end
