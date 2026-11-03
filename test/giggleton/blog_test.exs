defmodule Giggleton.BlogTest do
  use ExUnit.Case, async: true

  alias Giggleton.Blog
  alias Giggleton.Blog.{NotFoundError, Post}

  doctest Giggleton.Markdown

  test "posts are newest first and numbered from the oldest" do
    posts = Blog.all_posts()

    assert posts == Enum.sort_by(posts, & &1.date, {:desc, Date})
    assert Enum.map(posts, & &1.entry) == Enum.to_list(length(posts)..1//-1)
  end

  test "a post is found by its slug" do
    post = hd(Blog.all_posts())

    assert Blog.get_post!(post.slug) == post
    assert_raise NotFoundError, fn -> Blog.get_post!("no-such-post") end
  end

  test "tags are gathered from every post, sorted and without repeats" do
    tags = Blog.all_tags()

    assert tags == tags |> Enum.uniq() |> Enum.sort()

    for tag <- tags do
      assert Enum.all?(Blog.posts_tagged!(tag), &(tag in &1.tags))
    end

    assert_raise NotFoundError, fn -> Blog.posts_tagged!("no-such-tag") end
  end

  test "the newest post has no newer neighbour" do
    newest = hd(Blog.all_posts())

    assert {_older, nil} = Blog.neighbours(newest)
  end

  test "Elixir code blocks are highlighted at compile time" do
    html = Giggleton.Markdown.convert("p.md", "```elixir\nalias Giggly.Plot\n```\n", %{}, [])

    assert html =~ ~s(<pre><code class="makeup elixir">)
    assert html =~ ~s(<span class="kn">alias</span>)
  end

  describe "building a post" do
    @attrs %{
      title: "Nice breaks",
      description: "Minor ticks.",
      residents: [:scales],
      tags: ["breaks"]
    }

    test "takes the date and slug from the path" do
      post = Post.build("priv/content/posts/2026/10-28-nice-breaks.md", @attrs, "<p>Hi</p>")

      assert post.date == ~D[2026-10-28]
      assert post.slug == "nice-breaks"
      assert post.residents == [:scales]
    end

    test "rejects a misspelt key, an unknown resident, a bad tag or a bad path" do
      path = "posts/2026/10-28-nice-breaks.md"

      assert_raise KeyError, fn -> Post.build(path, Map.put(@attrs, :tagz, []), "") end

      assert_raise ArgumentError, ~r/residents/, fn ->
        Post.build(path, %{@attrs | residents: [:ggity]}, "")
      end

      assert_raise ArgumentError, ~r/tags/, fn ->
        Post.build(path, %{@attrs | tags: ["Log Breaks"]}, "")
      end

      assert_raise ArgumentError, ~r/YYYY/, fn ->
        Post.build("posts/nice-breaks.md", @attrs, "")
      end

      assert_raise ArgumentError, ~r/YYYY/, fn ->
        Post.build("posts/2026/13-40-x.md", @attrs, "")
      end
    end
  end
end
