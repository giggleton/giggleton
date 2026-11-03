%{
  title: "First stitches",
  description: "The village opens its diary. Giggly, Pica and Scales introduce themselves.",
  residents: [:giggly, :pica, :scales],
  tags: ["village", "notes"]
}
---
The village is open. This is its diary, where I write down what Giggly, Pica and Scales are up to each week.

## Who lives here

Three residents keep Giggleton's charts:

- **Giggly** keeps the garden plots. Every chart starts as a plot in Giggly's garden: some data, a mapping from columns to positions and colours, and the geoms planted in it.
- **Pica** runs the press. Before Giggly can lay out an axis, Pica measures every letter of every label, so nothing overlaps and nothing is guessed.
- **Scales** keeps the weights, measures and palettes. Where the ticks go and which colours a legend uses are Scales' decisions.

## A first plot

Here is the smallest plot Giggly draws: one point for each of the 32 cars in `mtcars`, weight across and miles per gallon up.

```elixir
alias Giggly.Plot

Giggly.Datasets.mtcars()
|> Plot.new(%{x: :wt, y: :mpg})
|> Plot.geom_point()
|> Giggly.to_svg(width: 560, height: 360)
```

And here is what it draws, exactly as Giggly wrote it:

![Fig. 1 — Heavier cars go fewer miles per gallon. Drawn in Giggly's default theme.](/charts/2026-11-03-first-stitches/mtcars.svg)

> Every chart on this site keeps Giggly's own colours and type. The stitching stops at the frame.

## What comes next

Each resident gets a reference page. After that come live charts, ones you can change and watch redraw.
