defmodule GiggletonWeb.PostLiveTest do
  use GiggletonWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Giggleton.Blog

  setup do
    %{post: hd(Blog.all_posts())}
  end

  test "the diary lists every post and every tag", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, ~p"/posts")

    assert has_element?(view, ~s(nav a[aria-current="page"]), "Posts")
    assert has_element?(view, "#post-#{post.slug} h2 a[href='/posts/#{post.slug}']")

    assert length(Blog.all_posts()) ==
             view
             |> render()
             |> LazyHTML.from_document()
             |> LazyHTML.query("#posts .post-card")
             |> Enum.count()

    for tag <- Blog.all_tags() do
      assert has_element?(view, "#all-tags a[href='/tags/#{tag}']")
    end
  end

  test "a post shows its title, its body and its tags", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, ~p"/posts/#{post.slug}")

    assert page_title(view) =~ post.title
    assert has_element?(view, "#post-title", post.title)
    assert has_element?(view, "#post .prose p")
    assert has_element?(view, "#all-posts[href='/posts']")

    for tag <- post.tags do
      assert has_element?(view, "#post-tags a[href='/tags/#{tag}']")
    end
  end

  test "the first post shows its highlighted code", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/posts/first-stitches")

    assert has_element?(view, "#post pre code.makeup.elixir span.kn", "alias")
  end

  test "a tag page lists the posts carrying it", %{conn: conn, post: %{tags: [tag | _]} = post} do
    {:ok, view, _html} = live(conn, ~p"/tags/#{tag}")

    assert has_element?(view, "#tag-title", tag)
    assert has_element?(view, "#post-#{post.slug}")
    assert has_element?(view, ~s(#all-tags a[aria-current="page"]), tag)
  end

  test "an unknown post or tag is a 404", %{conn: conn} do
    assert_error_sent 404, fn -> get(conn, ~p"/posts/no-such-post") end
    assert_error_sent 404, fn -> get(conn, ~p"/tags/no-such-tag") end
  end
end
