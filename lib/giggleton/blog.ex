defmodule Giggleton.Blog do
  @moduledoc """
  The village diary: every post under `priv/content/posts`, compiled into this module.

  Posts are sorted and numbered at compile time, newest first. Tags are plain front-matter
  strings; NimblePublisher has no notion of them, so the tag list is gathered here too.
  """

  alias Giggleton.Blog.{NotFoundError, Post}

  use NimblePublisher,
    build: Post,
    from: "priv/content/posts/**/*.md",
    as: :posts,
    html_converter: Giggleton.Markdown,
    highlighters: [:makeup_elixir]

  # Recompile when a post's chart is redrawn, not only when its Markdown changes.
  for post <- @posts, chart <- post.charts do
    @external_resource chart
  end

  @posts @posts
         |> Enum.sort_by(&{&1.date, &1.slug}, :asc)
         |> Enum.with_index(1)
         |> Enum.map(fn {post, entry} -> %{post | entry: entry} end)
         |> Enum.reverse()

  duplicates = @posts |> Enum.frequencies_by(& &1.slug) |> Enum.filter(&(elem(&1, 1) > 1))

  if duplicates != [] do
    raise ArgumentError,
          "two posts share a slug: #{duplicates |> Enum.map(&elem(&1, 0)) |> Enum.join(", ")}"
  end

  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  @doc "Every post, newest first."
  @spec all_posts() :: [Post.t()]
  def all_posts, do: @posts

  @doc "The newest `count` posts."
  def recent_posts(count), do: Enum.take(@posts, count)

  @doc "Every tag used by any post, in alphabetical order."
  def all_tags, do: @tags

  @doc "The post with this slug. Raises `Giggleton.Blog.NotFoundError` if there is none."
  def get_post!(slug) do
    Enum.find(@posts, &(&1.slug == slug)) ||
      raise NotFoundError, "no post with slug #{inspect(slug)}"
  end

  @doc "Posts carrying `tag`, newest first. Raises `Giggleton.Blog.NotFoundError` for an unused tag."
  def posts_tagged!(tag) do
    case Enum.filter(@posts, &(tag in &1.tags)) do
      [] -> raise NotFoundError, "no posts tagged #{inspect(tag)}"
      posts -> posts
    end
  end

  @doc "Posts about the resident with this id, newest first; none is an empty list."
  @spec posts_about(atom()) :: [Post.t()]
  def posts_about(resident), do: Enum.filter(@posts, &(resident in &1.residents))

  @doc "The posts either side of `post`, as `{older, newer}`; either may be nil."
  def neighbours(%Post{entry: entry}) do
    index = length(@posts) - entry
    older = Enum.at(@posts, index + 1)
    newer = if index > 0, do: Enum.at(@posts, index - 1)
    {older, newer}
  end
end
