%{
  name: "Giggly",
  species: "hyena",
  vocation: "Keeps the village garden plots.",
  home: "The garden plots",
  thread: :brown,
  says: "Map it to a bed first, then we'll see how it grows.",
  install: ~s({:giggly, github: "giggleton/giggly"}),
  source: "https://github.com/giggleton/giggly",
  order: 1
}
---
Giggly keeps the village garden plots: the `giggly` package, a grammar-of-graphics plotting
library for Elixir, modelled on R's ggplot2.

## What Giggly does

The garden plots are on the sunny side of the village, with a shed full of string and labels.
Bring Giggly a table of numbers and it comes back as a plot, laid out the way ggplot2 lays one
out:

- **Data** is any table: a list of maps, a map of columns or an Explorer data frame.
- **A mapping** says which column goes along, which goes up and which picks the colour, like
  a seed packet assigned to a bed.
- **Layers** are planted one over another: points, lines, paths, areas, ribbons, bars,
  histograms, densities, boxplots, smooths and text.
- **Scales** train each mapping to the data: continuous, log, square root, reversed, dated and
  discrete, with ggplot2's hues, gradients, greys and viridis.
- **Facets** fence the plot into panels, one for each value of a column, or a grid of two.
- **Themes** are ggplot2's own: gray, bw, classic, minimal, light, dark, linedraw and void.

Giggly draws SVG, for a LiveView, a Livebook or a static page like this one. When Pica is in
the project, Giggly drops by the press for the width of every label, so the text sits where
the font puts it.

## The API

A plot is a value built with a pipe. `Giggly.Plot` describes it and draws nothing; the
functions in `Giggly` run it.

```elixir
alias Giggly.Plot

Giggly.Datasets.mpg()
|> Plot.new(%{x: :displ, y: :hwy})
|> Plot.geom_point(%{color: :drv})
|> Plot.geom_smooth(method: :lm)
|> Plot.facet_wrap(:year)
|> Plot.labs(
  x: "Engine displacement (litres)",
  y: "Highway miles per gallon",
  color: "Drive"
)
|> Giggly.to_svg(width: 480, height: 320)
```

![Fig. 1 — Bigger engines go fewer highway miles, in 1999 and 2008 alike. Drawn by the code above, in Giggly's default theme.](/charts/giggly/garden.svg)

- `Giggly.Plot.new/2` takes the data and the plot's mapping.
- `geom_*` and `stat_*` add layers; `scale_*`, `lims/2` and `guides/2` set the scales and
  legends; `facet_wrap/3` and `facet_grid/3` split the panels; `labs/2` names things; and
  `theme_*` and `theme/2` dress the plot.
- `Giggly.to_svg/2` draws the plot. `Giggly.layer_data/2` shows the table a layer computes,
  and `Giggly.panel_scales/2` the scales a panel is drawn on, which is how a plot is checked
  against ggplot2's.
- `Giggly.Datasets` holds ggplot2's example tables: `mtcars`, `mpg`, `diamonds`, `economics`
  and `txhousing`.

Giggly isn't on Hex yet. Take it from GitHub, pinned to a commit with `ref:`.
