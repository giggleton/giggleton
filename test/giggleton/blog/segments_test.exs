defmodule Giggleton.Blog.SegmentsTest do
  use ExUnit.Case, async: true

  alias Giggleton.Blog
  alias Giggleton.Blog.Segments

  doctest Segments

  test "every demo a post marks is a live component" do
    for post <- Blog.all_posts(), {:demo, module, _id} <- post.segments do
      assert Code.ensure_loaded?(module),
             "#{post.slug} marks a demo #{inspect(module)}, which doesn't exist"

      assert function_exported?(module, :__live__, 0) and module.__live__().kind == :component,
             "#{post.slug} marks a demo #{inspect(module)}, which isn't a LiveComponent"
    end
  end

  test "a post with no marker is one segment of HTML" do
    assert Segments.split("<p>Hi</p>\n", "post.md") == [{:html, "<p>Hi</p>\n"}]
  end

  test "each demo gets its own id" do
    html = "<!-- demo: Bins -->\n<p>Between</p>\n<!-- demo: Bins -->\n"

    assert [{:demo, _, "demo-1"}, {:html, _}, {:demo, _, "demo-2"}] =
             Segments.split(html, "post.md")
  end

  test "a marker inside a paragraph fails the build" do
    assert_raise ArgumentError, ~r/line of its own/, fn ->
      Segments.split("<p>Look <!-- demo: Bins --> here</p>\n", "post.md")
    end
  end

  test "a demo name must be a module name" do
    assert_raise ArgumentError, ~r/module name/, fn ->
      Segments.split("<!-- demo: bins -->\n", "post.md")
    end
  end

  test "Markdown passes a marker between paragraphs through as its own line" do
    html = Giggleton.Markdown.convert("p.md", "Before\n\n<!-- demo: Bins -->\n\nAfter\n", %{}, [])

    assert [{:html, "<p>Before</p>\n"}, {:demo, GiggletonWeb.Demos.Bins, "demo-1"}, {:html, _}] =
             Segments.split(html, "p.md")
  end
end
