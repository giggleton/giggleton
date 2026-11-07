%{
  title: "First stitches",
  description: "The village opens its diary. Giggly, Pica and Scales introduce themselves.",
  residents: [:giggly, :pica, :scales],
  tags: ["village", "notes"]
}
---
Welcome to Giggleton, a charming village of friendly folks that help us visualize data. Giggleton started from my fascination with the grammar of graphics and ggplot2, the powerful data visualizaton library for the R language. Over the past several years I worked on an Elixir clone, "GGity," that I built by hand to get a feel for how chart libraries work.

Enter LLMs, and it occurred to me that cloning ggplot2 for Elixir and making powerful grammar of graphics visualization tools written in Elixir available was a goal that was now very much in reach. Whereas I felt I had reached the limits of what I could do without plowing the depths of R as a programming language or the underlying statistical methods that underlie some of its drawings, now I could apply my ideas about how to design those features in Elixir and have the LLM build the same plots in R as fixtures, write the code to do the same thing in Elixir and still learn along the way.

And so Giggly was born. But soon it became clear that Giggly needed friends to help him, and while ggplot2 has the tidyverse, I have no such delusions of grandeur. Giggly and his friends live in Giggleton, a friendly little village that Elixir developers can visit to build great data visualizations.

This site is a blog where I will write about what Giggly and his friends do and how they work, and what I have done or learned along the way. It's basically a journal, both informative and adorable.

## Meet the townsfolk

- **Giggly** keeps the plots. Every chart starts as a plot in Giggly's garden: some data, a mapping from columns to positions and colours, and the geoms planted in it.
- **Pica** runs the printing press. Before Giggly lays out the plot, Pica measures every letter of every label, so everything looks neat and tidy. 
- **Scales** keeps the weights, measures and palettes. Where the ticks go and which colours a legend uses are Scales' work.

## A first plot

Here is the simplest plot Giggly draws: one point for each of the 32 cars in the `mtcars` dataset, weight across and miles per gallon up.

```elixir
alias Giggly.Plot

Giggly.Datasets.mtcars()
|> Plot.new(%{x: :wt, y: :mpg})
|> Plot.geom_point()
|> Giggly.to_svg(width: 560, height: 360)
```

![Fig. 1 — Heavier cars go fewer miles per gallon. Drawn in Giggly's default theme.](/charts/2026-11-03-first-stitches/mtcars.svg)

Like GGity, one of Giggly's key design goals is for someone who is familiar with ggplot2 and Elixir to be able to build plots without much if any reference to the documentation - if you know ggplot2 and idiomatic Elixir, Giggly should feel obvious to you.

In our next post, we'll do the obligatory LiveView example.