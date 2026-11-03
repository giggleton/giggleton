defmodule GiggletonWeb.HomeLive do
  @moduledoc """
  The home page: the greeting, the latest diary entry and the three residents.

  The latest entry comes from `Giggleton.Blog`. The residents move to content when their
  reference pages arrive.
  """
  use GiggletonWeb, :live_view

  alias Giggleton.Blog

  @residents [
    %{
      pattern: "giggly",
      name: "Giggly",
      vocation: "Keeps the village garden plots.",
      package: "giggly",
      home: "The garden plots"
    },
    %{
      pattern: "pica",
      name: "Pica",
      vocation: "Runs the press and measures every letter.",
      package: "pica",
      home: "The press"
    },
    %{
      pattern: "scales",
      name: "Scales",
      vocation: "Keeps the weights, measures and palettes.",
      package: "scales",
      home: "Weights & measures"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "A village in cross-stitch",
       page_description:
         "Giggleton is the diary of a village where Elixir's charts get drawn: Giggly, Pica and Scales.",
       latest: List.first(Blog.recent_posts(1)),
       residents: @residents
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:home}>
      <section class="hero" aria-labelledby="greeting">
        <div>
          <h1 id="greeting">A village in<br />cross-stitch</h1>
          <p class="lede">
            Giggleton is where Elixir's charts get drawn. Giggly keeps the garden plots, Pica runs
            the press and Scales keeps the weights and measures. This is the village diary.
          </p>
        </div>

        <div :if={@latest} id="latest" class="stitched entry">
          <.post_card id="latest-post" post={@latest} />
        </div>
      </section>

      <section id="residents" aria-labelledby="residents-heading">
        <h2 id="residents-heading" class="section-heading">The residents</h2>
        <ul class="residents">
          <li :for={resident <- @residents} class="stitched resident">
            <.pixel_art name={resident.pattern} size={96} />
            <div>
              <h3>{resident.name}</h3>
              <p>{resident.vocation}</p>
              <span class="tag">{resident.package} · {resident.home}</span>
            </div>
          </li>
        </ul>
      </section>
    </Layouts.app>
    """
  end
end
