alias Giggly.Plot

font = fn file -> {:ok, font} = Pica.load(File.read!("priv/charts/fonts/" <> file)); font end
:ok = Pica.register("Source Serif 4", plain: font.("SourceSerif4-Regular.otf.woff2"))
:ok = Pica.register("Lobster", plain: font.("Lobster-Regular.ttf"))

press =
  Giggly.Datasets.mtcars()
  |> Plot.new(%{x: :wt, y: :mpg})
  |> Plot.geom_point()
  |> Plot.labs(
    title: "Heavier cars, thirstier engines",
    x: "Weight (1,000 lb)",
    y: "Miles per gallon"
  )
  |> Plot.theme_gray(base_family: "Source Serif 4", header_family: "Lobster")

%{"press" => Giggly.to_svg(press, width: 480, height: 320, installed_fonts: false)}
