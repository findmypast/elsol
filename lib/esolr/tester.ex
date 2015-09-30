Esolr.start

defmodule Esolr.Tester do

  def run do
    query_string = "/solr/testing/select?q=*:*&rows=1000&fl=name&wt=json"
    Esolr.query(query_string)
  end


  def run2 do
    query_string = %Esolr{query_string: "cheese"}
    Esolr.query(query_string)
  end
end
