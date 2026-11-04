defmodule GiggletonWeb.DemoComponents do
  @moduledoc """
  The frame every live demo draws in: the chart, the reader's controls beneath it and the
  caption, in the same stitched frame as a static chart.
  """
  use Phoenix.Component

  @doc """
  A live chart in its frame. `chart` is an SVG already passed through
  `Giggleton.Blog.Figures.scalable/2` with `"\#{id}-caption"` as its caption id.
  """
  attr :id, :string, required: true
  attr :chart, :string, required: true
  slot :controls, required: true
  slot :caption, required: true

  def demo_frame(assigns) do
    ~H"""
    <figure id={@id} class="stitched chart-frame demo" aria-labelledby={"#{@id}-caption"}>
      <div class="chart">{Phoenix.HTML.raw(@chart)}</div>
      <div class="demo-controls">{render_slot(@controls)}</div>
      <figcaption id={"#{@id}-caption"}>{render_slot(@caption)}</figcaption>
    </figure>
    """
  end
end
