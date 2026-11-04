defmodule GiggletonWeb.Feeds.Atom do
  @moduledoc """
  The diary as an Atom feed.

  Each entry's content is the post as Markdown made it, made fit for a feed reader: links and
  images point at the site's full address, so a static chart is an `<img>` of its committed
  SVG; heading anchors are dropped; and a live demo, which a reader can't run, becomes a line
  linking to the post.
  """

  import Phoenix.HTML, only: [html_escape: 1, safe_to_string: 1]

  alias Giggleton.Blog.Post

  @demo ~r/^<!--\s*demo:\s*\S+\s*-->$/m
  @anchor ~r{<a href="#[^"]*"[^>]*class="anchor"[^>]*></a>}
  @relative ~r{(src|href)="/(?!/)}

  @doc """
  The feed for `posts`, newest first, on the site at `base_url` (no trailing slash), whose
  feed lives at `self_url`.
  """
  @spec render([Post.t()], String.t(), String.t()) :: String.t()
  def render(posts, base_url, self_url) do
    updated =
      case posts do
        [newest | _] -> timestamp(newest.date)
        [] -> timestamp(~D[1970-01-01])
      end

    entries = Enum.map(posts, &entry(&1, base_url))

    """
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <id>#{esc(base_url <> "/")}</id>
      <title>Giggleton</title>
      <subtitle>The diary of a village where Elixir's charts get drawn.</subtitle>
      <link rel="alternate" type="text/html" href="#{esc(base_url <> "/")}"/>
      <link rel="self" type="application/atom+xml" href="#{esc(self_url)}"/>
      <updated>#{updated}</updated>
      <author><name>Giggleton</name></author>
    #{Enum.join(entries)}</feed>
    """
  end

  defp entry(post, base_url) do
    url = "#{base_url}/posts/#{post.slug}"
    categories = Enum.map(post.tags, &~s(    <category term="#{esc(&1)}"/>\n))

    """
      <entry>
        <id>#{esc(url)}</id>
        <title>#{esc(post.title)}</title>
        <link rel="alternate" type="text/html" href="#{esc(url)}"/>
        <published>#{timestamp(post.date)}</published>
        <updated>#{timestamp(post.date)}</updated>
        <summary>#{esc(post.description)}</summary>
    #{categories}    <content type="html">#{esc(content(post, base_url, url))}</content>
      </entry>
    """
  end

  @doc false
  def content(post, base_url, url) do
    post.feed_body
    |> String.replace(
      @demo,
      ~s(<p><em><a href="#{url}">This entry has a live chart. Open it on the site to try it.</a></em></p>)
    )
    |> String.replace(@anchor, "")
    |> String.replace(@relative, ~s(\\1="#{base_url}/))
  end

  defp timestamp(date), do: date |> DateTime.new!(~T[00:00:00]) |> DateTime.to_iso8601()

  defp esc(text), do: text |> html_escape() |> safe_to_string()
end
