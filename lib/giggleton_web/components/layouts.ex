defmodule GiggletonWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use GiggletonWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  The site frame: skip link, masthead with the stitched cottage, the nav tabs and the theme
  toggle, then the page and a one-line footer.

  `current` names the tab to mark as the current page.

      <Layouts.app flash={@flash} current={:home}>
        ...
      </Layouts.app>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current, :atom, default: nil, doc: "the nav tab for this page"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <a class="skip-link" href="#main">Skip to the page</a>
    <div class="page">
      <header class="masthead-bar">
        <.link navigate={~p"/"} class="home" aria-label="Giggleton, home">
          <.pixel_art name="home" size={40} />
          <span class="name" aria-hidden="true">Giggleton</span>
        </.link>
        <nav class="site-nav" aria-label="Site">
          <.link
            :for={{key, label, path} <- nav_tabs()}
            navigate={path}
            class="tab"
            aria-current={@current == key && "page"}
          >
            {label}
          </.link>
          <.theme_toggle />
        </nav>
      </header>

      <main id="main">
        {render_slot(@inner_block)}
      </main>

      <footer class="site-footer">
        Giggleton: charts drawn by Giggly, letters measured by Pica, breaks kept by Scales.
        <a href="https://github.com/giggleton">The village on GitHub</a>
        · <a href={~p"/feed.xml"}>Feed</a>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  defp nav_tabs do
    [
      {:home, "Home", ~p"/"},
      {:posts, "Posts", ~p"/posts"},
      {:residents, "Residents", ~p"/residents"},
      {:about, "About", ~p"/about"}
    ]
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  The Linen/Midnight switch: a sun in Linen, a moon in Midnight. The script in the root layout
  applies the theme before paint and handles the event this button dispatches.
  """
  def theme_toggle(assigns) do
    ~H"""
    <button
      type="button"
      class="theme-toggle"
      phx-click={JS.dispatch("giggleton:toggle-theme")}
      aria-label="Switch between Linen and Midnight"
    >
      <.pixel_art name="sun" size={24} class="sun" />
      <.pixel_art name="moon" size={24} class="moon" />
    </button>
    """
  end
end
