defmodule GiggletonWeb.PixelArtTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias GiggletonWeb.PixelArt

  doctest GiggletonWeb.PixelArt.Runs

  test "every pattern file is compiled in" do
    assert Enum.sort(PixelArt.names()) == ~w(arrow giggly home moon pica scales sun)
  end

  test "a pattern renders as runs of thread-classed rects at the requested size" do
    assigns = %{}
    html = rendered_to_string(~H|<PixelArt.pixel_art name="home" size={40} />|)

    assert html =~ ~s(viewBox="0 0 10 10")
    assert html =~ ~s(width="40")
    assert html =~ ~s(class="px-r")
    assert html =~ ~s(aria-hidden="true")
  end

  test "a labelled pattern is an image for screen readers" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<PixelArt.pixel_art name="giggly" label="Giggly, a laughing hyena" />|
      )

    assert html =~ ~s(role="img")
    assert html =~ ~s(aria-label="Giggly, a laughing hyena")
    refute html =~ "aria-hidden"
  end
end
