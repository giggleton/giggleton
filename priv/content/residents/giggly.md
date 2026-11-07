%{
  name: "Giggly",
  species: "hyena",
  vocation: "Keeps the village plots.",
  home: "The garden plots",
  thread: :brown,
  says: "Map it to a bed first, then we'll see how it grows.",
  install: ~s({:giggly, "~> 0.1"}),
  docs: "https://hexdocs.pm/giggly",
  source: "https://github.com/giggleton/giggly",
  order: 1
}
---
Giggly keeps the village plots: the `giggly` package, a grammar-of-graphics plotting
library for Elixir, modelled on R's ggplot2.

## What Giggly does

The plots are on the sunny side of the village, with a shed full of string and labels.
Bring Giggly a table of numbers and it gives back plot, laid out the way ggplot2 lays one
out:

- **Data** is anything that implements Table.Reader. 
- **A mapping** says which column goes along, which goes up and which picks the colour, like
  a seed packet assigned to a bed.
- **Layers** are planted one over another: points, lines, paths, areas, ribbons, bars,
  histograms, densities, boxplots, smooths and text.
- **Scales** train each mapping to the data: continuous, log, square root, reversed, dated and
  discrete, with ggplot2's hues, gradients, greys and other palettes.
- **Facets** fence the plot into panels, one for each value of a column, or a grid of two.
- **Themes** are ggplot2's own: gray, bw, classic, minimal, light, dark, linedraw and void.

Giggly draws SVG for a LiveBook, a LiveView or a static page like this one. Optionally Giggly
can ask his friend Pica to measure every label using the right font metrics. [Pica's page](/residents/pica)
shows a chart set that way.

## The API

`Giggly.Plot` builds a plot specification. Giggly uses that specification to calculate the attributes of the
plots elements and their layout, and then draw the plot. 

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
- `Giggly.to_svg/2` draws the plot. 
- `Giggly.Datasets` holds ggplot2's example datasets, like `mtcars`, `diamonds`, `economics`
  and `txhousing`.
