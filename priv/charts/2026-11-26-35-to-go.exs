alias Giggly.Plot

# Counted from Giggly's notebooks at each day's last commit to notebooks/, through the v0.2.0
# tag (2026-11-25). An example is a ```r block; it is drawn when an ```elixir block follows it
# before the next ```r block, and waiting when it isn't drawn and its text says "Not in Giggly
# yet". The index notebook is left out. The notebooks were all written on October 15, so the
# count starts there.
drawn_by_day = [
  {~D[2026-10-15], 26},
  {~D[2026-10-16], 35},
  {~D[2026-10-17], 41},
  {~D[2026-10-18], 71},
  {~D[2026-10-19], 102},
  {~D[2026-10-20], 131},
  {~D[2026-10-22], 152},
  {~D[2026-10-23], 178},
  {~D[2026-10-24], 198},
  {~D[2026-10-26], 248},
  {~D[2026-10-27], 248},
  {~D[2026-10-29], 267},
  {~D[2026-10-30], 270},
  {~D[2026-10-31], 303},
  {~D[2026-11-01], 337},
  {~D[2026-11-02], 346},
  {~D[2026-11-03], 353},
  {~D[2026-11-04], 407},
  {~D[2026-11-05], 409},
  {~D[2026-11-06], 420},
  {~D[2026-11-07], 448},
  {~D[2026-11-08], 473},
  {~D[2026-11-09], 476},
  {~D[2026-11-10], 476},
  {~D[2026-11-11], 480},
  {~D[2026-11-12], 489},
  {~D[2026-11-13], 493},
  {~D[2026-11-16], 494},
  {~D[2026-11-17], 496},
  {~D[2026-11-18], 496},
  {~D[2026-11-19], 500},
  {~D[2026-11-20], 500},
  {~D[2026-11-21], 531},
  {~D[2026-11-22], 547},
  {~D[2026-11-23], 563},
  {~D[2026-11-24], 568},
  {~D[2026-11-25], 568}
]

drawn =
  drawn_by_day
  |> Enum.map(fn {day, examples} -> %{day: day, examples: examples} end)
  |> Plot.new(%{x: :day, y: :examples})
  |> Plot.geom_hline(yintercept: 644, linetype: :dashed)
  |> Plot.annotate(:text,
    x: ~D[2026-10-15],
    y: 675,
    label: "All 644 examples",
    hjust: 0
  )
  |> Plot.geom_line(color: "#0072B2", linewidth: 1)
  |> Plot.geom_point(color: "#0072B2")
  |> Plot.scale_x_date(date_breaks: [week: 1], date_labels: "%b %-d")
  |> Plot.scale_y_continuous(limits: {0, 700})
  |> Plot.labs(x: :none, y: "Examples Giggly draws")
  |> Giggly.to_svg(width: 560, height: 300)

%{"drawn" => drawn}
