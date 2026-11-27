alias Giggly.Plot

# North Carolina's counties, filled by area, drawn in the state's own plane coordinates (NAD83 /
# North Carolina, EPSG 32119), which Loxo carries every point onto.
nc =
  GigDatasets.nc()
  |> Plot.new()
  |> Plot.geom_sf(%{fill: :AREA})
  |> Plot.coord_sf(crs: 32119)
  |> Giggly.to_svg(width: 560, height: 260)

%{"nc" => nc}
