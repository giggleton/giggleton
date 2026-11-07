defmodule GiggletonWeb.HomeLive do
  @moduledoc """
  The home page: the greeting, the latest diary entry in a wide panel, the few entries before
  it as a compact index, and the residents in a quiet band at the foot.

  The entries come from `Giggleton.Blog` and the residents from `Giggleton.Residents`.
  """
  use GiggletonWeb, :live_view

  alias Giggleton.{Blog, Residents}

  # The latest entry plus this many before it.
  @earlier_count 3

  @impl true
  def mount(_params, _session, socket) do
    {latest, earlier} =
      case Blog.recent_posts(@earlier_count + 1) do
        [latest | earlier] -> {latest, earlier}
        [] -> {nil, []}
      end

    {:ok,
     socket
     |> assign(
       page_title: "A village in cross-stitch",
       page_description:
         "Giggleton is the diary of a village where Elixir's charts get drawn: Giggly, Pica and Scales.",
       latest: latest,
       earlier?: earlier != [],
       residents: Residents.all_residents()
     )
     |> stream_configure(:earlier, dom_id: &"earlier-#{&1.slug}")
     |> stream(:earlier, earlier)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:home}>
      <section class="hero" aria-labelledby="greeting">
        <h1 id="greeting">A village in<br />cross-stitch</h1>
        <p class="lede">
          Giggleton is where Elixir's charts get drawn. Giggly keeps the garden plots, Pica runs
          the press and Scales keeps the weights and measures. This is the village diary.
        </p>
      </section>

      <section :if={@latest} id="latest" class="stitched featured" aria-label="The latest entry">
        <.post_card id="latest-post" post={@latest} />
      </section>

      <section :if={@earlier?} class="earlier" aria-labelledby="earlier-heading">
        <div class="earlier-head">
          <h2 id="earlier-heading" class="section-heading">Earlier entries</h2>
          <.link id="every-entry" navigate={~p"/posts"} class="every-entry">Every entry</.link>
        </div>
        <div id="earlier" class="stitched post-index" phx-update="stream">
          <.post_row :for={{id, post} <- @streams.earlier} id={id} post={post} />
        </div>
      </section>

      <section id="residents" class="resident-band" aria-labelledby="residents-heading">
        <h2 id="residents-heading" class="kicker">Who lives here</h2>
        <ul>
          <li :for={resident <- @residents}>
            <.resident_line resident={resident} />
          </li>
        </ul>
      </section>
    </Layouts.app>
    """
  end
end
