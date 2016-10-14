defmodule Elsol.Query.Update do

  defstruct url: nil, name: "/update", commit: nil, optimize: nil, 
            waitFlush: nil, waitSearcher: nil, expungeDeletes: nil,
            maxSegments: nil, rollback: nil, collection: nil

end