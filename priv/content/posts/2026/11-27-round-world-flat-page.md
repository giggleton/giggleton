%{
  title: "Plot Meets World",
  description: "Giggly 0.3 draws maps, and Loxo is the new package that projects them. A primer on what that takes, from someone who didn't understand any of it, and why I trust code I mostly didn't write.",
  residents: [:loxo, :giggly],
  tags: ["maps", "projections", "packages"]
}
---
I wanted maps in Giggly for two reasons. Giggly wouldn't be feature-complete without them, and a significant proportion of good data visualizations are projected onto maps.

Giggly 0.3 draws maps, and a new Giggleton resident, [Loxo](https://github.com/giggleton/loxo), gets points off a round world and onto a flat page for it. Before this I didn't understand much about how maps work. If that's you too, here's what I learned.

One more thing up front: Claude wrote most of Loxo and most of Giggly's map code, not me. The last section is about why I'm comfortable that both work well enough to ship.

## Where is a point?

A place on Earth is usually given as a longitude and a latitude: degrees east or west of Greenwich, and degrees north or south of the equator.

Sounds like a grid, which is right up our alley because that's how most plots work. Small problem though. Not only is the Earth not flat like a grid, it is not even a sphere. It's a little squashed, about 43 km shorter from pole to pole than across the equator, and its surface is lumpy besides. So mapmakers pick a smooth, slightly squashed shape that fits the Earth well, and decide exactly how it lines up with the real Earth, so that every longitude and latitude on it lands on one particular spot on the ground. That pair of choices, the shape and how it lines up, is called a datum. GPS uses one called WGS 84. North American maps from much of the last century used another, NAD27. The same longitude and latitude in the two can be tens of meters apart on the ground.

A datum, plus a way of turning positions into numbers, is a coordinate system. There are thousands of them, and they're catalogued: EPSG 4326 is longitude and latitude on WGS 84, EPSG 3857 is the Web Mercator of most map tiles online, EPSG 32119 is North Carolina's own grid in meters. The other common way to name one is a proj string, a list of settings that spells the coordinate system out. In `+proj=ortho +lon_0=-80`, `+proj=ortho` asks for an orthographic projection, the globe as it looks from far out in space, and `+lon_0=-80` turns that globe so its middle is at longitude 80° west, over the Americas. Any setting a string leaves out takes a default, so with no `+lat_0` the middle sits on the equator. Loxo takes either an EPSG code or a proj string as the system to convert points from or to.

## You can't flatten an orange peel

The simplest way to draw a map is to ignore all that and plot longitude as x and latitude as y. Giggly does exactly this when you don't ask for anything else. Here `world` is a table of the world's countries, one GeoJSON shape per row, built from `GigDatasets.world_map/0` in this post's chart script, and `greenland` is the one row for Greenland.

GeoJSON is a standard way of writing down shapes on the Earth as plain JSON. A shape is a type, such as a point, a line or a polygon, and the longitude and latitude of each of its corners. A triangle over North Carolina looks like `{"type": "Polygon", "coordinates": [[[-80, 35], [-77, 35], [-78.5, 36.5], [-80, 35]]]}`, the last corner repeating the first to close it. A country is a list of polygons like that, one for each separate piece of land, such as an island. A lot of the map data you'll find online comes in this form.

```elixir
alias Giggly.Plot

Plot.new()
|> Plot.geom_sf(data: world, fill: "#e8dcc4", colour: "#8a7a5c", linewidth: 0.2)
|> Plot.geom_sf(data: greenland, fill: "#D55E00", colour: "#8a7a5c", linewidth: 0.2)
|> Giggly.to_svg(width: 560, height: 300)
```

![Fig. 1 — Longitude and latitude drawn straight onto the page. Greenland in orange.](/charts/2026-11-27-round-world-flat-page/degrees.svg)

It looks like a map, and for a lot of charts it's fine. But it's stretched. On the globe, a degree of longitude shrinks as you go toward the poles, to nothing at the pole itself. On this map every degree of longitude is the same width, so everything far north or south is pulled sideways.

Any flat map is stretched somewhere. That isn't a failure of mapmakers; it's geometry. You can't press an orange peel flat without tearing or stretching it, and the same goes for a globe. So every projection scheme has to make a tradeoff.

Mercator, Fig. 2, keeps angles right. Wherever you are on it, north is straight up and a small shape keeps its shape. The price is size: the farther from the equator, the more everything is blown up, and the poles are infinitely far away, which is why this map leaves Antarctica out.

![Fig. 2 — Web Mercator, without Antarctica.](/charts/2026-11-27-round-world-flat-page/mercator.svg)

Greenland looks about as big as Africa. Africa is about 14 times bigger.

Mercator was built for sailors, and this is where Loxo gets its name. Sail on one fixed compass bearing, say always north-east, and the path you trace on the globe is a curve called a loxodrome, or rhumb line. On a Mercator map, every loxodrome is a straight line. Rule a line between two ports, read its angle, and steer by it.

Equal Earth, Fig. 3, makes the opposite choice. Every country has its true area, and shapes get squeezed toward the edges instead.

![Fig. 3 — Equal Earth. Areas are true.](/charts/2026-11-27-round-world-flat-page/equal-earth.svg)

And an orthographic projection, Fig. 4, draws the globe as it looks from far out in space. It's the most honest picture of the shape, and it can only show half the world. The other half has nowhere to go.

![Fig. 4 — Orthographic, from above the equator at 80°W.](/charts/2026-11-27-round-world-flat-page/globe.svg)

The code for Figs. 2 to 4 is the same plot with one more line. Only `crs:` changes:

```elixir
Plot.coord_sf(crs: 3857)
Plot.coord_sf(crs: "+proj=eqearth")
Plot.coord_sf(crs: "+proj=ortho +lon_0=-80")
```

## What drawing a map actually takes

I assumed drawing a map meant running the coordinates through a formula and drawing polygons. That's the middle of it. There's more on either side.

**The shapes come in as GeoJSON.** `Plot.geom_sf/3` takes a table with a `geometry` column, each row one feature: a point, a line or a polygon, written the way GeoJSON writes them. GeoJSON is always longitude and latitude on WGS 84, so Giggly always knows where it's starting from.

**Every point gets projected.** Loxo converts each vertex of each shape into the map's coordinate system. A country is just a list of points, so this part really is a formula, millions of times over. The formulas are hard, which is why we wrap [`proj4rs`](https://crates.io/crates/proj4rs), a Rust library modeled on PROJ. PROJ is the free, open-source library that does coordinate conversions for most mapping software, including QGIS, PostGIS and R's `sf` package, and has been developed since the 1980s. We wrap the Rust library because we love [`rustler_precompiled`](https://hex.pm/packages/rustler_precompiled).

**Some points can't be drawn at all.** A projection is a formula that turns a longitude and latitude into an x and a y, and for some points that formula has no answer. On an orthographic globe, a point on the far side would land behind the globe, hidden by the near side, so there's no spot on the page for it. On Mercator, the poles would land infinitely far up or down. Loxo hands those points back as `nil` rather than inventing a position, and Giggly leaves them out of their shape.

**The grid has to bend.** Most maps draw faint lines of longitude and latitude across them at round numbers of degrees, so you can read off where things are. That network of lines is called the graticule, and it's the map's version of the grid lines behind an ordinary chart. On a projected map those lines aren't straight: they bend however the projection bends the land, as on the globe in Fig. 4. To draw those lines, Giggly works out round-numbered values in degrees, sends them through the same projection as the shapes, and then finds where each one crosses the edge of the panel, so the axis can be ticked and labelled in degrees even though the map is in meters. The panel's shape has to come out right too: a meter has to be as long across as up.

## Why a package of its own

Loxo doesn't know Giggly exists. It speaks in points and coordinate systems, so anything in Elixir that needs to move coordinates around can use it. Giggly lists it as optional, the same way it treats Pica and Explorer. Without Loxo, `coord_sf/2` still draws in longitude and latitude, as in Fig. 1. With it, `crs:` takes any coordinate system Loxo can read.

There were other ways to do this. There are Elixir bindings to PROJ and GDAL already, but each needs the C library installed on your machine, and none ships ready-built. Loxo comes with a precompiled binary, like Pica, so adding it is one line in your dependencies. We love `rustler_precompiled`!

## Why I trust it

The short version of why I trust code I mostly didn't write is that neither Claude nor I decided what the right answers were. Every expected value in these tests came from somewhere else.

**Loxo is checked against PROJ.** PROJ is the reference implementation of map projection, and R's `sf` package uses it. Loxo's test values are written by a script that runs PROJ 9.8.1 through `sf` in a Docker image. The committed tests cover Web Mercator, US Albers, Britain's National Grid, France's Lambert 93 and an orthographic projection, forward and back, held to a millionth of a meter and a billionth of a degree, because 10+ decimal points of precision is just how Claude rolls. Before any of Loxo was written, Claude measured `proj4rs` the same way, over 19 cases in 12 projections and about 11,000 points. Its largest gap from PROJ was six nanometers, but we decided to allow it.

**Giggly's maps are checked against ggplot2.** Every test drawing in Giggly was checked element by element against the SVG that ggplot2 itself draws for the same plot, in R. There are 14 of those for maps: projected and unprojected maps, Mercator, Albers, orthographic, points beyond the horizon, legends and labels. The graticule was prototyped first and compared number by number with what `sf` gives, on North Carolina in four coordinate systems, the US states in three, the world in four, Europe in two and a polar map, and it matched every line, tick and label. The point where a label goes inside each shape matches every point in R's version. Giggly's notebook that follows ggplot2's own reference page for `geom_sf()` draws its examples, and North Carolina's counties sit within 0.02 of a point of ggplot2's drawing of them.

What these checks don't deliver:

- **Matching R means matching R's choices.** As is our general approach, where ggplot2 draws something oddly, Giggly does too, on purpose. An orthographic map's equator, for instance, runs straight across the panel past the horizon, because that's what `sf` does.
- **Loxo has no datum shifts yet.** Moving a point from one datum to another, say from NAD27 to WGS 84, isn't a single formula. The difference between two datums varies from place to place, so PROJ uses grids of measured corrections, data files that each cover a region, and picks one by where the point is. `proj4rs` doesn't have those grids. For Giggly they rarely matter, because GeoJSON is always in WGS 84. So for now Loxo refuses a coordinate system like NAD27 with an error, rather than drawing it slightly in the wrong place. Britain's National Grid comes out 3.4 mm from PROJ's, because PROJ picks a more local shift there.
- **Some projections are missing**, among them Natural Earth and Winkel Tripel, which `proj4rs` doesn't have.
