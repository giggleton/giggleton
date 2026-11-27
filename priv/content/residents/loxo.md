%{
  name: "Loxo",
  species: "moth",
  vocation: "Maps points from the round world to the flat page.",
  home: "The map room",
  thread: :gold,
  says: "Keep the moon on your left and you'll never wander.",
  install: ~s({:loxo, "~> 0.1"}),
  source: "https://github.com/giggleton/loxo",
  order: 4
}
---
Loxo keeps the village's map room: the `loxo` package, map projection for Elixir, through the
`proj4rs` crate in a precompiled native library.

## What Loxo does

Hand Loxo a point on the round world and the name of a flat one, and it says where the point
lands: a longitude and latitude converted to a Mercator sheet, or to a globe seen from space, or
to any of the projections a proj string can name.

Loxo is short for loxodrome. A moth steers by keeping the moon at the same angle all night. A
ship's navigator did the same with a compass, holding one bearing from port to port, and the
line that course traces on the globe is a loxodrome. It's not the shortest way, but it's the one
you can follow.

## The API

`Loxo.project/2` takes a list of points and two coordinate systems, the one the points are in
(`from:`) and the one to convert them to (`to:`). A point is `{x, y}`: for longitude and latitude,
longitude first, in degrees. A coordinate system is an EPSG code, such as `4326` for longitude
and latitude or `3857` for Web Mercator, or a proj string. Here two points, one in North Carolina
and one in China, go from longitude and latitude onto an orthographic projection, the globe as
seen from space above the equator at 80°W:

```elixir
Loxo.project([{-79.0, 35.5}, {120.0, 35.0}], from: 4326, to: "+proj=ortho +lon_0=-80")
#=> {:ok, [{90724.78519077871, 3683167.978542877}, nil]}
```

The points come back in the same order, in the new system's units. China is on the far side of
the globe, so it comes back `nil`, and North Carolina is projected all the same.

- `Loxo.coordinate_system/1` reads a system once, into a `Loxo.CoordinateSystem` that
  `project/2` takes in place of the code or string, and says whether it is longitude and
  latitude. Read it once when projecting many batches between the same two systems.
- `Loxo.project!/2` and `Loxo.coordinate_system!/1` raise a `Loxo.Error` instead of returning
  `{:error, reason}`.

A system Loxo can't read makes the whole call an error: an EPSG code with no system, a proj
string it can't parse, or a datum shift that needs a grid file, as NAD27's (`4267`) does, which
Loxo doesn't have yet. Loxo comes with precompiled binaries, so a project using it needs no
PROJ, no GDAL and no C toolchain.

## Drawing a map

Giggly 0.3 draws maps, and Loxo is what lets it draw them in any projection. `Plot.geom_sf/3`
draws a table whose `geometry` column holds a GeoJSON geometry in each row, in longitude and
latitude, and `Plot.coord_sf/2` names the system to draw it in with `crs:`, an EPSG code or a
proj string. Giggly uses Loxo to project each point of the map into that system, and projects the lines
of latitude and longitude the same way, so they curve along with the map.

```elixir
alias Giggly.Plot

GigDatasets.nc()
|> Plot.new()
|> Plot.geom_sf(%{fill: :AREA})
|> Plot.coord_sf(crs: 32119)
|> Giggly.to_svg(width: 560, height: 260)
```

![Fig. 1 — North Carolina's counties, filled by area, in the state's own plane coordinates (EPSG 32119).](/charts/loxo/nc.svg)

Loxo is optional in Giggly. List it in your project's dependencies and `crs:` takes any system
Loxo can read; without it, `crs:` takes only longitude and latitude.
