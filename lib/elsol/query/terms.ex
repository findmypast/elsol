defmodule Elsol.Query.Terms do

  defstruct url: nil, name: "/terms", terms: true,  terms_fl: nil,
            terms_limit: nil, terms_lower: nil, terms_lower_incl: nil, terms_mincount: nil,
            terms_maxcount: nil, terms_prefix: nil, terms_raw: nil,
            terms_regex: nil, terms_regex_flag: nil, terms_sort: nil,
            terms_upper: nil, terms_upper_incl: nil

end