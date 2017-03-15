defmodule Elsol.Query.Group do
  defstruct group: true, group_field: nil, group_func: nil, group_query: nil,
            group_limit: nil, group_offset: nil, group_sort: nil, group_format: nil,
            group_main: nil, group_ngroups: nil, group_truncate: nil, group_facet: nil, group_cache_percent: nil
end