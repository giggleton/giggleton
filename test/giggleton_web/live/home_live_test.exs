defmodule GiggletonWeb.HomeLiveTest do
  use GiggletonWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "the home page greets the reader and leads with the latest entry", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert html =~ "A village in"
    [latest] = Giggleton.Blog.recent_posts(1)
    assert has_element?(view, "#latest h2 a[href='/posts/#{latest.slug}']", latest.title)
  end

  test "the entries before the latest are listed as an index", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    [_latest | earlier] = Giggleton.Blog.recent_posts(4)
    assert earlier != []

    for post <- earlier do
      assert has_element?(
               view,
               "#earlier-#{post.slug} h3 a[href='/posts/#{post.slug}']",
               post.title
             )
    end

    refute has_element?(view, "#earlier article:nth-child(#{length(earlier) + 1})")
    assert has_element?(view, "#every-entry[href='/posts']")
  end

  test "the residents sit in a band, each linked to their page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for {id, name} <- [giggly: "Giggly", pica: "Pica", scales: "Scales"] do
      assert has_element?(view, "#residents a#resident-#{id}[href='/residents/#{id}']", name)
    end

    refute has_element?(view, "#residents .stitched")
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
