defmodule GiggletonWeb.Demos.Bins do
  @moduledoc """
  How many bins: a histogram of highway mileage in ggplot2's `mpg`, which Giggly redraws on
  the server as the reader moves a slider. It starts at ggplot2's default of 30 bins, which is
  also what a reader without a socket sees.
  """
  use GiggletonWeb, :live_component

  alias Giggleton.Blog.Figures
  alias Giggly.Plot

  @min 3
  @max 60
  @default 30

  @impl true
  def mount(socket), do: {:ok, socket}

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, if(socket.assigns[:bins], do: socket, else: draw(socket, @default))}
  end

  @impl true
  def handle_event("bins", %{"bins" => bins}, socket) do
    case Integer.parse(bins) do
      {bins, ""} -> {:noreply, draw(socket, bins |> max(@min) |> min(@max))}
      _ -> {:noreply, socket}
    end
  end

  defp draw(socket, bins) do
    {:ok, chart} =
      GigDatasets.mpg()
      |> Plot.new(%{x: :hwy})
      |> Plot.geom_histogram(bins: bins)
      |> Plot.labs(x: "Highway miles per gallon", y: "Cars")
      |> Giggly.to_svg(width: 560, height: 320)
      |> Figures.scalable("#{socket.assigns.id}-caption")

    assign(socket, bins: bins, chart: chart, form: to_form(%{"bins" => bins}))
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, min: @min, max: @max)

    ~H"""
    <div id={"#{@id}-demo"}>
      <.demo_frame id={@id} chart={@chart}>
        <:controls>
          <.form for={@form} id={"#{@id}-form"} phx-change="bins" phx-target={@myself}>
            <label for={"#{@id}-bins"}>Bins</label>
            <input
              type="range"
              id={"#{@id}-bins"}
              name={@form[:bins].name}
              value={@form[:bins].value}
              min={@min}
              max={@max}
              step="1"
              phx-throttle="60"
            />
            <output for={"#{@id}-bins"}>{@bins}</output>
          </.form>
        </:controls>
        <:caption>
          Highway mileage of 234 cars, in {@bins} bins. Drawn live by Giggly, in its default
          theme.
        </:caption>
      </.demo_frame>
    </div>
    """
  end
end
