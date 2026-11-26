%{
  title: "Measure twice, draw once",
  description: "Pica gets her turn in the diary: why a charting library has to measure every letter before it draws a thing.",
  residents: [:pica, :giggly],
  tags: ["text", "fonts", "packages"]
}
---
One of the most intimidating things about plotting libraries for me was not drawing lines and shapes - it was font metrics. Drawing words. We can't lay out the plot correctly without knowing exactly how much room every label is going to take, and the only way to know that is to measure every letter. That's Pica's job.

Pica wraps Rust libraries that do this for us. That's a little heavy, so it is optional. Base Giggly makes some assumptions that should work ok most of the time, as many other charting packages do.

## The labels go first

Here are the 234 cars in ggplot2's `mpg` table, counted by class, drawn twice. The only difference between the two is one line, `Plot.scale_y_discrete(labels: names)`, which spells the class names out:

![Fig. 1 — mpg's own class names](/charts/2026-11-11-measure-twice/short.svg)
![Fig. 2 — The same counts, the names spelled out](/charts/2026-11-11-measure-twice/long.svg)

Same data, same size, and the panel in Fig. 2 is a lot narrower. The axis labels sit to the left of the panel, so the panel starts wherever the widest label ends. Same goes for the axis titles, the plot's title, the legend and its keys: every one of them takes its room first, and the data gets what's left.

So every label gets measured before anything is drawn, and it has to be measured right. Guess too narrow and the label runs into the panel or off the edge of the drawing. Guess too wide and you throw away room the data could have used.

## Borrowing ggplot2's ruler

ggplot2 checks its drawings against SVG snapshots, and the tool that writes those snapshots measures every string with Liberation Sans, which has the same widths as Arial and Helvetica. Add up each character's width, done.

Giggly ships a copy of that table, which is a big part of how it can match ggplot2's drawings to the hundredth of a point, as I wrote about in [A notebook for every page](/posts/a-notebook-for-every-page). This is what Giggly does if you don't install Pica.

Of course, this only works if the reader's browser draws the chart in Liberation Sans, Arial or Helvetica. Pick another font in your theme and the browser draws your font at Liberation's widths. [Pica's page](/residents/pica) has an example where a title set in Lobster gets stretched by about 16% to fill the room Liberation Sans would have taken. It is not a good look.

## Letters aren't Lego

So measure the real font instead. A font file has a width for every letter, so add those up, right?

Wrong! Fonts are much smarter (and much more complicated) than a table of widths:

- **Kerning.** Some pairs of letters get pulled closer together than their widths say, so the "V" tucks in under the arm of the "A". In Source Serif 4 the "A" in "AV" moves the pen on 545 units instead of its own 664.
- **Ligatures.** Some runs of letters get swapped for a single glyph. "office" is six letters, but Source Serif 4 draws it as four glyphs, because "ffi" is one.
- **Contextual forms.** Some fonts swap letters for different versions depending on their neighbors. Lobster, a script font, does this all over the place, which is how "Type" comes out as three glyphs.

The process of turning a string into the right glyphs at the right positions is called shaping, and Pica does it:

```elixir
{:ok, font} =
  "SourceSerif4-Regular.otf.woff2"
  |> File.read!()
  |> Pica.load()

font
|> Pica.shape("AV")
|> Enum.map(fn glyph ->
  {glyph.x_advance, glyph.nominal_advance}
end)
#=> [{545, 664}, {674, 674}]
```

Each glyph comes back with how far it actually moves the pen (`x_advance`) and how far it would on its own (`nominal_advance`). Here's how much narrower some words get once they're shaped, compared to adding up their letters one at a time:

![Fig. 3 — Shaping takes almost 10% off "AVATAR", and almost nothing off "Miles per gallon". Measured in Source Serif 4.](/charts/2026-11-11-measure-twice/kerning.svg)

For a typical axis title like "Miles per gallon", shaping only changes things by a fraction of a percent. Words in all caps are where kerning really matters.

## Why not just write it in Elixir?

Because I'm not an idiot.

We did look. Before writing a line of Pica, Claude surveyed what was on Hex. Some packages only read the old `kern` table, which doesn't help much because Google's fonts keep their kerning somewhere else (the `GPOS` table, if you're keeping score). One reads `GPOS` but misses enough of it that it found none of Lato's kerning at all. The one package that did wrap HarfBuzz (more on that in a second) ran a process for every font and couldn't tell you a font's metrics. And measuring by rendering the text to an image and looking at it doesn't work either, because the ink of a letter isn't the same as the room it takes up.

The library that does all of this right is HarfBuzz. It shapes the text in Chrome, Firefox and Android, and more to the point for us, it's what R's svglite uses to measure text. HarfBuzz has an official Rust port, harfrust, so Pica is a thin Elixir layer over harfrust, in a Rust NIF.

Readers of the notebook post know I draw the line at Fortran. Rust, it turns out, is on my side of the line. Pica ships prebuilt binaries, so you don't need a Rust toolchain to use it. Thank heavens for [rustler_precompiled](https://hexdocs.pm/rustler_precompiled)!

And because svglite uses HarfBuzz too, Giggly can match R's widths with Pica the same way it matches them with the Liberation Sans table. Across sizes from 5 to 30 points in Lato and Source Serif 4, Giggly's widths come within 4/64 of a point of svglite's. Yes, Claude checked. Yes, Claude loved it.

## Measuring, not drawing

Pica measures, but she doesn't draw anything. She hands the measurements back to whoever asked, usually Giggly, and Giggly lays out the chart around them. Pica can also hand over each glyph's outline, so by default Giggly draws a label as the font's actual letter shapes instead of text that names a font. That means a chart looks the same everywhere, whether or not the reader has the font installed.

She also never guesses. If you ask for a font she doesn't have, she raises.

Like Scales, Pica is a package of her own, and for the same reason: measuring text is useful for a lot more than charts. PDF writers, image generators, anything that has to know how wide a string is before it puts it somewhere. Giggly lists Pica as an optional dependency, so nobody has to download a NIF just to draw a bar chart for their dashboard.

Pica is on [Hex](https://hex.pm/packages/pica), with its documentation at [hexdocs](https://hexdocs.pm/pica).
