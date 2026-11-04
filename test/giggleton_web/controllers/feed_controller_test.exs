defmodule GiggletonWeb.FeedControllerTest do
  use GiggletonWeb.ConnCase, async: true

  alias Giggleton.{Blog, Residents}

  # LazyHTML reads the XML as HTML, so self-closing tags such as <category/> wrap what follows;
  # selectors below match at any depth for that reason.
  defp xml(conn, path, type) do
    conn = get(conn, path)

    assert [content_type] = get_resp_header(conn, "content-type")
    assert content_type =~ type
    conn |> response(200) |> LazyHTML.from_document()
  end

  defp texts(doc, selector), do: doc |> LazyHTML.query(selector) |> Enum.map(&LazyHTML.text/1)

  defp contents_by_slug(conn) do
    doc = xml(conn, ~p"/feed.xml", "application/atom+xml")
    slugs = Enum.map(Blog.all_posts(), & &1.slug)
    slugs |> Enum.zip(texts(doc, "entry content")) |> Map.new()
  end

  test "the feed has an entry for every post, newest first", %{conn: conn} do
    doc = xml(conn, ~p"/feed.xml", "application/atom+xml")

    assert texts(doc, "entry > id") == Enum.map(Blog.all_posts(), &url(~p"/posts/#{&1.slug}"))
    assert texts(doc, "entry > summary") == Enum.map(Blog.all_posts(), & &1.description)
  end

  test "a static chart is an image of its committed SVG, at the site's full address",
       %{conn: conn} do
    content = contents_by_slug(conn)["first-stitches"]

    assert content =~ ~s(<img src="#{url(~p"/charts/2026-11-03-first-stitches/mtcars.svg")}")
    refute content =~ "<svg"
    refute content =~ ~s(class="anchor")
  end

  test "a live demo becomes a link to its post", %{conn: conn} do
    content = contents_by_slug(conn)["how-many-bins"]

    assert content =~ ~s(<a href="#{url(~p"/posts/how-many-bins")}">)
    refute content =~ "<!-- demo"
  end

  test "the sitemap lists every page", %{conn: conn} do
    locs = conn |> xml(~p"/sitemap.xml", "application/xml") |> texts("url > loc")

    paths =
      ["/posts", "/residents"] ++
        Enum.map(Blog.all_posts(), &"/posts/#{&1.slug}") ++
        Enum.map(Blog.all_tags(), &"/tags/#{&1}") ++
        Enum.map(Residents.ids(), &"/residents/#{&1}")

    assert url(~p"/") in locs
    for path <- paths, do: assert((url(~p"/") <> String.trim_leading(path, "/")) in locs)
  end

  test "every page points feed readers at the feed", %{conn: conn} do
    doc = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert texts(doc, ~s(link[rel="alternate"][type="application/atom+xml"][href="/feed.xml"])) ==
             [""]
  end
end
