defmodule GiggletonWeb.ResidentLiveTest do
  use GiggletonWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Giggleton.{Blog, Residents}

  test "the residents page has a card for each, linking to their page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/residents")

    assert has_element?(view, ~s(nav a[aria-current="page"]), "Residents")

    for resident <- Residents.all_residents() do
      assert has_element?(
               view,
               "#resident-#{resident.id}[href='/residents/#{resident.id}'] h2",
               resident.name
             )
    end
  end

  test "the residents page lists the neighbors, each linking to its documentation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/residents")

    assert has_element?(view, "#neighbors-heading")

    for neighbor <- Giggleton.Neighbors.all_neighbors() do
      assert has_element?(
               view,
               "#neighbor-#{neighbor.id}[href='#{neighbor.docs}'] h3",
               neighbor.id
             )
    end
  end

  test "a resident's page shows their workshop and their plate", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/residents/pica")

    assert page_title(view) =~ "Pica"
    assert has_element?(view, ~s(nav a[aria-current="page"]), "Residents")
    assert has_element?(view, "#resident-title", "Pica")
    assert has_element?(view, "#resident .prose p")
    assert has_element?(view, "#resident-plate.blue svg[role='img']")
    assert has_element?(view, "#resident-plate a[href='https://hexdocs.pm/pica']")
    assert has_element?(view, "#resident-plate a[href='https://github.com/giggleton/pica']")
  end

  test "Giggly's and Pica's pages show the charts their examples draw", %{conn: conn} do
    for id <- ["giggly", "pica"] do
      {:ok, view, _html} = live(conn, ~p"/residents/#{id}")

      assert has_element?(view, "#resident figure.chart-frame svg[role='img']")
    end
  end

  test "a resident's page lists the diary entries about them", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/residents/scales")

    for post <- Blog.posts_about(:scales) do
      assert has_element?(view, "#resident-posts #post-#{post.slug}")
    end

    assert has_element?(view, "#resident-posts-empty.hidden")
  end

  test "a resident's page links next door both ways", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/residents/giggly")

    assert has_element?(view, "#before-resident[href='/residents/scales']")
    assert has_element?(view, "#next-resident[href='/residents/pica']")
    assert has_element?(view, "#all-residents[href='/residents']")
  end

  test "an unknown resident is a 404", %{conn: conn} do
    assert_error_sent 404, fn -> get(conn, ~p"/residents/ggity") end
  end
end
