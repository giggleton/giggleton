defmodule GiggletonWeb.PixelArt do
  @moduledoc """
  Renders the village's stitch patterns as crisp SVG pixel art.

  Patterns live in `priv/patterns/*.txt`, one character per stitch (key in that folder's
  README). They are read and checked at compile time, and each row is turned into runs of
  same-thread stitches, so a 24×24 resident is a few dozen rects rather than hundreds. Each
  run's class names its thread token in `stitch.css`, so the art follows the site theme, except
  `d` and `l`, which stay dark and light in both themes for a resident whose colours are who
  they are, such as the magpie.
  """
  use Phoenix.Component

  @dir Path.expand("../../../priv/patterns", __DIR__)
  @threads %{
    ?k => "px-k",
    ?n => "px-n",
    ?w => "px-w",
    ?b => "px-b",
    ?y => "px-y",
    ?g => "px-g",
    ?r => "px-r",
    ?d => "px-d",
    ?l => "px-l"
  }

  patterns =
    for path <- Path.wildcard(Path.join(@dir, "*.txt")), into: %{} do
      @external_resource path
      name = Path.basename(path, ".txt")
      rows = path |> File.read!() |> String.split("\n", trim: true)

      widths = rows |> Enum.map(&String.length/1) |> Enum.uniq()

      unless match?([_], widths) do
        raise CompileError,
          description: "#{path}: rows must all be the same width, got #{inspect(widths)}"
      end

      runs =
        for {row, y} <- Enum.with_index(rows),
            {char, x, w} <- row |> String.to_charlist() |> GiggletonWeb.PixelArt.Runs.of(),
            char != ?. do
          class =
            Map.get(@threads, char) ||
              raise CompileError,
                description: "#{path}: unknown stitch #{inspect(<<char>>)} in row #{y + 1}"

          {x, y, w, class}
        end

      {name, %{width: hd(widths), height: length(rows), runs: runs}}
    end

  @patterns patterns

  @doc "The names of every pattern, from the files in `priv/patterns`."
  def names, do: Map.keys(@patterns)

  @doc """
  A pattern as an SVG, `size` pixels wide.

  Give `label` when the art means something on its own (a resident beside no name);
  without one it is hidden from screen readers as decoration.
  """
  attr :name, :string, required: true, values: Map.keys(@patterns)

  attr :size, :integer,
    default: 96,
    doc: "Width in CSS pixels; keep it a multiple of the pattern width"

  attr :label, :string, default: nil
  attr :class, :any, default: nil

  def pixel_art(assigns) do
    pattern = Map.fetch!(@patterns, assigns.name)

    assigns =
      assign(assigns,
        pattern: pattern,
        height: div(assigns.size * pattern.height, pattern.width)
      )

    ~H"""
    <svg
      class={["pixel", @class]}
      viewBox={"0 0 #{@pattern.width} #{@pattern.height}"}
      width={@size}
      height={@height}
      shape-rendering="crispEdges"
      role={@label && "img"}
      aria-label={@label}
      aria-hidden={is_nil(@label) && "true"}
    >
      <rect :for={{x, y, w, class} <- @pattern.runs} x={x} y={y} width={w} height="1" class={class} />
    </svg>
    """
  end
end
