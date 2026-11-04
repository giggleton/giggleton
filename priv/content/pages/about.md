%{
  title: "About Giggleton",
  description: "What Giggleton is, who lives in the village, and how the site is made."
}
---
Giggleton is a set of Elixir packages for drawing charts, and this site is their village: a diary of what the packages are up to, and a reference page for each.

## The village

Each package is a resident with a trade:

- **Giggly** keeps the garden plots and draws the charts, in the grammar of graphics that R's ggplot2 made familiar.
- **Pica** runs the press and measures every letter, so a label sits where its font puts it.
- **Scales** keeps the weights, measures and palettes: the breaks, labels, transforms and colours a chart's scales are built from.

Their [reference pages](/residents) say what each one does and how to ask. The [diary](/posts) is where I write down what they've been up to: new features, fixes, and charts worth drawing. There's a [feed](/feed.xml) for anyone who reads with a feed reader.

## Why cross-stitch

A chart is a grid of marks, and so is a sampler. The site is stitched on linen, with the residents as 24×24 patterns you could stitch yourself.

The stitching stops at a chart's frame, though. Every chart here is shown exactly as Giggly drew it, in Giggly's own colours and type, so what you see is what the code makes.

## How the site is made

The site is a Phoenix LiveView app with no database. Posts and pages are Markdown, compiled into the app by NimblePublisher and MDEx, with code highlighted by Makeup.

Static charts are drawn by Giggly ahead of time, committed as SVG and set into the page when the site compiles. Live charts are LiveView components: Giggly redraws them on the server as you move their controls, and the new drawing comes back over the page's socket.

The packages are open source, [on GitHub](https://github.com/giggleton).
