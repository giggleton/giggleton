%{
  title: "A notebook for every page",
  description: "How we followed ggplot2's reference page by page in Livebook, checked each drawing against R's, and decided which differences to live with.",
  residents: [:giggly],
  tags: ["notebooks", "ggplot2", "testing"]
}
---
When you set out to port ggplot2, you need some way to know how far along you are. ggplot2 already has one: its reference site has a page for every function, and nearly every page ends in examples. So we gave each of those pages a Livebook notebook of its own. There are 141 of them now, plus an index laid out like ggplot2's.

## One page, one notebook

The rules are simple. A notebook takes every example on its page, in the page's order. Each example starts with ggplot2's code, copied verbatim, comments and all. Giggly's version comes next if Giggly can draw it. If it can't, the R code stays put and a line says what it's waiting for:

```r
p + geom_label(aes(fill = factor(cyl)), colour = "white", fontface = "bold")
```

> Not in Giggly yet: a fixed `fontface`.

That line is always worded the same way, in every notebook. So when a feature lands, one search finds every example that was waiting for it. We draw those, and the notebooks double as Giggly's to-do list, written by ggplot2's own docs. On 16 October, 619 examples were waiting. Today 509 are drawn, 266 are waiting, and 43 notebooks have nothing left to wait for.

We also learned not to cheat. Some examples call `qplot()`, ggplot2's old shortcut. Others compute a column first, such as `cut_width(carat, 0.25)`. You can often fake those with a few lines of Elixir, but a faked plot isn't Giggly drawing ggplot2's example, so those examples wait too.

## Drawn means checked

The notebooks never show ggplot2's drawings, only Giggly's. They're documentation first, and two near-identical charts on every page would just be clutter. The checking happens in review. Before an example counts as drawn, ggplot2 draws the same plot in Docker, through vdiffr's copy of svglite, which measures text with the same glyph table Giggly uses. Then we compare the two files element by element. Giggly's test suite keeps 371 of those comparisons as golden SVGs, each with the R script that checks it.

Here's the first example from the `geom_point()` page, drawn both ways:

```elixir
Giggly.Datasets.mtcars()
|> Plot.new(%{x: :wt, y: :mpg})
|> Plot.geom_point()
```

![Fig. 1 — ggplot(mtcars, aes(wt, mpg)) + geom_point(), drawn by ggplot2](/charts/2026-11-04-a-notebook-for-every-page/point-ggplot2.svg)
![Fig. 2 — The same plot, drawn by Giggly](/charts/2026-11-04-a-notebook-for-every-page/point-giggly.svg)

Every rectangle, grid line, point and label sits at the same coordinates, to the hundredth of a point. The two files differ only in order: Giggly writes the x axis before the y axis, as ggplot2 itself does once a plot has facets. If the labels look a shade different, that's the browser. ggplot2's SVG names a font and lets your machine pick one, while Giggly draws the letters as outlines.

## A departure we kept

Some differences we chose. The biggest is loess, the local regression `geom_smooth()` fits when a group has fewer than 1,000 rows. R's default doesn't fit a regression at every point on the curve. It divides the data into cells, fits at the cells' corners, and joins those fits with cubic pieces, and the rule for cutting the cells is only written down in R's Fortran. Matching it would have meant porting that Fortran. Giggly fits at each point of the curve directly instead, as R does when you ask for `loess(surface = "direct")`.

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

We kept it, and we wrote it down. The notebook says how far the curve sits from R's at every loess example, measured on the notebook's own drawing. Giggly's golden for loess is drawn by R in direct mode, so the check is still exact. It's just exact against the method we chose.

The other departures follow the same pattern:

- **Jitter.** Jittered points take their distances from Erlang's random numbers, so they land in different places than R's, within the same distance of where they started.
- **Bootstrap intervals.** These are drawn from a seed. ggplot2's examples set none, so R's ends move on every run anyway. The notebook says how far they wander, measured over 500 seeds.
- **Colour names.** These mean what they mean in CSS, so `"green"` is `#008000` where R's is a brighter `#00FF00`.

Each is stated in the notebook's prose, with how far it goes. A difference with nothing written beside it is a bug.

## Try them

The notebooks live in [Giggly's repository](https://github.com/giggleton/giggly), under `notebooks/`. Open `index.livemd` in Livebook and follow it the way you'd follow ggplot2's reference. For now they install Giggly from the checkout, so clone the repository first.
