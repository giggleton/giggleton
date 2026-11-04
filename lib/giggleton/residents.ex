defmodule Giggleton.Residents do
  @moduledoc """
  The village's residents, one per package: every file under `priv/content/residents`,
  compiled into this module in village order.

  A new package joins the village with a Markdown file here and a stitch pattern of the
  same name in `priv/patterns`.
  """

  alias Giggleton.Blog.NotFoundError
  alias Giggleton.Residents.Resident

  use NimblePublisher,
    build: Resident,
    from: "priv/content/residents/*.md",
    as: :residents,
    html_converter: Giggleton.Markdown,
    highlighters: [:makeup_elixir]

  for resident <- @residents, chart <- resident.charts do
    @external_resource chart
  end

  @residents Enum.sort_by(@residents, &{&1.order, &1.id})
  @ids Enum.map(@residents, & &1.id)

  @doc "Every resident, in village order."
  @spec all_residents() :: [Resident.t()]
  def all_residents, do: @residents

  @doc "Every resident's id, in village order: the names a post's `residents` may use."
  @spec ids() :: [atom()]
  def ids, do: @ids

  @doc """
  The resident with this id, given as an atom or as the string in their page's address.
  Raises `Giggleton.Blog.NotFoundError` if there is none.
  """
  @spec get_resident!(atom() | String.t()) :: Resident.t()
  def get_resident!(id) when is_atom(id), do: find(&(&1.id == id), id)
  def get_resident!(id) when is_binary(id), do: find(&(Atom.to_string(&1.id) == id), id)

  defp find(fun, id) do
    Enum.find(@residents, fun) || raise NotFoundError, "no resident #{inspect(id)}"
  end

  @doc "The residents either side of `resident` along the street, wrapping round at the ends."
  @spec neighbours(Resident.t()) :: {Resident.t(), Resident.t()}
  def neighbours(%Resident{id: id}) do
    index = Enum.find_index(@ids, &(&1 == id))
    count = length(@residents)

    {Enum.at(@residents, rem(index - 1 + count, count)),
     Enum.at(@residents, rem(index + 1, count))}
  end
end
