defmodule GiggletonWeb.HomeLiveTest do
  use GiggletonWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "the home page greets the reader and shows the three residents", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert html =~ "A village in"
    assert has_element?(view, "#latest h2 a[href='/posts/first-stitches']", "First stitches")

    for name <- ["Giggly", "Pica", "Scales"] do
      assert has_element?(view, "#residents h3", name)
    end
  end

  test "the masthead marks Home as the current page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ~s(nav a[aria-current="page"]), "Home")
  end

  test "each resident is drawn from their stitch pattern", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view |> element("#residents li:first-child svg.pixel") |> render() =~
             ~s(viewBox="0 0 24 24")
  end
end
