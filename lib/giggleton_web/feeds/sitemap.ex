defmodule GiggletonWeb.Feeds.Sitemap do
  @moduledoc """
  Every page on the site, for search engines: the home page, the diary, each post and tag,
  and the residents. A post's last change is its date; a list's is its newest post's.
  """

  import Phoenix.HTML, only: [html_escape: 1, safe_to_string: 1]

  alias Giggleton.{Blog, Residents}

  @doc "The sitemap for the site at `base_url`, with no trailing slash."
  @spec render(String.t()) :: String.t()
  def render(base_url) do
    newest = Blog.all_posts() |> List.first() |> then(&(&1 && &1.date))

    pages =
      [{"/", newest}, {"/posts", newest}] ++
        Enum.map(Blog.all_posts(), &{"/posts/#{&1.slug}", &1.date}) ++
        Enum.map(Blog.all_tags(), &{"/tags/#{&1}", newest_date(Blog.posts_tagged!(&1))}) ++
        [{"/residents", nil}] ++
        Enum.map(Residents.all_residents(), &{"/residents/#{&1.id}", nil})

    """
    <?xml version="1.0" encoding="utf-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{Enum.map_join(pages, &url(base_url, &1))}</urlset>
    """
  end

  defp newest_date([post | _]), do: post.date

  defp url(base_url, {path, nil}), do: "  <url><loc>#{esc(base_url <> path)}</loc></url>\n"

  defp url(base_url, {path, date}) do
    "  <url><loc>#{esc(base_url <> path)}</loc><lastmod>#{Date.to_iso8601(date)}</lastmod></url>\n"
  end

  defp esc(text), do: text |> html_escape() |> safe_to_string()
end
