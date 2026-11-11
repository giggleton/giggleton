alias Giggly.Plot

# A made-up prediction shaped like a real one: the bus is most likely about 10 minutes away, and
# more likely to run late than early. Log-normal, its median 10 minutes and its log's standard
# deviation 0.3.
median = 10.0
spread = 0.3

density = fn minutes ->
  z = (:math.log(minutes) - :math.log(median)) / spread
  :math.exp(-z * z / 2) / (minutes * spread * :math.sqrt(2 * :math.pi()))
end

# The quantile function: the arrival time by which a share `p` of buses has come. The normal
# distribution's comes from the inverse error function, which Nx has.
quantiles = fn count ->
  shares =
    1..count
    |> Enum.map(fn i -> (i - 0.5) / count end)
    |> Nx.tensor()

  z =
    shares
    |> Nx.multiply(2)
    |> Nx.subtract(1)
    |> Nx.erf_inv()
    |> Nx.multiply(:math.sqrt(2))

  z
  |> Nx.multiply(spread)
  |> Nx.add(:math.log(median))
  |> Nx.exp()
  |> Nx.to_list()
end

leave_by = 8.0
axis = [x: "Minutes until the bus arrives", y: :none]

# Twenty dots, each a 1-in-20 chance, coloured by whether the bus has come by the time you'd
# have to leave. Written out in full, without `frame` below, because the post shows this code as
# it is, with the comment on `quantiles` just below: change one and change the other.
# `quantiles` is the function from the appendix.
twenty =
  quantiles.(20)
  |> Enum.map(fn minutes ->
    early = if minutes < 8, do: "Before 8", else: "After 8"
    %{minutes: minutes, early: early}
  end)
  |> Plot.new(%{x: :minutes, fill: :early})
  |> Plot.geom_dotplot(binwidth: 1.0, color: :none)
  |> Plot.geom_vline(xintercept: 8, linetype: :dashed)
  |> Plot.scale_fill_manual(
    values: %{
      "Before 8" => "#D55E00",
      "After 8" => "#0072B2"
    }
  )
  |> Plot.scale_x_continuous(limits: {0, 25})
  |> Plot.scale_y_continuous(name: :none, breaks: :none)
  |> Plot.guides(fill: :none)
  |> Plot.labs(x: "Minutes until the bus arrives")
  |> Giggly.to_svg(width: 560, height: 160)

# A hundred dots, too many to count, in one colour.
hundred =
  for(minutes <- quantiles.(100), do: %{minutes: minutes})
  |> Plot.new(%{x: :minutes})
  |> Plot.geom_dotplot(binwidth: 0.4, color: :none, fill: "#0072B2")

curve =
  Plot.new()
  |> Plot.geom_function(fun: density, geom: :area, xlim: {0.1, 25}, n: 201, fill: "#0072B2")

# The same axis as the twenty dots, with the y axis left off: neither a density's height nor a
# stack's means anything a reader needs.
frame = fn plot ->
  plot
  |> Plot.geom_vline(xintercept: leave_by, linetype: :dashed)
  |> Plot.scale_x_continuous(limits: {0, 25})
  |> Plot.scale_y_continuous(name: :none, breaks: :none)
  |> Plot.labs(axis)
  |> Giggly.to_svg(width: 560, height: 160)
end

%{
  "density" => frame.(curve),
  "dots-20" => twenty,
  "dots-100" => frame.(hundred)
}
