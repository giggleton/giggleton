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

`GiggletonWeb.PixelArt` reads these at compile time; editing one recompiles it.
