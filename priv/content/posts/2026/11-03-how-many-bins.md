%{
  title: "How many bins?",
  description: "Giggly's first live chart: a histogram you can rebin with a slider, redrawn on the server as you move it.",
  residents: [:giggly],
  tags: ["histograms", "live-charts"]
}
---
You can't build a charting library in Elixir without showing how it works with LiveView. For our example we picked the histogram as a nod to one of ggplot2's sillier quirks.
## Thirty bins

To draw a histogram, you need to somehow specify how the chart will split the data into bins. By default, ggplot2 uses 30 bins, but it immediately warns you that 30 is a dumb number to use for this purpose. Giggly uses that default too! But thanks to LiveView, quickly seeing how your data looks with different numbers of bins is a breeze.

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

The chart is a LiveView component inside the post. The slider updates the value of `bins`, Giggly draws the histogram again, and returns the new SVG. 

But wait, you say, this means you have to redraw the entire SVG when anything changes! What if I have 50,000 points on a scatter plot?

You don't have 50,000 points on a scatter plot. Get over yourself. Redrawing it will work fine.

That said, I too don't really care if I have 50,000 points or not, I want to figure out how to solve that problem. And I have some ideas, but Giggly doesn't do that yet.