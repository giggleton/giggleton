defmodule GiggletonWeb.PostIndexLive do
  @moduledoc "Every diary entry, newest first, with the tags beneath."
  use GiggletonWeb, :live_view

  alias Giggleton.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "The diary",
       page_description: "Every entry in the Giggleton diary, newest first.",
       tags: Blog.all_tags()
     )
     |> stream_configure(:posts, dom_id: &"post-#{&1.slug}")
     |> stream(:posts, Blog.all_posts())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:posts}>
      <header class="page-intro">
        <h1>The diary</h1>
        <p class="lede">Every entry, newest first.</p>
      </header>

      <div class="listing">
        <section id="posts" class="stitched post-list" phx-update="stream" aria-label="Entries">
          <p id="posts-empty" class="hidden only:block muted">No entries yet.</p>
          <.post_card :for={{id, post} <- @streams.posts} id={id} post={post} />
        </section>

        <aside :if={@tags != []} class="listing-aside" aria-labelledby="tags-heading">
          <h2 id="tags-heading" class="section-heading">Tags</h2>
          <.tag_list id="all-tags" tags={@tags} />
        </aside>
      </div>
    </Layouts.app>
    """
  end
end
