defmodule Giggleton.Pages do
  @moduledoc "The site's standalone pages, every file under `priv/content/pages`."

  alias Giggleton.Blog.NotFoundError
  alias Giggleton.Pages.Page

  use NimblePublisher,
    build: Page,
    from: "priv/content/pages/*.md",
    as: :pages,
    html_converter: Giggleton.Markdown,
    highlighters: [:makeup_elixir]

  for page <- @pages, chart <- page.charts do
    @external_resource chart
  end

  @doc "Every page, by slug."
  @spec all_pages() :: [Page.t()]
  def all_pages, do: Enum.sort_by(@pages, & &1.slug)

  @doc "The page with this slug. Raises `Giggleton.Blog.NotFoundError` if there is none."
  @spec get_page!(String.t()) :: Page.t()
  def get_page!(slug) do
    Enum.find(@pages, &(&1.slug == slug)) || raise NotFoundError, "no page #{inspect(slug)}"
  end
end
