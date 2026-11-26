# Charts for "First stitches". Run `mix charts` after changing this file.
alias Giggly.Plot

%{
  "mtcars" =>
    GigDatasets.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_point()
    |> Giggly.to_svg(width: 560, height: 360)
}
