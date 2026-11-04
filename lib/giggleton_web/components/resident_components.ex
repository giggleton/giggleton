defmodule GiggletonWeb.ResidentComponents do
  @moduledoc """
  The resident card, shared by the home page and the Residents index, and the plate that
  sits beside a resident's reference page.
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: GiggletonWeb.Endpoint,
    router: GiggletonWeb.Router,
    statics: GiggletonWeb.static_paths()

  import GiggletonWeb.PixelArt

  alias Giggleton.Residents.Resident

  @doc """
  A resident's card: their pattern, name, vocation, and package and home as a label. The
  whole card links to their reference page.
  """
  attr :resident, Resident, required: true
  attr :heading, :string, default: "h3", values: ["h2", "h3"]

  def resident_card(assigns) do
    ~H"""
    <.link
      id={"resident-#{@resident.id}"}
      navigate={~p"/residents/#{@resident.id}"}
      class="stitched resident"
    >
      <.pixel_art name={Atom.to_string(@resident.id)} size={96} />
      <div>
        <.dynamic_tag tag_name={@heading}>{@resident.name}</.dynamic_tag>
        <p>{@resident.vocation}</p>
        <span class="tag">{@resident.id} · {@resident.home}</span>
      </div>
    </.link>
    """
  end

  @doc """
  The plate beside a reference page, stitched in the resident's thread: their portrait, what
  they say, the package and how to install it, and where its documentation and source live.
  """
  attr :resident, Resident, required: true
  attr :id, :string, required: true

  def resident_plate(assigns) do
    ~H"""
    <aside
      id={@id}
      class={["stitched plate", Atom.to_string(@resident.thread)]}
      aria-label={"About #{@resident.name}"}
    >
      <.pixel_art
        name={Atom.to_string(@resident.id)}
        size={192}
        label={"#{@resident.name} the #{@resident.species}, in cross-stitch"}
      />
      <blockquote class="says">
        <p>“{@resident.says}”</p>
      </blockquote>
      <dl class="facts">
        <div>
          <dt>Package</dt>
          <dd><code>{@resident.id}</code></dd>
        </div>
        <div>
          <dt>Lives at</dt>
          <dd>{@resident.home}</dd>
        </div>
        <div>
          <dt>In mix.exs</dt>
          <dd><code class="install">{@resident.install}</code></dd>
        </div>
      </dl>
      <ul class="plate-links">
        <li :if={@resident.docs}><a href={@resident.docs}>Documentation</a></li>
        <li><a href={@resident.source}>Source on GitHub</a></li>
      </ul>
    </aside>
    """
  end
end
