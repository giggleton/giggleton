alias Giggly.Plot
alias Scales.{ColorOperations, Palette}

# Fig. 1 and 2: the same mammals on a linear scale and a logarithmic one.
sleep =
  Giggly.Datasets.msleep()
  |> Plot.new(%{x: :bodywt, y: :brainwt})
  |> Plot.geom_point()

linear =
  sleep
  |> Plot.labs(x: "Body weight (kg)", y: "Brain weight (kg)")
  |> Giggly.to_svg(width: 280, height: 240)

logged =
  sleep
  |> Plot.scale_x_log10()
  |> Plot.scale_y_log10()
  |> Plot.labs(x: "Body weight (kg), log scale", y: "Brain weight (kg), log scale")
  |> Giggly.to_svg(width: 280, height: 240)

# Fig. 3: blue to yellow, blended two ways. Scales blends in CIE L*a*b*, as R does; the naive
# way blends each of red, green and blue on its own.
low = "#0000FF"
high = "#FFFF00"
steps = 48
places = for i <- 0..(steps - 1), do: i / (steps - 1)

channels = fn "#" <> hex -> for <<byte::binary-size(2) <- hex>>, do: String.to_integer(byte, 16) end

rgb_blend = fn place ->
  hex =
    Enum.zip_with(channels.(low), channels.(high), fn from, to ->
      (from + (to - from) * place)
      |> round()
      |> Integer.to_string(16)
      |> String.pad_leading(2, "0")
    end)

  "#" <> Enum.join(hex)
end

blends = [
  {"Blended in RGB", Enum.map(places, rgb_blend)},
  {"Blended in Lab", Palette.continuous({:gradient, [low, high]}, places)}
]

rows =
  for {method, colors} <- blends, {place, color} <- Enum.zip(places, colors) do
    %{
      place: place,
      method: method,
      color: color,
      lightness: color |> ColorOperations.to_lab() |> elem(0)
    }
  end

swatches = Map.new(rows, &{&1.color, &1.color})

strips =
  rows
  |> Plot.new(%{x: :place, y: :method, fill: :color})
  # A shade wider than a step, so neighbouring tiles overlap and no seam shows between them.
  |> Plot.geom_tile(width: 1.1 / (steps - 1))
  |> Plot.scale_fill_manual(values: swatches)
  |> Plot.scale_y_discrete(limits: ["Blended in Lab", "Blended in RGB"])
  |> Plot.guides(fill: :none)
  |> Plot.labs(x: :none, y: :none)
  |> Plot.theme_minimal()
  |> Plot.theme(panel_grid: :none, axis_text_x: :none)
  |> Giggly.to_svg(width: 560, height: 150)

# Fig. 4: how light each blend is along the way, by L*, the lightness Lab keeps on its own axis.
lightness =
  rows
  |> Plot.new(%{x: :place, y: :lightness, color: :method})
  |> Plot.geom_line(linewidth: 1)
  |> Plot.scale_color_manual(values: %{"Blended in RGB" => "#7F7F7F", "Blended in Lab" => "#B5651D"})
  |> Plot.labs(x: "Place along the gradient", y: "Lightness (L*)", color: :none)
  |> Plot.theme(legend_position: :bottom)
  |> Giggly.to_svg(width: 560, height: 300)

# Fig. 5 and 6: one surface, Old Faithful's eruptions by waiting time, in ggplot2's default
# gradient and in viridis.
faithful =
  Giggly.Datasets.faithfuld()
  |> Plot.new(%{x: :waiting, y: :eruptions, fill: :density})
  |> Plot.geom_raster()
  |> Plot.labs(x: "Waiting (min)", y: "Eruption (min)", fill: "Density")

default_fill = Giggly.to_svg(faithful, width: 280, height: 240)
viridis_fill = faithful |> Plot.scale_fill_viridis_c() |> Giggly.to_svg(width: 280, height: 240)

%{
  "sleep-linear" => linear,
  "sleep-log" => logged,
  "strips" => strips,
  "lightness" => lightness,
  "faithful-default" => default_fill,
  "faithful-viridis" => viridis_fill
}
