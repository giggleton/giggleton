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
