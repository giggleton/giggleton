defmodule Giggleton.Pages.Page do
  @moduledoc """
  A standalone page, such as About, built by NimblePublisher from
  `priv/content/pages/<slug>.md`. The file name is the slug; the front matter gives the rest:

      %{
        title: "About Giggleton",
        description: "One line: the page's meta description."
      }

  Both keys are required, and a misspelt one fails the build. Charts in the body are inlined
  as in a post, by `Giggleton.Blog.Figures`.
  """

  @type t :: %__MODULE__{}

  @enforce_keys [:slug, :title, :description, :body]
  defstruct @enforce_keys ++ [charts: []]

  @doc false
  def build(path, attrs, body) do
    slug = Path.basename(path, ".md")

    unless slug =~ ~r/\A[a-z0-9]+(-[a-z0-9]+)*\z/ do
      raise ArgumentError, "#{path}: file name must be a lowercase-and-hyphens slug"
    end

    page = struct!(__MODULE__, [slug: slug, body: body] ++ Map.to_list(attrs))
    {body, charts} = Giggleton.Blog.Figures.inline(body, path)

    for key <- [:title, :description], not is_binary(Map.fetch!(page, key)) do
      raise ArgumentError, "#{path}: #{key} must be a string"
    end

    %{page | body: body, charts: charts}
  end
end
