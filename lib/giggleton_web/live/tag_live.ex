defmodule GiggletonWeb.TagLive do
  @moduledoc "The entries carrying one tag. An unused tag is a 404."
  use GiggletonWeb, :live_view

  alias Giggleton.Blog

  @impl true
  def mount(%{"tag" => tag}, _session, socket) do
    posts = Blog.posts_tagged!(tag)

    {:ok,
     socket
     |> assign(
       page_title: "Tagged #{tag}",
       page_description: "Entries in the Giggleton diary tagged #{tag}.",
       tag: tag,
       count: length(posts),
       tags: Blog.all_tags()
     )
     |> stream_configure(:posts, dom_id: &"post-#{&1.slug}")
     |> stream(:posts, posts)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:posts}>
      <header class="page-intro">
        <p class="kicker">Tag</p>
        <h1 id="tag-title">{@tag}</h1>
        <p class="lede">
          {entries_label(@count)} tagged {@tag}. <.link navigate={~p"/posts"}>Every entry</.link>
        </p>
      </header>

      <div class="listing">
        <section id="posts" class="stitched post-list" phx-update="stream" aria-label="Entries">
          <.post_card :for={{id, post} <- @streams.posts} id={id} post={post} />
        </section>

        <aside class="listing-aside" aria-labelledby="tags-heading">
          <h2 id="tags-heading" class="section-heading">Tags</h2>
          <.tag_list id="all-tags" tags={@tags} current={@tag} />
        </aside>
      </div>
    </Layouts.app>
    """
  end

  defp entries_label(1), do: "One entry"
  defp entries_label(count), do: "#{count} entries"
end
