alias Giggly.Plot

# Fig. 1 and 2: the same counts twice, once with mpg's own short class names and once spelled
# out. The post quotes the one line that differs, `Plot.scale_y_discrete(labels: names)`.
names = %{
  "2seater" => "Two-seater sports car",
  "compact" => "Compact",
  "midsize" => "Midsize",
  "minivan" => "Minivan",
  "pickup" => "Pickup truck",
  "subcompact" => "Subcompact",
  "suv" => "Sport utility vehicle"
}

counts =
  GigDatasets.mpg()
  |> Keyword.fetch!(:class)
  |> Enum.frequencies()
  |> Enum.map(fn {class, cars} -> %{class: class, cars: cars} end)

bars =
  counts
  |> Plot.new(%{x: :cars, y: :class})
  |> Plot.geom_col()
  |> Plot.labs(x: "Cars", y: :none)

draw = fn plot -> Giggly.to_svg(plot, width: 280, height: 240) end

# Fig. 3: how much narrower some words are in Source Serif 4 once Pica shapes them, with
# kerning and ligatures, than their letters' own widths added up one by one.
{:ok, serif} =
  "priv/static/fonts/SourceSerif4-Regular.otf.woff2"
  |> File.read!()
  |> Pica.load()

words = [
  "AVATAR",
  "WAVY",
  "Yo-yo",
  "office",
  "Toyota",
  "Volkswagen",
  "Weight (1,000 lb)",
  "Miles per gallon"
]

narrower =
  Enum.map(words, fn word ->
    ids = Pica.glyph_ids(serif, word)

    letter_by_letter =
      serif
      |> Pica.nominal_advances(ids)
      |> Enum.sum()

    shaped =
      serif
      |> Pica.shape(word)
      |> Enum.map(& &1.x_advance)
      |> Enum.sum()

    %{word: word, percent: 100 * (letter_by_letter - shaped) / letter_by_letter}
  end)

# The biggest saving at the top: a discrete y axis runs from the bottom up.
order =
  narrower
  |> Enum.sort_by(& &1.percent)
  |> Enum.map(& &1.word)

kerning =
  narrower
  |> Plot.new(%{x: :percent, y: :word})
  |> Plot.geom_col(fill: "#0072B2")
  |> Plot.scale_y_discrete(limits: order)
  |> Plot.labs(x: "Narrower once shaped (%)", y: :none)
  |> Giggly.to_svg(width: 560, height: 260)

%{
  "short" => draw.(bars),
  "long" => draw.(Plot.scale_y_discrete(bars, labels: names)),
  "kerning" => kerning
}
