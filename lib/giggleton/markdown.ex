defmodule Giggleton.Markdown do
  @moduledoc """
  The HTML converter NimblePublisher calls for every post, in place of Earmark.

  Earmark is retired and carries a stored-XSS advisory, so posts are parsed by MDEx. Raw HTML
  is allowed because the author is the only writer: a post can hold a `<figure>` or a demo
  marker. Elixir code blocks are then highlighted at compile time by makeup.

      iex> Giggleton.Markdown.convert("post.md", "Hello *village*", %{}, [])
      "<p>Hello <em>village</em></p>"
  """

  @options [
    extension: [
      strikethrough: true,
      table: true,
      autolink: true,
      footnotes: true,
      header_id_prefix: ""
    ],
    render: [unsafe: true]
  ]

  # MDEx writes the fence's language as `class="language-elixir"`; NimblePublisher's own
  # pattern expects a bare `class="elixir"`.
  @code_block ~r/<pre><code class="language-([^"\s]*)">([^<]*)<\/code><\/pre>/

  @doc "Converts a post body to HTML. Matches NimblePublisher's `html_converter` contract."
  def convert(_path, body, _attrs, _opts) do
    body
    |> MDEx.to_html!(@options)
    |> NimblePublisher.highlight(regex: @code_block)
  end
end
