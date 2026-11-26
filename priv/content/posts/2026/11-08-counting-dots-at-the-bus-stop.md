%{
  title: "How many dots away?",
  description: "geom_dotplot is one of ggplot2's odder geoms. Who the heck is using this thing?",
  residents: [:giggly],
  tags: ["dotplots", "uncertainty", "livebook"]
}
---
As a complete nerd, one thing I like to do is page through the ggplot2 reference pages looking at all the oddball types of charts and wishing I was doing something that required their use. `geom_dotplot()` is one of those. It stacks one dot per observation, each dot as wide as its bin, which sounds like a histogram with extra steps. Then the documentation warns you that the numbers on its y axis don't mean anything, and suggests you hide them. M'kay...

But there's at least one place where the humble dot plot is CLINICALLY PROVEN to be more effective than its better-known peers.

The bus stop.

## When(ish) is my bus?

In 2016, Matthew Kay, Tara Kola, Jessica Hullman and Sean Munson published [When (ish) is My Bus?](https://mucollective.northwestern.edu/project/when-ish-is-my-bus), a study of OneBusAway, the real-time transit app many Seattle riders were using. Their opening example: the app says your bus is five minutes away, so you duck into a coffee shop. The bus makes up time, arrives in two, and you're late for your meeting. The app wasn't really wrong. It gave a point estimate for something that was uncertain, and no additonal information about just how uncertain.

The academic way to visualize "just how uncertain" is a density curve. But it is reasonable to wonder if bus riders will find that to be easy to interpret and use. What's the chance the bus comes before you'd have to leave the coffee shop? It's the area under one part of the curve, and nobody judges areas well by eye.

Kay and his co-authors drew it differently. Their *quantile dotplot* shows the prediction as a small number of dots, each worth the same share of the chance. With 20 dots, each dot is a 1-in-20 chance. To answer "will the bus come before I leave?", you count.

## Building one

Say the app thinks the bus is about 10 minutes out, and it's likelier to run late than early. The study's predictions came from models fit to about two weeks of real Seattle arrival data. We'll keep things simple and make up a log-normal distribution with that shape; or in human words, half of such buses come within 10 minutes, with a long tail of stragglers. Here it is drawn as a density curve, with a dashed line at 8 minutes, when you'd have to leave to get your coffee:

![Fig. 1 — The prediction as a density. How likely is the bus before 8 minutes? Good luck.](/charts/2026-11-08-when-ish-is-my-bus/density.svg)

To turn the curve into dots, ask the distribution's quantile function for evenly spaced shares: with 20 dots, the times by which 2.5%, 7.5%, 12.5% and so on up to 97.5% of buses have come. Each of those times becomes a dot. You (or your AI) can build a log-normal quantile function with Nx; that code is [appended at the end of the post](#appendix-the-quantile-function).

Then `geom_dotplot()` stacks them. We colour each dot by which side of 8 minutes it falls, and leave off the legend and the y axis, since a stack's height in data units means nothing here. This is the whole of the code that draws Fig. 2:

```elixir
# `quantiles` is the function from the appendix.
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
```

![Fig. 2 — The same prediction as 20 dots. Five are before the line: about a 1-in-4 chance.](/charts/2026-11-08-when-ish-is-my-bus/dots-20.svg)

Five dots are left of the line, so the bus beats you back about one time in four. The exact answer from the distribution is 22.8%, and nobody deciding whether to buy a latte needs the decimal. 

Why quantiles and not random draws from the distribution? Random draws are noisy: ask for 20 twice and you get two different pictures of the same prediction. Quantiles give the same 20 dots every time, spread the way the distribution says.

## Fewer dots work better

You might think more dots would be better, since they follow the curve more closely. Here are 100:

![Fig. 3 — 100 dots: closer to the curve, too many to count.](/charts/2026-11-08-when-ish-is-my-bus/dots-100.svg)

The study tested exactly this. In an online experiment, over 500 people read bus predictions drawn as a density, as 20 dots, as 100 dots and as a "stripe plot", then estimated probabilities from them. The 20-dot plots won. People's estimates were the most consistent, about 1.15 times more precise than with the density plots, and people were more confident in them. The 100-dot plots did no better than the density. With that many dots, people stopped counting and went back to eyeballing the shape. (In fairness to the density plot, people rated it the most visually appealing.)

A follow-up study in 2018 went a step further. It had people decide when to head for the bus, with money on the line, and found they made better decisions with quantile dotplots (or cumulative distribution charts) than with no uncertainty shown, or with uncertainty given only as text.

So there's the case for an obscure geom: when the reader needs to judge a probability without calculating an integral by eye, and there's room for about 20 dots.

## Try it

There's a [Livebook version](/notebooks/when-ish-is-my-bus.livemd) of this post with a slider for the number of dots, so you can watch counting get harder as the dots pile up. Change the prediction's median and spread, or move the 8-minute line, and see how the count changes.

The study's survey data and analysis code are on [GitHub](https://github.com/mjskay/when-ish-is-my-bus), for anyone who wants to dig further.

## Appendix: the quantile function

The `quantiles` function the figures use, for a log-normal prediction with a median of 10 minutes. It returns `count` arrival times, one for each dot:

```elixir
median = 10.0
spread = 0.3

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
```
