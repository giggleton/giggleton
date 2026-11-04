# Charts for "A notebook for every page". Run `mix charts` after changing this file.
#
# Each plot is drawn twice: by Giggly here, and by ggplot2, whose drawings are committed beside
# this script with the R script that draws them (see its header). Both are 400 by 300 pixels.
alias Giggly.Plot

ggplot2 = fn name ->
  File.read!(Path.join("priv/charts/2026-11-04-a-notebook-for-every-page", "#{name}.svg"))
end

point =
  Giggly.Datasets.mtcars()
  |> Plot.new(%{x: :wt, y: :mpg})
  |> Plot.geom_point()

smooth =
  Giggly.Datasets.mpg()
  |> Plot.new(%{x: :displ, y: :hwy})
  |> Plot.geom_point()
  |> Plot.geom_smooth(span: 0.3)

%{
  "point-ggplot2" => ggplot2.("point"),
  "point-giggly" => Giggly.to_svg(point, width: 400, height: 300),
  "smooth-ggplot2" => ggplot2.("smooth"),
  "smooth-giggly" => Giggly.to_svg(smooth, width: 400, height: 300)
}
