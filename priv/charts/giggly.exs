alias Giggly.Plot

garden =
  GigDatasets.mpg()
  |> Plot.new(%{x: :displ, y: :hwy})
  |> Plot.geom_point(%{color: :drv})
  |> Plot.geom_smooth(method: :lm)
  |> Plot.facet_wrap(:year)
  |> Plot.labs(
    x: "Engine displacement (litres)",
    y: "Highway miles per gallon",
    color: "Drive"
  )

%{"garden" => Giggly.to_svg(garden, width: 480, height: 320)}
