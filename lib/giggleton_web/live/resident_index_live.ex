defmodule GiggletonWeb.ResidentIndexLive do
  @moduledoc "The village's residents, one card each, in village order, and then its neighbors."
  use GiggletonWeb, :live_view

  alias Giggleton.{Neighbors, Residents}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "The residents",
       page_description:
         "Giggleton's residents: Giggly keeps the garden plots, Pica runs the press and Scales keeps the weights and measures.",
       residents: Residents.all_residents(),
       neighbors: Neighbors.all_neighbors()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={:residents}>
      <header class="page-intro">
        <h1>The residents</h1>
        <p class="lede">
          Each of the village's trades is kept by one resident, and each resident is an Elixir
          package. Call at their workshops for what they do and how to ask them.
        </p>
      </header>

      <ul id="residents" class="residents">
        <li :for={resident <- @residents}>
          <.resident_card resident={resident} heading="h2" />
        </li>
      </ul>

      <section class="neighbors-section" aria-labelledby="neighbors-heading">
        <h2 id="neighbors-heading" class="section-heading">The neighbors</h2>
        <p class="lede">
          Neighbors (plugins and accessories) are welcome to visit us any time, but they don't
          make their home in Giggly. (Technically Pica is an optional package too, but she is an
          honorary citizen).
        </p>
        <ul id="neighbors" class="residents">
          <li :for={neighbor <- @neighbors}>
            <.neighbor_card neighbor={neighbor} />
          </li>
        </ul>
      </section>
    </Layouts.app>
    """
  end
end
