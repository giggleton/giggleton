defmodule GiggletonWeb.PostLive do
  @moduledoc "One diary entry, with links to the entries either side."
  use GiggletonWeb, :live_view

  alias Giggleton.Blog

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    post = Blog.get_post!(slug)
    {older, newer} = Blog.neighbours(post)

    {:ok,
     assign(socket,
       page_title: post.title,
       page_description: post.description,
       post: post,
       older: older,
       newer: newer
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:posts}>
      <article id="post" class="stitched post" aria-labelledby="post-title">
        <header>
          <.post_kicker post={@post} full_date />
          <h1 id="post-title">{@post.title}</h1>
        </header>

        <div class="prose">{raw(@post.body)}</div>

        <footer :if={@post.tags != []} class="post-footer">
          <.tag_list id="post-tags" tags={@post.tags} aria-label="Tags" />
        </footer>
      </article>

      <nav id="post-neighbours" class="post-neighbours" aria-label="More entries">
        <.link :if={@older} id="older-post" navigate={~p"/posts/#{@older.slug}"} rel="prev">
          <.pixel_art name="arrow" size={16} class="back" />
          <span><span class="kicker">Older</span>{@older.title}</span>
        </.link>
        <.link id="all-posts" navigate={~p"/posts"} class="all">Every entry</.link>
        <.link :if={@newer} id="newer-post" navigate={~p"/posts/#{@newer.slug}"} rel="next">
          <span><span class="kicker">Newer</span>{@newer.title}</span>
          <.pixel_art name="arrow" size={16} />
        </.link>
      </nav>
    </Layouts.app>
    """
  end
end
