defmodule Elsol.Query.Highlight do
  defstruct hl: true, hl_fl: nil, hl_fragsize: nil, hl_snippets: nil,
            hl_requireFieldMatch: nil, hl_tag_pre: nil,
            hl_tag_post: nil, hl_useFastVectorHighlighter: nil
end