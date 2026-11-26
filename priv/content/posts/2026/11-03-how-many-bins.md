%{
  title: "How many bins?",
  description: "Giggly's first live chart: a histogram you can rebin with a slider, redrawn on the server as you move it.",
  residents: [:giggly],
  tags: ["histograms", "live-charts"]
}
---
You can't build a charting library in Elixir without showing how it works with LiveView. For our example we picked the histogram as a nod to one of ggplot2's sillier quirks.
## Thirty bins

To draw a histogram, you need to somehow specify how the chart will split the data into bins. By default, ggplot2 uses 30 bins, but it immediately warns you that 30 is a dumb number to use for this purpose.

Giggly uses that default too! But, thanks to LiveView, quickly seeing how your data looks with different numbers of bins is a breeze.

```elixir
alias Giggly.Plot

GigDatasets.mpg()
|> Plot.new(%{x: :hwy})
|> Plot.geom_histogram(bins: bins)
|> Plot.labs(x: "Highway miles per gallon", y: "Cars")
|> Giggly.to_svg(width: 560, height: 320)
```

<!-- demo: Bins -->

These are the 234 cars in ggplot2's `mpg` table, by highway miles per gallon. At three bins there's no shape to speak of: a short bar, a tall one and a sliver. Around a dozen, two humps show: one near 17 miles per gallon, nearly all SUVs and pickups, and one near 26 for the compacts, midsizes and subcompacts.

Past about thirty the bins get narrower than a mile per gallon. The table records mileage in whole miles per gallon, so from there on the chart is a count of each whole number, gaps and all.

## How it works

The chart is a LiveView component inside the post. The slider updates the value of `bins`, Giggly draws the histogram again, and returns the new SVG. Stripped down to a plain LiveView, it's about this much code:

```elixir
defmodule MyAppWeb.BinsLive do
  use MyAppWeb, :live_view

  alias Giggly.Plot

  def mount(_params, _session, socket) do
    {:ok, draw(socket, 30)}
  end

  def handle_event("bins", %{"bins" => bins}, socket) do
    {:noreply, draw(socket, String.to_integer(bins))}
  end

  defp draw(socket, bins) do
    svg =
      GigDatasets.mpg()
      |> Plot.new(%{x: :hwy})
      |> Plot.geom_histogram(bins: bins)
      |> Giggly.to_svg(width: 560, height: 320)
      |> IO.iodata_to_binary()

    src = "data:image/svg+xml;base64," <> Base.encode64(svg)
    assign(socket, bins: bins, src: src)
  end

  def render(assigns) do
    ~H"""
    <form phx-change="bins">
      <input
        type="range"
        name="bins"
        min="3"
        max="60"
        value={@bins}
      />
    </form>
    <img
      src={@src}
      alt={"Highway mileage of 234 cars, in #{@bins} bins"}
    />
    """
  end
end
```

Moving the slider sends a `"bins"` event, `draw/2` builds the plot again with the new count, and LiveView sends the new SVG down to the browser. There's no JavaScript chart library to keep in sync. The server owns the chart, and the browser shows whatever it's given.

But wait, you say, this means you have to redraw the entire SVG when anything changes! What if I have 50,000 points on a scatter plot?

You don't have 50,000 points on a scatter plot. Get over yourself. Redrawing it will work fine.

That said, I too don't really care if I have 50,000 points or not, I want to figure out how to solve that problem. And I have some ideas, but Giggly doesn't do that yet.

Final note - the snippet and the demo on this page differ in a few ways:

- **Getting the SVG on the page.** The snippet puts it in an `<img>` as a data URI. The demo puts it straight into the page with `raw/1`, which also works (and Giggly escapes things like label text), but is less secure if your data is untrusted. The downside of the `<img>` approach is that it closes the door on CSS styling, which will be a thing Giggly has more support for over time.
- **Validation.** Along those lines, the snippet calls `String.to_integer/1` on whatever the slider sends. The demo uses `Integer.parse/1` instead, ignores anything that isn't a whole number, and keeps the count between 3 and 60.
- **Throttling.** The demo's slider has `phx-throttle="60"`, so dragging it sends at most one event every 60 milliseconds instead of one for every value the slider passes through.

In our next post, we'll talk about Giggly Livebook guides. I'm super proud of this.