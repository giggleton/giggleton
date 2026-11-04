defmodule GiggletonWeb.ResidentIndexLive do
  @moduledoc "The village's residents, one card each, in village order."
  use GiggletonWeb, :live_view

  alias Giggleton.Residents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "The residents",
       page_description:
         "Giggleton's residents: Giggly keeps the garden plots, Pica runs the press and Scales keeps the weights and measures.",
       residents: Residents.all_residents()
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
    </Layouts.app>
    """
  end
end
