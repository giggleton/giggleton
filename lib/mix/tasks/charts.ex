defmodule Mix.Tasks.Charts do
  @shortdoc "Redraws post charts whose scripts changed"

  @moduledoc """
  Runs the chart scripts under `priv/charts` and writes their SVGs under `priv/static/charts`.

  A script is named after its post, `priv/charts/2026-11-03-first-stitches.exs`, or after a
  resident, `priv/charts/giggly.exs`, and returns a map from chart name to the SVG Giggly drew:

      %{"mtcars" => plot |> Giggly.to_svg(width: 560, height: 360)}

  Each chart is written to `priv/static/charts/<script name>/<chart name>.svg`, and a post shows
  it with an image whose alt text is the caption:

      ![Fig. 1 — Heavier cars go fewer miles per gallon](/charts/2026-11-03-first-stitches/mtcars.svg)

  `Giggleton.Blog` and `Giggleton.Residents` inline the SVG into the page at compile time.
  Commit the script and its SVGs together, so the page never draws a chart on request.

  A script is rerun when it is newer than its charts, or when there are none.

      mix charts                       # every changed script
      mix charts first-stitches        # scripts whose names contain "first-stitches"
      mix charts --force               # every script, after bumping Giggly
  """
  use Mix.Task

  @scripts "priv/charts"
  @output "priv/static/charts"

  @impl true
  def run(args) do
    {opts, filters} = OptionParser.parse!(args, strict: [force: :boolean])

    # Load the dependencies without compiling the site, which can't compile until a post's
    # new chart exists. Scripts may call Giggly and other dependencies, never the site.
    Mix.Task.run("loadpaths")
    {:ok, _} = Application.ensure_all_started(:giggly)

    scripts =
      Path.wildcard(Path.join(@scripts, "*.exs"))
      |> Enum.filter(fn script ->
        filters == [] or Enum.any?(filters, &String.contains?(script, &1))
      end)
      |> Enum.filter(&(opts[:force] || stale?(&1)))

    if scripts == [], do: Mix.shell().info("Charts are up to date.")

    Enum.each(scripts, &draw/1)
  end

  defp draw(script) do
    dir = Path.join(@output, Path.basename(script, ".exs"))

    case Code.eval_file(script) do
      {%{} = charts, _binding} when map_size(charts) > 0 ->
        File.rm_rf!(dir)
        File.mkdir_p!(dir)

        for {name, svg} <- charts do
          path = Path.join(dir, "#{name}.svg")
          File.write!(path, svg)
          Mix.shell().info("Drew #{path}")
        end

      {other, _binding} ->
        Mix.raise(
          "#{script} must return a map of chart name to SVG, got: #{inspect(other, limit: 5)}"
        )
    end
  end

  defp stale?(script) do
    dir = Path.join(@output, Path.basename(script, ".exs"))
    script_time = File.stat!(script).mtime

    case Path.wildcard(Path.join(dir, "*.svg")) do
      [] -> true
      charts -> Enum.any?(charts, &(File.stat!(&1).mtime < script_time))
    end
  end
end
