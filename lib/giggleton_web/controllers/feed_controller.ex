defmodule GiggletonWeb.FeedController do
  @moduledoc "Serves the Atom feed and the sitemap, built from the compiled content."
  use GiggletonWeb, :controller

  alias GiggletonWeb.Feeds.{Atom, Sitemap}

  def atom(conn, _params) do
    xml = Atom.render(Giggleton.Blog.all_posts(), base_url(), url(~p"/feed.xml"))
    send_xml(conn, "application/atom+xml", xml)
  end

  def sitemap(conn, _params), do: send_xml(conn, "application/xml", Sitemap.render(base_url()))

  defp send_xml(conn, type, xml) do
    conn
    |> put_resp_content_type(type)
    |> put_resp_header("cache-control", "public, max-age=3600")
    |> send_resp(200, xml)
  end

  defp base_url, do: String.trim_trailing(url(~p"/"), "/")
end
