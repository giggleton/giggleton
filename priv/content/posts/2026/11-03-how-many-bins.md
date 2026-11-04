%{
  title: "How many bins?",
  description: "Giggly's first live chart: a histogram you can rebin with a slider, redrawn on the server as you move it.",
  residents: [:giggly],
  tags: ["histograms", "live-charts"]
}
---
Giggly has drawn its first live chart: a histogram you can rebin. Move the slider and Giggly redraws it on the server, then the page swaps the new drawing in.

## Thirty bins

A histogram cuts an axis into bins and counts the rows that fall in each. ggplot2 cuts it into 30 unless told otherwise, and grumbles about it every time, because 30 is rarely right. Giggly starts at 30 too.

```elixir
alias Giggly.Plot

Giggly.Datasets.mpg()
|> Plot.new(%{x: :hwy})
|> Plot.geom_histogram(bins: bins)
|> Plot.labs(x: "Highway miles per gallon", y: "Cars")
|> Giggly.to_svg(width: 560, height: 320)
```

<!-- demo: Bins -->

These are the 234 cars in ggplot2's `mpg` table, by highway miles per gallon. At three bins there's no shape to speak of: a short bar, a tall one and a sliver. Around a dozen, two humps show: one near 17 miles per gallon, nearly all SUVs and pickups, and one near 26 for the compacts, midsizes and subcompacts.

Past about thirty the bins get narrower than a mile per gallon. The table records mileage in whole miles per gallon, so from there on the chart is a count of each whole number, gaps and all.

## How it works

The chart is a LiveView component inside the post. The slider sends the bin count over the page's socket, Giggly draws the histogram again, and the new SVG comes back over the same socket. Without a connection, the chart stays at thirty bins.
