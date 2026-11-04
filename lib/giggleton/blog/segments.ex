defmodule Giggleton.Blog.Segments do
  @moduledoc """
  Splits a post's compiled HTML at its live demo markers.

  A post marks where a demo goes with an HTML comment on a line of its own, between
  paragraphs:

      Move the slider and Giggly redraws the histogram.

      <!-- demo: Bins -->

      At three bins it's one lump.

  The name is a module under `GiggletonWeb.Demos`, a `Phoenix.LiveComponent`. The HTML becomes
  a list of segments, `{:html, binary}` and `{:demo, module, id}`, which the post page renders
  in order, mounting each demo in place. A marker inside a paragraph raises, since the split
  would land inside a tag. Whether each module exists is checked by the test suite.
  """

  @marker ~r/^<!--\s*demo:\s*(\S+)\s*-->$\n?/m
  @name ~r/\A[A-Z][A-Za-z0-9]*\z/

  @type segment :: {:html, String.t()} | {:demo, module(), String.t()}

  @doc """
  The segments of `html`, with each demo given an id unique on the page, `demo-1` onward.

      iex> Giggleton.Blog.Segments.split("<p>Before</p>\\n<!-- demo: Bins -->\\n<p>After</p>\\n", "post.md")
      [{:html, "<p>Before</p>\\n"}, {:demo, GiggletonWeb.Demos.Bins, "demo-1"}, {:html, "<p>After</p>\\n"}]
  """
  @spec split(String.t(), Path.t()) :: [segment()]
  def split(html, path) do
    {segments, _count} =
      @marker
      |> Regex.split(html, include_captures: true)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map_reduce(1, fn part, count ->
        case Regex.run(@marker, part) do
          [^part, name] -> {{:demo, module!(name, path), "demo-#{count}"}, count + 1}
          _ -> {{:html, check!(part, path)}, count}
        end
      end)

    segments
  end

  defp module!(name, path) do
    if name =~ @name do
      Module.concat(GiggletonWeb.Demos, name)
    else
      raise ArgumentError, "#{path}: demo #{inspect(name)} must be a module name, like Bins"
    end
  end

  defp check!(html, path) do
    if html =~ ~r/<!--\s*demo:/ do
      raise ArgumentError,
            "#{path}: a demo marker must be on a line of its own, between paragraphs"
    end

    html
  end
end
