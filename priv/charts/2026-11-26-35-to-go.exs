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

# The 126 examples waiting at 34e5991 (2026-11-13), each grouped once, under the first of these
# its note named, in this order: maps; the movies dataset; the theme's palettes and
# element_geom(); statistical models; R's own machinery (ggproto, grid grobs and arrows,
# plotmath, qplot(), %+%, theme objects, + aes()); stat plumbing (stats chosen by name,
# stat_manual(), stat_identity(), stat_unique(), after_scale(), stage()); functions in a
# mapping; and the rest. Then each one's state at v0.2.0: drawn, set aside (neither drawn nor
# waiting) or still waiting.
fates = [
  {"Maps", 0, 0, 32},
  {"R's own machinery", 13, 10, 3},
  {"Stat plumbing", 20, 0, 0},
  {"Statistical models", 6, 5, 0},
  {"The movies dataset", 10, 0, 0},
  {"Theme palettes", 9, 0, 0},
  {"Functions in a mapping", 8, 0, 0},
  {"Everything else", 9, 1, 0}
]

# Largest group at the top and "Everything else" at the bottom: a discrete y axis runs from
# the bottom up.
order =
  fates
  |> Enum.map(fn {what, _, _, _} -> what end)
  |> Enum.reverse()

rows =
  Enum.flat_map(fates, fn {what, drawn, aside, waiting} ->
    [
      %{what: what, now: "Drawn", examples: drawn},
      %{what: what, now: "Set aside", examples: aside},
      %{what: what, now: "Still waiting", examples: waiting}
    ]
  end)

fate =
  rows
  |> Plot.new(%{x: :examples, y: :what, fill: :now})
  |> Plot.geom_col(position: {:stack, reverse: true})
  |> Plot.scale_y_discrete(limits: order)
  |> Plot.scale_fill_manual(values: ["#0072B2", "#999999", "#E69F00"])
  |> Plot.labs(x: "Examples waiting on November 13", y: :none, fill: :none)
  |> Plot.theme(legend_position: :top)
  |> Giggly.to_svg(width: 560, height: 300)

%{"drawn" => drawn, "fate" => fate}
