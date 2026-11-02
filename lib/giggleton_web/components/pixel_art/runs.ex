defmodule GiggletonWeb.PixelArt.Runs do
  @moduledoc false

  @doc """
  Splits a row of stitches into runs of the same character, as `{char, x, width}`.

      iex> GiggletonWeb.PixelArt.Runs.of(~c"kkn.k")
      [{?k, 0, 2}, {?n, 2, 1}, {?., 3, 1}, {?k, 4, 1}]
  """
  def of(chars) do
    chars
    |> Enum.chunk_by(& &1)
    |> Enum.map_reduce(0, fn [char | _] = run, x -> {{char, x, length(run)}, x + length(run)} end)
    |> elem(0)
  end
end
