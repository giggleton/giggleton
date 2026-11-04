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

A plot names its fonts by family, in its theme. What a reader then sees depends on whether Pica
holds the font.

```elixir
alias Giggly.Plot

plot =
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
```

### Naming the font

In a project without Pica, naming the families is all there is to it:

```elixir
Giggly.to_svg(plot, width: 480, height: 320)
```

![Fig. 1 — The fonts named only. Giggly laid the chart out with Liberation Sans's widths, and your browser draws each label in the named face, if it has it, stretched or squeezed to fit.](/charts/pica/named.svg)

Giggly has no font to measure, so it lays the chart out with Liberation Sans's widths and writes
each label as text naming its family, fitted to the width it measured. This page loads both
faces as web fonts, so your browser draws them, but at the wrong widths. Lobster sets the title
151 points wide where Liberation Sans takes 175, so here it is stretched about 16% to fill the
room, and the axis titles by 8% and 14%. Compare them with Fig. 2.

A browser without the face draws a fallback, usually Arial or Helvetica, instead. So does every
feed reader, since a chart in a feed is an image, and an image can't use a page's fonts.

### Registering it with Pica

Ship the font files in `priv` and register them with Pica once, when the application starts:

```elixir
# lib/my_app/application.ex
@fonts [
  {"Source Serif 4", "SourceSerif4-Regular.otf.woff2"},
  {"Lobster", "Lobster-Regular.ttf"}
]

def start(_type, _args) do
  Enum.each(@fonts, &register_font/1)
  # ...then start the supervision tree as usual
end

defp register_font({family, file}) do
  bytes =
    :my_app
    |> Application.app_dir("priv/fonts")
    |> Path.join(file)
    |> File.read!()

  {:ok, font} = Pica.load(bytes)
  :ok = Pica.register(family, plain: font)
end
```

Then the same call draws the same plot:

```elixir
Giggly.to_svg(plot, width: 480, height: 320)
```

![Fig. 2 — The fonts registered with Pica. Each label measured in its own face and drawn as that face's outlines.](/charts/pica/registered.svg)

Pica measured each label in its own face before Giggly placed it, so the layout is built for
these widths. Giggly then drew each label as the font's glyph outlines, so the SVG carries the
letters itself: it looks the same to every reader and in every feed, with no web font. The words
are still in the drawing as unseen text, so a screen reader reads them and a search of the page
finds them.

A page that loads the faces itself can have both: `Giggly.to_svg(plot, text: :text)` measures
with Pica but writes each label as text naming its family, a smaller drawing that the browser
draws at the right widths. Giggly's [fonts guide](https://hexdocs.pm/giggly/fonts.html) has the
rest: bold and italic faces, and fonts installed on the machine.
