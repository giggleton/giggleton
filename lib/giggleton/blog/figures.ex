defmodule Giggleton.Blog.Figures do
  @moduledoc """
  Inlines a post's static charts at compile time.

  A chart is referenced in Markdown as an image, alone in its paragraph, whose source is an
  SVG under `/charts/` and whose alt text is the caption:

      ![Fig. 1 — Heavier cars go fewer miles per gallon](/charts/2026-11-03-first-stitches/mtcars.svg)

  The SVG is read from `priv/static`, its fixed `width` and `height` are dropped so it scales
  to the column by its `viewBox`, and it is set in the stitched chart frame with the caption
  below. Nothing inside the SVG is changed: it keeps the colours and fonts of its Giggly theme.

  A chart not drawn yet fails a prod build. In dev and test it is a compile warning and a
  placeholder in the frame instead, since `mix charts` lives in this project and can only run
  once the project compiles.
  """

  @static "priv/static"
  @image ~r{<p><img src="(/charts/[^"]+\.svg)" alt="([^"]*)" /></p>}
  @svg_tag ~r{<svg\b[^>]*>}
  @size_attr ~r{\s(?:width|height)=(["'])[^"']*\1}
  @missing if Mix.env() == :prod, do: :raise, else: :warn

  @doc """
  Replaces each chart image in `html` with its framed, inlined SVG.

  Returns the new HTML and the chart files it names, so the caller can recompile when one is
  drawn or redrawn. Raises if a chart has no `viewBox`. A missing chart raises when `missing`
  is `:raise`, the default in prod, and warns and leaves a placeholder when it is `:warn`.
  """
  @spec inline(String.t(), Path.t(), :raise | :warn) :: {String.t(), [Path.t()]}
  def inline(html, post_path, missing \\ @missing) do
    files = for [_, src, _] <- Regex.scan(@image, html), uniq: true, do: file(src)

    html =
      Regex.replace(@image, html, fn _, src, caption ->
        figure(src, caption, post_path, missing)
      end)

    {html, files}
  end

  defp figure(src, caption, post_path, missing) do
    id = "fig-" <> Path.basename(src, ".svg")

    svg =
      case {File.read(file(src)), missing} do
        {{:ok, svg}, _} ->
          case scalable(svg, id) do
            {:ok, svg} -> svg
            {:error, reason} -> raise ArgumentError, "#{post_path}: #{src} #{reason}"
          end

        {{:error, _}, :raise} ->
          raise ArgumentError, "#{post_path}: no chart at #{file(src)}; run mix charts"

        {{:error, _}, :warn} ->
          IO.warn("#{post_path}: no chart at #{file(src)}; run mix charts", [])
          ~s(<p class="chart-missing">Not drawn yet. Run <code>mix charts</code>.</p>)
      end

    """
    <figure class="stitched chart-frame" aria-labelledby="#{id}">
    #{svg}
    <figcaption id="#{id}">#{caption}</figcaption>
    </figure>
    """
  end

  @doc """
  An SVG made ready to sit in a chart frame: its XML prologue and fixed `width` and `height`
  dropped so it scales by its `viewBox`, and labelled by the caption with id `caption_id`.
  Live demos use it on each SVG they draw.

  Every id inside the SVG, and every reference to one, is prefixed with `caption_id`, so two
  charts on a page never share an id. Giggly names its clip paths and glyphs by their content,
  so two charts would otherwise repeat them.
  """
  @spec scalable(iodata(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def scalable(svg, caption_id) do
    svg =
      svg
      |> IO.iodata_to_binary()
      |> String.replace(~r{<\?xml.*?\?>|<!DOCTYPE[^>]*>}s, "")
      |> String.trim()
      |> prefix_ids(caption_id <> "-")

    case Regex.run(@svg_tag, svg) do
      nil ->
        {:error, "is not an SVG"}

      [tag] ->
        if tag =~ "viewBox" do
          new_tag =
            tag
            |> String.replace(@size_attr, "")
            |> String.replace_suffix(">", ~s( role="img" aria-labelledby="#{caption_id}">))

          {:ok, String.replace(svg, tag, new_tag, global: false)}
        else
          {:error, "has no viewBox, so it can't scale"}
        end
    end
  end

  defp prefix_ids(svg, prefix) do
    svg
    |> String.replace(~r/\bid=(['"])/, "id=\\1#{prefix}")
    |> String.replace(~r/\bhref=(['"])#/, "href=\\1##{prefix}")
    |> String.replace("url(#", "url(##{prefix}")
  end

  defp file("/" <> src), do: Path.join(@static, src)
end
