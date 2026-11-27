alias Giggly.Plot

# Natural Earth's countries as GigDatasets.world_map/0 lays them out, a row to a point, made into
# one GeoJSON MultiPolygon for each country, as Giggly's ggsf notebook does. Two of Russia's points
# sit at longitude 180.00000000000006, a hair past the antimeridian, which a projection wraps round
# to -180, drawing a sliver across the whole map; so every longitude is held to [-180, 180].
world_map = GigDatasets.world_map()

countries =
  [world_map[:long], world_map[:lat], world_map[:group], world_map[:region]]
  |> Enum.zip_with(fn [long, lat, group, region] ->
    {region, group, [long |> max(-180.0) |> min(180.0), lat]}
  end)
  |> Enum.chunk_by(fn {region, _group, _position} -> region end)
  |> Enum.map(fn [{region, _group, _position} | _rest] = rows ->
    rings =
      rows
      |> Enum.chunk_by(fn {_region, group, _position} -> group end)
      |> Enum.map(fn ring -> [Enum.map(ring, fn {_region, _group, position} -> position end)] end)

    {region, %{"type" => "MultiPolygon", "coordinates" => rings}}
  end)

features = fn countries ->
  [
    region: Enum.map(countries, fn {region, _geometry} -> region end),
    geometry: Enum.map(countries, fn {_region, geometry} -> geometry end)
  ]
end

world = features.(countries)
greenland = countries |> Enum.filter(fn {region, _} -> region == "Greenland" end) |> features.()

# Mercator sends the poles to infinity, so its map leaves Antarctica out, as web maps do.
not_antarctica = Enum.reject(countries, fn {region, _} -> region == "Antarctica" end)

map = fn world ->
  Plot.new()
  |> Plot.geom_sf(data: world, fill: "#e8dcc4", colour: "#8a7a5c", linewidth: 0.2)
  |> Plot.geom_sf(data: greenland, fill: "#D55E00", colour: "#8a7a5c", linewidth: 0.2)
end

# Fig. 1: longitude and latitude drawn straight onto the page, as x and y. No Loxo.
degrees = map.(world) |> Giggly.to_svg(width: 560, height: 300)

# Fig. 2: Web Mercator, the projection of most map tiles on the web.
mercator =
  map.(features.(not_antarctica))
  |> Plot.coord_sf(crs: 3857)
  |> Giggly.to_svg(width: 560, height: 460)

# Fig. 3: Equal Earth, which keeps every country's area true.
equal_earth =
  map.(world)
  |> Plot.coord_sf(crs: "+proj=eqearth")
  |> Giggly.to_svg(width: 560, height: 300)

# Fig. 4: orthographic, the globe as seen from far out in space, above the equator at 80°W.
globe =
  map.(world)
  |> Plot.coord_sf(crs: "+proj=ortho +lon_0=-80")
  |> Giggly.to_svg(width: 360, height: 360)

%{
  "degrees" => degrees,
  "mercator" => mercator,
  "equal-earth" => equal_earth,
  "globe" => globe
}
