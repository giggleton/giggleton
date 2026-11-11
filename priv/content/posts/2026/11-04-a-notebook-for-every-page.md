%{
  title: "A notebook for every page",
  description: "How we followed ggplot2's reference page by page in Livebook, checked each drawing against R's, and decided which differences to live with.",
  residents: [:giggly],
  tags: ["notebooks", "ggplot2", "testing"]
}
---
When you set out to port ggplot2, you need a way to easily mark progress and prove you are getting it right. Luckily, we have the ggplot2 reference site, which has a page for every function, and at least one example on nearly every page. From there it's easy to make Livebooks for each page and fill them in as we go. There are 141 of them as of this writing.

Each Liveboook includes ggplot2's code. Giggly's version comes next if Giggly can draw it. If it can't, we note what's missing so we can track what's left to do and how many examples a particular function will let us draw. 

```r
p + geom_label(
  aes(fill = factor(cyl)),
  colour = "white",
  fontface = "bold"
)
```

> Not in Giggly yet: a fixed `fontface`.

That line is always worded the same way, so when a feature lands, we can find the examples it will enable. We draw those, and the notebooks double as Giggly's to-do list. On October 16, 2026, 619 examples were waiting. 

## Drawn means checked

The notebooks never show ggplot2's drawings, only Giggly's. They're documentation first, and two near-identical charts on every page would just be clutter. The checking happens in review. Before an example counts as drawn, ggplot2 draws the same plot in Docker, through vdiffr's copy of svglite, which measures text with the same glyph table Giggly uses. Then we compare the two files element by element. As of this writing, Giggly's test suite had 371 (holy cow, that's a lot) of those comparisons as golden SVGs, each with the R script that checks it.

Here's the first example from the `geom_point()` page, drawn both ways:

```elixir
Giggly.Datasets.mtcars()
|> Plot.new(%{x: :wt, y: :mpg})
|> Plot.geom_point()
```

![Fig. 1 — ggplot(mtcars, aes(wt, mpg)) + geom_point(), drawn by ggplot2](/charts/2026-11-04-a-notebook-for-every-page/point-ggplot2.svg)
![Fig. 2 — The same plot, drawn by Giggly](/charts/2026-11-04-a-notebook-for-every-page/point-giggly.svg)

Every rectangle, grid line, point and label sits at the same coordinates, to the hundredth of a point. This is one downside of this comparison process - Claude loves having a very specific bar to clear. I am pretty sure we have implemented specialized forms of floating point arithmetic just to match to the hundredth of a point, which seems silly.

And as I am very, very frequently reminded, even after all that, the two files differ in one meaningless respect: Giggly writes the x axis before the y axis, as ggplot2 itself does once a plot has facets. Also (and more interestingly), if the labels look a shade different, that's the browser. ggplot2's SVG names a font and lets your machine pick one, while Giggly draws the letters as outlines.

## Differences we accept 

We did actually accept some. For the most part, if under some edge case R draws something weird, we match the behavior. In other cases, where R just doesn't draw something on a bad input, we raise. 

Another example is loess, the local regression `geom_smooth()` fits when a group has fewer than 1,000 rows. R's default doesn't fit a regression at every point on the curve. It divides the data into cells, fits at the cells' corners, and joins those fits with cubic pieces, the code for which is in a Fortran library.

Frickin' Fortran! I draw the line at Fortran. 

Giggly fits at each point of the curve directly instead, as R does when you ask for `loess(surface = "direct")`.

Most of the time you can't tell. On the page's first smooth, Giggly's curve is never more than 1.7 points from R's, as the notebook draws it. Shrink the span, though, and R's cells shrink too:

```elixir
Giggly.Datasets.mpg()
|> Plot.new(%{x: :displ, y: :hwy})
|> Plot.geom_point()
|> Plot.geom_smooth(span: 0.3)
```

![Fig. 3 — geom_smooth(span = 0.3), drawn by ggplot2](/charts/2026-11-04-a-notebook-for-every-page/smooth-ggplot2.svg)
![Fig. 4 — The same plot, drawn by Giggly](/charts/2026-11-04-a-notebook-for-every-page/smooth-giggly.svg)

Look around the 2-litre engines. Giggly fits right at each point, so its curve dips with the handful of thirsty cars there. R only fits at its cells' corners, and its cubic pieces sweep past the dip. At this size Giggly's curve is up to 9.7 points from R's, and its band's edges up to 12. Everything else in the two drawings still matches, points and axes included.

Other departures (not an exhaustive list):

- **Jitter.** Jittered points take their distances from Erlang's random numbers, so they land in different places than R's, within the same distance of where they started.
- **Bootstrap intervals.** These are drawn from a seed. ggplot2's examples set none, so R's ends move on every run anyway.
- **Colour names.** In Giggly these mean what they mean in CSS, so `"green"` is `#008000` where R's is a brighter `#00FF00`.

We note the departures in the Livebooks. Ideally we'll write a separate guide that lists all of them in one place for easy reference.

## Try them

The notebooks live in [Giggly's repository](https://github.com/giggleton/giggly), under `notebooks/`. Open `index.livemd` in Livebook and follow it the way you'd follow ggplot2's reference. For now they install Giggly from the checkout, so clone the repository first.
