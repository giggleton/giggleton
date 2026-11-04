defmodule GiggletonWeb.PageLiveTest do
  use GiggletonWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Giggleton.Pages

  test "the about page shows its title and body, with About marked in the nav", %{conn: conn} do
    page = Pages.get_page!("about")
    {:ok, view, _html} = live(conn, ~p"/about")

    assert page_title(view) =~ page.title
    assert has_element?(view, "#page-title", page.title)
    assert has_element?(view, "#page .prose p")
    assert has_element?(view, ~s(nav a[aria-current="page"]), "About")
  end

  test "every page has a route, since the sitemap lists each at /<slug>" do
    for page <- Pages.all_pages() do
      route = Phoenix.Router.route_info(GiggletonWeb.Router, "GET", "/#{page.slug}", "localhost")

      assert match?(%{phoenix_live_view: {GiggletonWeb.PageLive, _, _, _}}, route) and
               Atom.to_string(elem(route.phoenix_live_view, 1)) == page.slug,
             "#{page.slug}.md has no route; add live \"/#{page.slug}\", PageLive, :#{page.slug}"
    end
  end

  test "an unknown page is a 404" do
    assert_raise Giggleton.Blog.NotFoundError, fn -> Pages.get_page!("nowhere") end
  end
end
