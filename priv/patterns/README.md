# Stitch patterns

Copied from the Giggleton design system's `assets/patterns/`. One character per stitch, one
line per row; every row in a file is the same width.

| Char | Thread |
| --- | --- |
| `.` | unstitched (nothing drawn) |
| `k` | ink |
| `n` | thread-brown |
| `w` | cloth-panel |
| `b` | thread-blue |
| `y` | thread-gold |
| `g` | thread-green |
| `r` | thread-red |
| `d` | always dark: ink in Linen, cloth-sunken in Midnight |
| `l` | always light: cloth-panel in Linen, ink in Midnight |
| `u` | pastel blue, the same in both themes |
| `v` | pastel purple, the same in both themes |
| `p` | pastel pink, the same in both themes |

`d` and `l` are the site's, not the design system's. Every other thread follows the theme, so
ink turns light in Midnight and a black bird would turn white. Pica is stitched in `d` with a
`k` edge and an `l` breast and eye, so she stays a magpie in both themes. The design system's
`pica.txt` still has the original rows, whose breast meets the card unoutlined.

Loxo the moth is stitched in `u`, `v` and `p`, edged in `d` so its wings stay outlined
in Midnight, with antennae in `k` so they show against the dark card.

`GiggletonWeb.PixelArt` reads these at compile time; editing one recompiles it.
