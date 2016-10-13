defmodule Elsol.Query.Facet do

  defstruct facet: true, facet_field: [], facet_query: [], facet_pivot: [], facet_prefix: nil,
            facet_range: nil, facet_range_start: nil, facet_range_end: nil, facet_range_gap: nil,
            facet_limit: nil, facet_offset: nil, facet_mincount: nil, facet_sort: nil,
            facet_missing: nil, facet_method: nil, facet_enum_cache_minDf: nil, facet_threads: nil

end