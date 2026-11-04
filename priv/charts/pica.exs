alias Giggly.Plot

plot =
  Giggly.Datasets.mtcars()
  |> Plot.new(%{x: :wt, y: :mpg})
  |> Plot.geom_point()
  |> Plot.labs(
    title: "Heavier cars, thirstier engines",
    x: "Weight (1,000 lb)",
    y: "Miles per gallon"
  )
  |> Plot.theme_gray(base_family: "Source Serif 4", header_family: "Lobster")

# Named only: drawn before any font is registered, and without searching the fonts installed on
# this machine, so it is what a project without Pica draws.
named = Giggly.to_svg(plot, width: 480, height: 320, installed_fonts: false)

# A script has no application start, so it registers the fonts here. Pica's page shows an
# application doing the same once, in Application.start/2.
for {family, file} <- [
      {"Source Serif 4", "SourceSerif4-Regular.otf.woff2"},
      {"Lobster", "Lobster-Regular.ttf"}
    ] do
  {:ok, font} = Pica.load(File.read!(Path.join("priv/static/fonts", file)))
  :ok = Pica.register(family, plain: font)
end

registered = Giggly.to_svg(plot, width: 480, height: 320)

%{"named" => named, "registered" => registered}
