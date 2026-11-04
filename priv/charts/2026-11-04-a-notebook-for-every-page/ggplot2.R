# ggplot2's own drawings of the two plots "A notebook for every page" compares with Giggly's,
# drawn as Giggly's goldens are checked: by vdiffr's copy of svglite, which measures text with the
# same glyph table Giggly does. mix charts never runs this; it needs R, ggplot2 and vdiffr. From
# the repository's root, with the giggly repository's ggplot2 4.0.3 image:
#
#   docker run --rm -v "$PWD/priv/charts/2026-11-04-a-notebook-for-every-page":/out \
#     giggly-r:ggplot2-4.0.3 Rscript /out/ggplot2.R
#
# It writes point.svg and smooth.svg beside itself; then run `mix charts --force
# a-notebook-for-every-page` to draw Giggly's and copy these into the post's charts.
#
# Each is 400 by 300 pixels at 96 to the inch, the size the post's script draws Giggly's at.

library(ggplot2)

draw <- function(plot, name) {
  vdiffr:::svglite(file.path("/out", paste0(name, ".svg")), width = 400 / 96, height = 300 / 96)
  print(plot)
  invisible(dev.off())
}

draw(ggplot(mtcars, aes(wt, mpg)) + geom_point(), "point")
draw(ggplot(mpg, aes(displ, hwy)) + geom_point() + geom_smooth(span = 0.3), "smooth")
