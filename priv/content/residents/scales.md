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
---
Scales keeps the village's weights, measures and palettes: the `scales` package, R's scales
for Elixir, giving the answers R's scales 1.4.0 gives, to the last digit.

## What Scales does

The Weights & Measures House is stone-built, by the market cross. Everything a chart's scales
are made from is kept there, and checked against R's:

- **Breaks** are where the marks go on every ruler, with minor marks between them.
- **Labels** are how each mark is written: as a number, with commas, as a percentage or a
  currency, in scientific notation, as bytes or as a date.
- **Transforms** turn one unit into another: logs, square roots, reversals, dates and times,
  each with its own breaks.
- **Bounds** rescale values into a range and decide what happens to those past its edge.
- **Palettes** are a cabinet of dyed threads: from a place along a range, or a count of
  levels, to colours that go together.

Scales works on plain values and belongs to no charting tool. Any chart can call at the
House, and so can anything else that needs a nice ruler.

## The API

Each module holds one of R's families, and each function is R's name without the family's
prefix: R's `breaks_extended()` is `Scales.Breaks.extended/2`. Here are the steps a chart
takes for a colour scale:

```elixir
alias Scales.{Bounds, Breaks, DataRange, Labels, Palette}

values = [12.0, 31.5, 18.25, nil]

range = DataRange.train_continuous(:none, values)
#=> {12.0, 31.5}

breaks = Breaks.extended(range)
#=> [10.0, 15.0, 20.0, 25.0, 30.0]

Labels.comma(breaks, suffix: " km")
#=> ["10 km", "15 km", "20 km", "25 km", "30 km"]

places = Bounds.rescale(values, range, {0, 1})
gradient = {:gradient, ["#132B43", "#56B1F7"]}
Palette.continuous(gradient, places)
#=> ["#132B43", "#56B1F7", "#275278", nil]
```

| Module | What it keeps | R's family |
| --- | --- | --- |
| `Scales.Breaks` | where an axis's breaks go | `breaks_*` |
| `Scales.MinorBreaks` | minor breaks between them | `minor_breaks_*` |
| `Scales.Labels` | labels for breaks | `label_*`, `cut_*` |
| `Scales.Transform` | transformations, with their breaks and labels | `transform_*` |
| `Scales.Palette` | palettes | `pal_*`, `palette_*` |
| `Scales.Bounds` | rescaling and out-of-range values | `rescale*`, `oob_*` |
| `Scales.DataRange` | the range of the data a scale has seen | `train_*` |
| `Scales.ColorOperations` | colours, as R's palettes make them | `col_*` |

A range is `{low, high}`, `nil` is R's `NA`, and a colour is uppercase `#RRGGBB`. Where Scales
departs from R, its documentation says how and why.
