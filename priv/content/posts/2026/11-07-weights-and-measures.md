%{
  title: "Scales are the hard part",
  description: "Scales gets a turn in the diary: why scales are the heart of a chart, and why they live in a package of their own.",
  residents: [:scales, :giggly],
  tags: ["scales", "color", "packages"]
}
---
So anyone working in R has heard of ggplot2. But what about the scales package? That's where the real work is done.

## A chart is a pile of scales

Strip a chart down and there isn't much left. You have some numbers, and you have marks on a page: a dot here, a bar that tall, a line that color. Everything in between is a scale. A scale is what turns your data into something useful for visualization - it takes a value and decides what it looks like: how far along the x axis it sits, how high it goes, how big its dot is, what color it gets. It also has to do the inverse transformation, telling the reader with ticks, labels and legends how to read the marks as numbers again.

At some level, all Giggly does is ask you which scales to apply to what data, and how you want the results presented.

## Harder than it looks

Every part of a scale looks like something you could write in an afternoon. Take a range, rescale it to 0–1, multiply by the panel's width. Done! Maybe that's why there aren't books and weekly contests featuring R's scales package.

There's so much more to it.

- **Breaks.** Where do the tick marks go? R uses the extended Wilkinson algorithm (Talbot, Lin and Hanrahan, 2010). It searches over candidate sequences and scores each for simplicity (steps of 1, 5, 2, 2.5, 4, 3 times a power of ten), coverage, and how close it gets to the number of ticks you asked for. When I was writing GGity by hand, I just flat out stole the (simplified) version of this code from Contex; it was complicated. 
- **Labels.** Once you know where the ticks go, you have to write them down: commas, percentages, currencies, scientific notation, bytes, dates, and enough digits that no two neighbouring ticks read the same. The biggest file in Scales isn't the color maths. It's `labels.ex`, at about 2,400 lines.
- **Transforms.** A log scale isn't just `:math.log10/1`. It needs its own breaks (1, 10, 100, not 0, 2,000, 4,000), its own minor breaks, and a plan for zero and negative numbers. Dates are worse, because months don't have the same number of days.
- **Out of bounds.** When a value falls outside the scale's limits, do you drop it, squish it to the edge, or keep it and let it hang off the panel? ggplot2 has an answer for each, and they are all slightly different.

## From a number to a color

Color is where it gets properly hard, because a color scale is the one scale that has to translate a straight line of numbers into something human eyes perceive. What does that even mean?

Say you want a gradient from blue to yellow. Your low values are `#0000FF`, your highs are `#FFFF00`, and a value halfway along gets... what? The obvious answer is to go halfway on each of red, green and blue: `#808080`.

That's grey. D'ohh.

Enter color spaces, which (my words) each represent a way to transform numbers into colors and back. The one most of us know (at least indirectly) is the RGB color space. Apparently that was not good enough, so we have approximately one gajillion alternative color spaces to choose from. Thankfully, when you have a very deep, complex set of specifications for a thing, and there isn't an Elixir package to manage them, Kip Cole steps in and writes a crazy complete library for you. Scales uses his [Color](https://hexdocs.pm/color) package, and I'm very glad it does so because heaven knows what Claude would have written without it.

RGB is not great for data visualization, because it is a description of how much light each part of the screen gives off, as opposed to how we perceive differences in color. Equal steps in RGB aren't equal steps to the eye. So R's scales doesn't blend in RGB. It converts each color to CIE L\*a\*b\* (Lab for short), a color space designed so that equal distances look roughly equally different, and so that lightness (L\*) has an axis of its own. It blends there and converts back. Scales does the same:

```elixir
alias Scales.Palette

gradient = {:gradient, ["#0000FF", "#FFFF00"]}
Palette.continuous(gradient, [0.0, 0.5, 1.0])
#=> ["#0000FF", "#CA8AAA", "#FFFF00"]
```

![Fig. 3 — Blue to yellow, blended two ways](/charts/2026-11-07-weights-and-measures/strips.svg)

The RGB strip sits dark for a long stretch, sags into grey and then rushes up to yellow at the end. The Lab strip gets lighter at a steady pace the whole way. Plot the lightness of each step and you can see it:

![Fig. 4 — How light each step is: the RGB blend stalls, then sprints](/charts/2026-11-07-weights-and-measures/lightness.svg)

That matters, because lightness is most of what a reader uses to read a color scale as "more" or "less". If lightness stalls for the first third of the gradient, so does the reader.

Lab isn't magic, though. Look at the middle of the Lab strip: the straight line from blue to yellow passes through a dusty pink. Even lightness is good. A pink nobody asked for is less good. So the best continuous palettes aren't two colors and a blend. They're designed one step at a time in a perceptual color space. Viridis is the famous one. Its lightness climbs evenly from dark purple to yellow, it survives being printed in greyscale, and it reads the same for the most common kinds of color blindness. Scales carries viridis and its siblings (magma, inferno, plasma, cividis and the rest) from viridisLite's own tables, so Giggly can draw ggplot2's default gradient or viridis with one line:

```elixir
faithful =
  GigDatasets.faithfuld()
  |> Plot.new(%{x: :waiting, y: :eruptions, fill: :density})
  |> Plot.geom_raster()

faithful
faithful |> Plot.scale_fill_viridis_c()
```

![Fig. 5 — Old Faithful in ggplot2's default gradient](/charts/2026-11-07-weights-and-measures/faithful-default.svg)
![Fig. 6 — The same, in viridis](/charts/2026-11-07-weights-and-measures/faithful-viridis.svg)

Discrete colors are a different problem with a similar answer. ggplot2's default palette, the salmon, green, teal and purple everyone recognizes, comes from walking evenly around the hue wheel in HCL (hue-chroma-luminance), another perceptual space. That way no category looks brighter or more important than another. Four groups get:

```elixir
Palette.discrete(Palette.named("hue"), 4)
#=> ["#F8766D", "#7CAE00", "#00BFC4", "#C77CFF"]
```

As you can imagine, getting Scales to match the R package for these transformation to the 200th digit or whatever was Claude's favorite thing ever.

## A package of its own

ggplot2 split its scales out into their own package, `scales`, over a decade ago. We've done the same.

Scales started inside Giggly, and once it covered everything R's scales 1.4.0 exports (213 functions, each built, replaced by something newer, or deliberately left out), we lifted it into a [package of its own](https://github.com/giggleton/scales). It depends on nothing in Giggly. It's plain functions of plain values, with no processes, no config and no state:

```elixir
alias Scales.{Breaks, DataRange, Labels}

values = [12.0, 31.5, 18.25, nil]
range = DataRange.train_continuous(:none, values)
#=> {12.0, 31.5}

Breaks.extended(range)
#=> [10.0, 15.0, 20.0, 25.0, 30.0]

Labels.comma([10.0, 15.0, 20.0], suffix: " km")
#=> ["10 km", "15 km", "20 km"]
```

The design basis for extracting it is obvious, but really I just know that, if you're writing a charting library in Elixir, or a sparkline component, or a dashboard that needs a sensible y axis, the scales are the part that takes longest to get right and is least fun to do. You shouldn't have to redo that work just to start. Take the nice breaks, the labels and the palettes from Scales, and do your cool stuff instead. 

Scales is on [Hex](https://hex.pm/packages/scales), with its documentation at [hexdocs](https://hexdocs.pm/scales). Where it departs from R, the documentation says how and why.
