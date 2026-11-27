alias Giggly.Plot

# Fig. 1: how long `Giggly.layer_data/2` took on a million rows, read into lists or kept in
# Explorer (lazy, after `materialize/1`), best of three. Measured 2026-11-20; the numbers are
# from the "Engine backends" entry in Giggly's notes/design-log.md.
timings = [
  {"Count by class", "Lists", 3.9},
  {"Count by class", "Explorer", 0.17},
  {"Count by class and group", "Lists", 6.6},
  {"Count by class and group", "Explorer", 0.37},
  {"30-bin histogram by group", "Lists", 5.4},
  {"30-bin histogram by group", "Explorer", 0.22}
]

seconds =
  timings
  |> Enum.map(fn {layer, frame, seconds} -> %{layer: layer, frame: frame, seconds: seconds} end)
  |> Plot.new(%{x: :seconds, y: :layer, fill: :frame})
  |> Plot.geom_col(position: :dodge)
  |> Plot.scale_fill_manual(values: %{"Lists" => "#D55E00", "Explorer" => "#0072B2"})
  |> Plot.labs(x: "Seconds, at a million rows", y: :none, fill: :none)
  |> Plot.theme(legend_position: :bottom)
  |> Giggly.to_svg(width: 560, height: 260)

%{"seconds" => seconds}
