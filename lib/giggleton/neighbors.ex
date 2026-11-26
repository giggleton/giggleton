defmodule Giggleton.Neighbors do
  @moduledoc """
  The village's neighbors: packages that work alongside the residents but haven't moved in, so
  they have no pattern or page of their own yet. Each is a box on the Residents page linking to
  its documentation.
  """

  @neighbors [
    %{
      id: "gig_ridges",
      description:
        "Ridgeline plots: each group's distribution drawn along its own baseline, the ridges " <>
          "overlapping. The first plugin, built on Giggly's layer API.",
      docs: "https://hexdocs.pm/gig_ridges"
    },
    %{
      id: "gig_typst",
      description:
        "Typst text and maths as labels: titles, axes, legends, annotations and facet strips, " <>
          "set by Typst and drawn into the plot.",
      docs: "https://hexdocs.pm/gig_typst"
    },
    %{
      id: "gig_datasets",
      description:
        "ggplot2's example datasets, and R's, as plain columns that Giggly, Explorer and Kino " <>
          "all read.",
      docs: "https://hexdocs.pm/gig_datasets"
    },
    %{
      id: "kino_giggly",
      description:
        "Draws Giggly plots in Livebook. Leave a plot as a cell's last value and it draws itself.",
      docs: "https://hexdocs.pm/kino_giggly"
    }
  ]

  @doc "Every neighbor, in the order the Residents page lists them."
  def all_neighbors, do: @neighbors
end
