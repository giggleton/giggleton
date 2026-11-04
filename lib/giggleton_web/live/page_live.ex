defmodule GiggletonWeb.PageLive do
  @moduledoc """
  A standalone page from `Giggleton.Pages`. The route's live action names the page, so
  `live "/about", PageLive, :about` shows `priv/content/pages/about.md`.
  """
  use GiggletonWeb, :live_view

  alias Giggleton.Pages

  @impl true
  def mount(_params, _session, socket) do
    page = socket.assigns.live_action |> Atom.to_string() |> Pages.get_page!()

    {:ok,
     assign(socket,
       page_title: page.title,
       page_description: page.description,
       page: page
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current={@live_action}>
      <article id="page" class="stitched post" aria-labelledby="page-title">
        <h1 id="page-title">{@page.title}</h1>
        <div class="prose">{raw(@page.body)}</div>
      </article>
    </Layouts.app>
    """
  end
end
