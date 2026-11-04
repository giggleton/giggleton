defmodule GiggletonWeb.ResidentLive do
  @moduledoc """
  A resident's reference page, their workshop: the page from `priv/content/residents`, their
  plate beside it, the diary entries they appear in, and the residents next door.
  """
  use GiggletonWeb, :live_view

  alias Giggleton.{Blog, Residents}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    resident = Residents.get_resident!(id)
    {before, next} = Residents.neighbours(resident)
    posts = Blog.posts_about(resident.id)

    {:ok,
     socket
     |> assign(
       page_title: "#{resident.name}, #{String.downcase(resident.home)}",
       page_description: "#{resident.name} the #{resident.species}. #{resident.vocation}",
       resident: resident,
       before: before,
       next: next,
       posts_empty?: posts == []
     )
     |> stream_configure(:posts, dom_id: &"post-#{&1.slug}")
     |> stream(:posts, posts)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:residents}>
      <header class="page-intro">
        <p class="kicker">Resident · {@resident.home}</p>
        <h1 id="resident-title">{@resident.name}</h1>
      </header>

      <div class="workshop">
        <article id="resident" class="stitched post" aria-labelledby="resident-title">
          <div class="prose">{raw(@resident.body)}</div>
        </article>

        <.resident_plate id="resident-plate" resident={@resident} />
      </div>

      <section id="resident-diary" class="resident-diary" aria-labelledby="diary-heading">
        <h2 id="diary-heading" class="section-heading">{@resident.name} in the diary</h2>
        <div id="resident-posts" class="stitched post-list" phx-update="stream">
          <p id="resident-posts-empty" class={["empty", !@posts_empty? && "hidden"]}>
            {@resident.name} hasn't been in the diary yet.
          </p>
          <.post_card :for={{id, post} <- @streams.posts} id={id} post={post} />
        </div>
      </section>

      <nav id="resident-neighbours" class="post-neighbours" aria-label="Next door">
        <.link id="before-resident" navigate={~p"/residents/#{@before.id}"} rel="prev">
          <.pixel_art name="arrow" size={16} class="back" />
          <span><span class="kicker">Next door</span>{@before.name}</span>
        </.link>
        <.link id="all-residents" navigate={~p"/residents"} class="all">Every resident</.link>
        <.link id="next-resident" navigate={~p"/residents/#{@next.id}"} rel="next">
          <span><span class="kicker">Next door</span>{@next.name}</span>
          <.pixel_art name="arrow" size={16} />
        </.link>
      </nav>
    </Layouts.app>
    """
  end
end
