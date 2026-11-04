defmodule Giggleton.Blog.Post do
  @moduledoc """
  One diary entry, built by NimblePublisher from a file under `priv/content/posts`.

  The path gives the date and the slug: `posts/2026/10-28-nice-breaks.md` is the post
  `nice-breaks`, dated 28 October 2026. The front matter gives everything else:

      %{
        title: "Nice breaks, those",
        description: "Scales puts a minor tick between every pair of majors.",
        residents: [:scales],
        tags: ["breaks", "log-scales"]
      }

  `title` and `description` are required. The description is the excerpt in post lists and
  the page's meta description. `residents` and `tags` default to none. A misspelt key, a
  resident with no file under `priv/content/residents`, or a tag that isn't
  lowercase-and-hyphens fails the build.

  Charts referenced as `/charts/...svg` images are inlined by `Giggleton.Blog.Figures`, and
  the files read are kept in `charts` so the blog recompiles when one is redrawn. The body is
  then split at its live demo markers into `segments` by `Giggleton.Blog.Segments`; the post
  page renders those, and `body` keeps the whole HTML. `feed_body` is the HTML as Markdown
  made it, before any of that: charts still images, demo markers still comments. The feed
  starts from it.

  `entry` is the post's place in the diary, counted from the first post, and is filled in
  by `Giggleton.Blog` once every post is read.
  """

  @type t :: %__MODULE__{}

  @enforce_keys [:slug, :date, :title, :description, :body]
  defstruct [
    :slug,
    :date,
    :title,
    :description,
    :body,
    :entry,
    residents: [],
    tags: [],
    charts: [],
    segments: [],
    feed_body: ""
  ]

  @kebab ~r/\A[a-z0-9]+(-[a-z0-9]+)*\z/

  @doc false
  def build(path, attrs, body) do
    {date, slug} = date_and_slug!(path)

    post = struct!(__MODULE__, [slug: slug, date: date, body: body] ++ Map.to_list(attrs))
    {inlined, charts} = Giggleton.Blog.Figures.inline(body, path)
    segments = Giggleton.Blog.Segments.split(inlined, path)
    post = %{post | body: inlined, charts: charts, segments: segments, feed_body: body}

    check!(path, is_binary(post.title), "title must be a string")
    check!(path, is_binary(post.description), "description must be a string")

    residents = Giggleton.Residents.ids()

    check!(
      path,
      Enum.all?(post.residents, &(&1 in residents)),
      "residents must be in #{inspect(residents)}"
    )

    check!(
      path,
      Enum.all?(post.tags, &(is_binary(&1) and &1 =~ @kebab)),
      "tags must be lowercase-and-hyphens strings"
    )

    post
  end

  defp date_and_slug!(path) do
    with [year, month_day_slug] <- path |> Path.rootname() |> Path.split() |> Enum.take(-2),
         [month, day, slug] <- String.split(month_day_slug, "-", parts: 3),
         {:ok, date} <- Date.from_iso8601("#{year}-#{month}-#{day}"),
         true <- slug =~ @kebab do
      {date, slug}
    else
      _ ->
        raise ArgumentError,
              "#{path}: expected posts/YYYY/MM-DD-slug.md with a lowercase-and-hyphens slug"
    end
  end

  defp check!(_path, true, _message), do: :ok
  defp check!(path, false, message), do: raise(ArgumentError, "#{path}: #{message}")
end
