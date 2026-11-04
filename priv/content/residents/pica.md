%{
  name: "Pica",
  species: "magpie",
  vocation: "Runs the press and measures every letter.",
  home: "The press",
  thread: :blue,
  says: "Twelve points to the pica. Don't guess the width, I'll measure it.",
  install: ~s({:pica, "~> 0.1"}),
  docs: "https://hexdocs.pm/pica",
  source: "https://github.com/giggleton/pica",
  order: 2
}
---
Pica runs the village press and measures every letter: the `pica` package, text shaping and
font metrics for Elixir, through HarfBuzz's Rust port.

## What Pica does

The press is a narrow shop on the square, with type cases up to the ceiling. Hand Pica a font
and a line of text and she says exactly how it sets: which glyph draws each letter, how far
each one moves the pen on, where kerning pulls a pair together, and when two letters tie into
a ligature. She also reports a font's own metrics, the box around each glyph and each glyph's
outline as drawing commands.

Pica measures everything and prints nothing. She hands the measured line to whoever is
drawing, which is usually Giggly, setting an axis label.

She never guesses, either. A family name matches exactly or not at all, an italic is never
stood in for by an upright, and a letter the font lacks comes back as glyph 0, the font's
`.notdef`, never borrowed from another font.

## The API

```elixir
bytes = File.read!("Lato-Regular.ttf")
{:ok, font} = Pica.load(bytes)

for glyph <- Pica.shape(font, "AV") do
  {glyph.x_advance, glyph.nominal_advance}
end
#=> [{1246, 1354}, {1354, 1354}]
```

Each glyph comes back as a `Pica.Glyph`. Kerning tucks the "V" under the "A", so the "A"
advances 108 units less than the font stores.

- `Pica.load/2` reads a font from its bytes: TrueType, OpenType, a font collection, WOFF or
  WOFF2. `Pica.info/1` reports what the font says about itself.
- `Pica.register/2` files fonts as a family's faces, plain, bold, italic and bold italic, and
  `Pica.lookup/3` finds a face by family name, among the registered fonts first and then the
  ones installed on the machine. Register once, when the application starts.
- `Pica.shape/3` shapes text into positioned `Pica.Glyph`s, with OpenType features turned on
  or off and an optional `:scale`.
- `Pica.glyph_ids/2`, `Pica.nominal_advances/2`, `Pica.glyph_boxes/2` and
  `Pica.glyph_outlines/2` read single glyphs, before shaping.

Every length is in font units, `units_per_em` to the em, unless shaping is given a scale. Pica
comes with precompiled binaries, so a project using it needs no Rust.

## Setting a chart in another face

Giggly measures a chart's text as Liberation Sans unless Pica holds a font for it. Register a
font with Pica under a family name and name that family in Giggly's theme: Pica measures every
label in it, and Giggly draws each label as the font's own glyph outlines.

```elixir
alias Giggly.Plot

load = fn path -> Pica.load(File.read!(path)) end
{:ok, serif} = load.("SourceSerif4-Regular.otf.woff2")
{:ok, lobster} = load.("Lobster-Regular.ttf")
:ok = Pica.register("Source Serif 4", plain: serif)
:ok = Pica.register("Lobster", plain: lobster)

Giggly.Datasets.mtcars()
|> Plot.new(%{x: :wt, y: :mpg})
|> Plot.geom_point()
|> Plot.labs(
  title: "Heavier cars, thirstier engines",
  x: "Weight (1,000 lb)",
  y: "Miles per gallon"
)
|> Plot.theme_gray(
  base_family: "Source Serif 4",
  header_family: "Lobster"
)
|> Giggly.to_svg(
  width: 480,
  height: 320,
  installed_fonts: false
)
```

![Fig. 1 — The same cars as Giggly's first plot, with the tick labels set in Source Serif 4 and the titles in Lobster. Drawn by the code above.](/charts/pica/press.svg)

The layout is built for these faces' own widths, not Liberation Sans's, because Pica measured
each label before Giggly placed it. Because the labels are drawn as outlines, the chart looks
the same to every reader, whether or not their machine has the fonts. The words are still in
the drawing as unseen text, so a screen reader reads them and a search of the page finds them.

Register fonts once, when the application starts. `installed_fonts: false` tells Giggly to use
only the registered fonts and never look for others on the machine drawing the chart. Giggly's
[fonts guide](https://hexdocs.pm/giggly/fonts.html) has the rest: faces, the symbol font, and
writing labels as text instead of outlines.
