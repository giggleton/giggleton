defmodule Giggleton.Blog.FiguresTest do
  use ExUnit.Case, async: true

  alias Giggleton.Blog.Figures

  @chart "/charts/2026-11-03-first-stitches/mtcars.svg"
  @image ~s(<p><img src="#{@chart}" alt="Fig. 1 — Heavy &amp; thirsty" /></p>)

  test "a chart image becomes its SVG in the stitched frame, captioned by the alt text" do
    {html, files} = Figures.inline("<p>Before</p>\n" <> @image, "post.md")

    assert files == ["priv/static" <> @chart]
    assert html =~ ~s(<p>Before</p>)
    assert html =~ ~s(<figure class="stitched chart-frame" aria-labelledby="fig-mtcars">)
    assert html =~ ~s(<figcaption id="fig-mtcars">Fig. 1 — Heavy &amp; thirsty</figcaption>)
    refute html =~ "<img"
  end

  test "the SVG keeps its viewBox and drops its fixed size" do
    {html, _files} = Figures.inline(@image, "post.md")
    [svg_tag] = Regex.run(~r/<svg\b[^>]*>/, html)

    assert svg_tag =~ "viewBox="
    assert svg_tag =~ ~s(role="img" aria-labelledby="fig-mtcars")
    refute svg_tag =~ ~r/\s(width|height)=/
  end

  test "ids inside the SVG, and references to them, take the figure's id as a prefix" do
    svg =
      ~s|<svg viewBox="0 0 1 1"><clipPath id='cp1'/><g clip-path='url(#cp1)'><use href='#g1'/></g></svg>|

    {:ok, svg} = Figures.scalable(svg, "fig-a")

    assert svg =~ "id='fig-a-cp1'"
    assert svg =~ "url(#fig-a-cp1)"
    assert svg =~ "href='#fig-a-g1'"
    refute svg =~ "'cp1'"
  end

  test "charts on consecutive lines of one paragraph are set side by side" do
    other = "/charts/giggly/garden.svg"
    html = ~s(<p><img src="#{@chart}" alt="Fig. 1" />\n<img src="#{other}" alt="Fig. 2" /></p>)

    {html, files} = Figures.inline(html, "post.md")
    doc = LazyHTML.from_fragment(html)

    assert files == ["priv/static" <> @chart, "priv/static" <> other]
    assert doc |> LazyHTML.query(".chart-compare > figure.chart-frame svg") |> Enum.count() == 2
    assert doc |> LazyHTML.query("#fig-mtcars") |> LazyHTML.text() == "Fig. 1"
    assert doc |> LazyHTML.query("#fig-garden") |> LazyHTML.text() == "Fig. 2"
    refute html =~ "<p>"
  end

  test "other images and text are left alone" do
    html = ~s(<p><img src="/images/cottage.png" alt="A cottage" /></p>)

    assert Figures.inline(html, "post.md") == {html, []}
  end

  describe "a missing chart" do
    @missing ~s(<p><img src="/charts/nowhere/missing.svg" alt="Fig. 9" /></p>)

    test "fails a prod build and says how to draw it" do
      assert_raise ArgumentError, ~r/run mix charts/, fn ->
        Figures.inline(@missing, "post.md", :raise)
      end
    end

    test "elsewhere warns and leaves a placeholder, still tracking the file" do
      {result, warning} =
        ExUnit.CaptureIO.with_io(:stderr, fn -> Figures.inline(@missing, "post.md", :warn) end)

      assert {html, ["priv/static/charts/nowhere/missing.svg"]} = result
      assert warning =~ "run mix charts"
      assert html =~ ~s(class="chart-missing")
      assert html =~ ~s(<figcaption id="fig-missing">Fig. 9</figcaption>)
    end
  end
end
