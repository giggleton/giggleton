defmodule Giggleton.Residents.Resident do
  @moduledoc """
  One resident of the village, built by NimblePublisher from `priv/content/residents/<id>.md`.

  The file name is the resident's id, the package's name: `scales.md` is `:scales`, at
  `/residents/scales`, drawn from `priv/patterns/scales.txt`. The front matter says who they are:

      %{
        name: "Scales",
        species: "chameleon",
        vocation: "Keeps the weights, measures and palettes.",
        home: "Weights & measures",
        thread: :green,
        says: "Nice breaks, those. Minor ones too, if you want them.",
        install: ~s({:scales, "~> 0.1"}),
        docs: "https://hexdocs.pm/scales",
        source: "https://github.com/giggleton/scales",
        order: 3
      }

  `vocation` is the fragment on their card; the full sentence opens the page as its lede.
  `home` is the short name of where they live, shown with the package on the card. `thread`
  is the colour their plate is stitched in. `docs` may be left out for a package not yet on
  Hex. `order` places them along the village street. Every key but `docs` is required, and
  a misspelt one fails the build.

  Charts in the body are inlined as in a post, by `Giggleton.Blog.Figures`.
  """

  @type t :: %__MODULE__{}

  @enforce_keys [
    :id,
    :name,
    :species,
    :vocation,
    :home,
    :thread,
    :says,
    :install,
    :source,
    :order,
    :body
  ]
  defstruct @enforce_keys ++ [docs: nil, charts: []]

  @threads [:red, :blue, :green, :gold, :brown]

  @doc false
  def build(path, attrs, body) do
    id = Path.basename(path, ".md")

    check!(path, id =~ ~r/\A[a-z][a-z0-9_]*\z/, "file name must be the package name")

    resident = struct!(__MODULE__, [id: String.to_atom(id), body: body] ++ Map.to_list(attrs))
    {body, charts} = Giggleton.Blog.Figures.inline(body, path)
    resident = %{resident | body: body, charts: charts}

    for key <- [:name, :species, :vocation, :home, :says, :install, :source] do
      check!(path, is_binary(Map.fetch!(resident, key)), "#{key} must be a string")
    end

    check!(path, is_nil(resident.docs) or is_binary(resident.docs), "docs must be a string")
    check!(path, resident.thread in @threads, "thread must be one of #{inspect(@threads)}")
    check!(path, is_integer(resident.order), "order must be an integer")

    resident
  end

  defp check!(_path, true, _message), do: :ok
  defp check!(path, false, message), do: raise(ArgumentError, "#{path}: #{message}")
end
