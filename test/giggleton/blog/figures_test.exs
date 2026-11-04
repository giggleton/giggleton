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
