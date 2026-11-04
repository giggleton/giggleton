defmodule GiggletonWeb.Router do
  use GiggletonWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GiggletonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # The feed and sitemap need no session or CSRF token.
  scope "/", GiggletonWeb do
    get "/feed.xml", FeedController, :atom
    get "/sitemap.xml", FeedController, :sitemap
  end

  scope "/", GiggletonWeb do
    pipe_through :browser

    live_session :site do
      live "/", HomeLive
      live "/posts", PostIndexLive
      live "/posts/:slug", PostLive
      live "/tags/:tag", TagLive
      live "/residents", ResidentIndexLive
      live "/residents/:id", ResidentLive
    end
  end
end
