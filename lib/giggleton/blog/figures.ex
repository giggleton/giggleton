defmodule Giggleton.Blog.Figures do
  @moduledoc """
  Inlines a post's static charts at compile time.

  A chart is referenced in Markdown as an image, alone in its paragraph, whose source is an
  SVG under `/charts/` and whose alt text is the caption:

      ![Fig. 1 — Heavier cars go fewer miles per gallon](/charts/2026-11-03-first-stitches/mtcars.svg)

  The SVG is read from `priv/static`, its fixed `width` and `height` are dropped so it scales
  to the column by its `viewBox`, and it is set in the stitched chart frame with the caption
  below. Nothing inside the SVG is changed: it keeps the colours and fonts of its Giggly theme.
  """

  @static "priv/static"
  @image ~r{<p><img src="(/charts/[^"]+\.svg)" alt="([^"]*)" /></p>}
  @svg_tag ~r{<svg\b[^>]*>}
  @size_attr ~r{\s(?:width|height)=(["'])[^"']*\1}

  @doc """
  Replaces each chart image in `html` with its framed, inlined SVG.

  Returns the new HTML and the chart files read, so the caller can recompile when one changes.
  Raises if a chart file is missing or has no `viewBox`.
  """
  @spec inline(String.t(), Path.t()) :: {String.t(), [Path.t()]}
  def inline(html, post_path) do
    files = for [_, src, _] <- Regex.scan(@image, html), uniq: true, do: file(src)
    html = Regex.replace(@image, html, fn _, src, caption -> figure(src, caption, post_path) end)
    {html, files}
  end

  defp figure(src, caption, post_path) do
    id = "fig-" <> Path.basename(src, ".svg")

    svg =
      case File.read(file(src)) do
        {:ok, svg} ->
          prepare(svg, id, src, post_path)

        {:error, _} ->
          raise ArgumentError, "#{post_path}: no chart at #{file(src)}; run mix charts"
      end

    """
    <figure class="stitched chart-frame" aria-labelledby="#{id}">
    #{svg}
    <figcaption id="#{id}">#{caption}</figcaption>
    </figure>
    """
  end

  defp prepare(svg, id, src, post_path) do
    svg = svg |> String.replace(~r{<\?xml.*?\?>|<!DOCTYPE[^>]*>}s, "") |> String.trim()

    [tag] = Regex.run(@svg_tag, svg) || raise ArgumentError, "#{post_path}: #{src} is not an SVG"

    unless tag =~ "viewBox",
      do: raise(ArgumentError, "#{post_path}: #{src} has no viewBox, so it can't scale")

    new_tag =
      tag
      |> String.replace(@size_attr, "")
      |> String.replace_suffix(">", ~s( role="img" aria-labelledby="#{id}">))

    String.replace(svg, tag, new_tag, global: false)
  end

  defp file("/" <> src), do: Path.join(@static, src)
end
