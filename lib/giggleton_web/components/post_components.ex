defmodule GiggletonWeb.PostComponents do
  @moduledoc """
  The pieces every post list and post page share: the kicker with date, entry number and
  residents, the post card, and the tag list.
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: GiggletonWeb.Endpoint,
    router: GiggletonWeb.Router,
    statics: GiggletonWeb.static_paths()

  import GiggletonWeb.PixelArt

  @doc """
  The label line above a post's title: "28 Oct · Entry 42", then each resident the post is
  about, drawn small. `full_date` adds the year, for the post's own page.
  """
  attr :post, Giggleton.Blog.Post, required: true
  attr :full_date, :boolean, default: false

  def post_kicker(assigns) do
    ~H"""
    <p class="kicker post-kicker">
      <span>
        <time datetime={Date.to_iso8601(@post.date)}>{format_date(@post.date, @full_date)}</time>
        · Entry {@post.entry}
      </span>
      <span :for={resident <- @post.residents} class="who">
        <.pixel_art name={Atom.to_string(resident)} size={24} />
        {resident_name(resident)}
      </span>
    </p>
    """
  end

  @doc "A post in a list: kicker, linked title, the description as its excerpt, and Read on."
  attr :post, Giggleton.Blog.Post, required: true
  attr :id, :string, required: true

  def post_card(assigns) do
    ~H"""
    <article id={@id} class="post-card" aria-labelledby={"#{@id}-title"}>
      <.post_kicker post={@post} />
      <h2 id={"#{@id}-title"}>
        <.link navigate={~p"/posts/#{@post.slug}"}>{@post.title}</.link>
      </h2>
      <p>{@post.description}</p>
      <.link navigate={~p"/posts/#{@post.slug}"} class="read-on" aria-hidden="true" tabindex="-1">
        Read on <.pixel_art name="arrow" size={16} />
      </.link>
    </article>
    """
  end

  @doc "Tags as links to their tag pages."
  attr :tags, :list, required: true
  attr :current, :string, default: nil, doc: "the tag whose page this is"
  attr :rest, :global

  def tag_list(assigns) do
    ~H"""
    <ul class="tags" {@rest}>
      <li :for={tag <- @tags}>
        <.link navigate={~p"/tags/#{tag}"} aria-current={@current == tag && "page"}>{tag}</.link>
      </li>
    </ul>
    """
  end

  @doc """
  A post date for a kicker.

      iex> GiggletonWeb.PostComponents.format_date(~D[2026-10-28], false)
      "28 Oct"
      iex> GiggletonWeb.PostComponents.format_date(~D[2026-10-28], true)
      "28 Oct 2026"
  """
  def format_date(date, false), do: Calendar.strftime(date, "%-d %b")
  def format_date(date, true), do: Calendar.strftime(date, "%-d %b %Y")

  defp resident_name(id), do: Giggleton.Residents.get_resident!(id).name
end
