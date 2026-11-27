%{
  title: "Bring your own data frame",
  description: "Why Giggly 0.2 lets a data frame library plug in: faster charts from big tables, and no betting everything on one library. Explorer is the first.",
  residents: [:giggly],
  tags: ["dataframes", "explorer", "performance"]
}
---
I had two reasons for wanting Giggly to work with data frame engines.

The first is speed. A chart usually doesn't hold much data. A histogram of a million rows draws 30 bars. But until Giggly 0.2, drawing it meant reading all million rows into Elixir lists first and traverse them multiple times to perform calculations that produce 30 values.

The second is that I didn't want Giggly to bet everything on one engine. [Explorer](https://github.com/elixir-nx/explorer) is the data frame library most Elixir folks use. [Dux](https://github.com/elixir-dux/dux), a newer one, compiles to SQL and runs in DuckDB. Volunteers maintain both, and one or even both of them might not be around in a few years.

Explorer is the first engine. If your data is an Explorer data frame and Explorer is in your project, the calculations operate in Explorer. The work runs there, in Polars, and only the stat's output comes across: one row for each bar or box.

```elixir
Mix.install([
  {:giggly, "~> 0.2.0"},
  {:explorer, "~> 0.13.0"}
])

alias Giggly.Plot

"trips.parquet"
|> Explorer.DataFrame.from_parquet!(lazy: true)
|> Plot.new(%{x: :distance})
|> Plot.geom_histogram(bins: 30)
```

You don't turn this on. There's no `engine:` option. Hand Giggly an Explorer frame, lazy or eager, and it just works.

![Fig. 1 — The same three layers on a million rows, read into lists or kept in Explorer](/charts/2026-11-26-pluggable-frames/seconds.svg)

## A table with a contract

Every table inside Giggly is a `Giggly.DataFrame`: the data you gave the plot, each table a stat computes on, each one `Giggly.layer_data/2` hands back. The stats only touch their data through its functions: `select`, `filter`, `mutate`, `sort`, `distinct`, `summarise`, `join` and a few more.

`Giggly.DataFrame` is also a behaviour, with one callback for each of those functions. Each call dispatches on the frame's struct to the module that implements it, the same pattern Explorer and Nx use for their backends. Giggly has two of them. Its own keeps every column as a list. The other keeps an Explorer frame. Explorer is optional: if you're working with Explorer data frames, you've presumably already added it to your dependencies yourself.

The catch is that an engine can't run an Elixir function. So none of the frame's functions takes one. What `filter` and `mutate` compute in each row is an expression written as plain data:

```elixir
frame
|> Giggly.DataFrame.mutate(big: {:>, [:x, 3]}, half: {:/, [:x, 2]})
|> Giggly.DataFrame.filter(:big)
```

That's a small vocabulary: comparisons, `and`/`or`/`not`, arithmetic, `log10`, `floor`, `if_else`, `cut` for binning, and `is_missing`. Every stat in Giggly but one is written in it, so each of them runs on either frame without knowing which one it has.

## Agreeing on data types

*[Full disclosure - when I asked Claude to help with this post, I was surprised to learn that the entire process below exists. I am very actively engaged in developing Giggly, and it is not something I would miss. Another odd benefit to writing this blog.]*

Explorer works out the types of its columns, and you can ask it for them with its `dtypes` function, without running anything. But Explorer's types aren't Giggly's. Polars has eight sizes of integer where Giggly has one, stores atoms as strings, and doesn't keep a category's levels in order. And translating them would only cover the columns that already exist. The Explorer frame would still have to know what every operation produces (an integer divided by an integer is a float) and refuse whatever the list frame refuses, with the same message.

So beside the Explorer data, the Explorer frame keeps a tiny list frame with Giggly's types for the same columns and a single row, every value missing. Before each operation, it runs the same operation on that tiny frame. If the operation isn't allowed, say adding a number to a string, the list frame raises, and you get the same error you'd get on lists. If it's fine, the tiny frame that comes back has the result's columns and types, and that becomes the new schema. Then Explorer computes the values. The type rules live in one place.

Where Explorer's answer differs from the contract's, the Explorer frame builds the contract's answer out of Explorer operations. A box plot needs R's type 7 quantiles, which Polars doesn't have, so they're interpolated from ranks. And Explorer's `log(x, 10)` says the base-10 logarithm of 1000 is 2.9999999999999996, which matters when the breaks of a log scale are supposed to sit on powers of ten.

## When the engine sits out

Not every layer can run on the engine yet. Before anything runs, Giggly asks each part of the layer whether it computes through the frame's operations: the facet, the stat, the mapping and the scales. None of those parts knows about engines; each one just answers for itself, and a user-supplied stat can say yes too.

If any part says no, the layer's table is read into lists once, where it comes in, and drawn exactly as before. Today that happens with `facet_wrap` and `facet_grid`, a log or date axis, and a mapping that calls an Elixir function. The plot comes out the same either way. One just takes longer to get there.

## Lazy isn't free

The first numbers were good but strange. A count by class and group took 2.05 seconds on Explorer. Nearly all of that was spent reading results.

A lazy Explorer frame is a plan, not a table, and every read runs the plan again from the top. Read it 25 times as a layer works its way through, and you pay for every join 25 times. So the frame got one more callback, `materialize/1`, which Giggly calls where each stage ends: work the plan out once, keep the rows in Explorer, and go on from there. That count went from 2.05 seconds to 0.37. That's what Fig. 1 shows: between 18 and 25 times faster than lists.

## The last digit

Polars adds up a group on several threads at once, so the order it adds in changes from run to run, and so can the last digit. Usually nobody cares. But 0.1 added up 100 times in row order is 9.99999999999998, not 10, and a break sitting right on a scale's limit can appear or disappear.

So the engine's sums are held to a bound in tests instead of being checked digit by digit. The golden drawings that compare Giggly to ggplot2 stay on the list frame, where the order is fixed.

## Who's next

Explorer is the first engine, not the only one the contract was built for. The operations were kept relational from the start (filters, joins, grouped summaries) so that Dux, or a SQL database itself, could implement them without any of Giggly's stats or scales changing.

Dux would have been the natural second engine, but I've passed on it for now, for two reasons. First, it needs a process running, and I've tried to keep Giggly as pure as I can: values in, values out, nothing to start or supervise. That purity is a big part of what makes our [mutation testing](/posts/mutants-after-every-commit) remotely feasible. Second, testing against Dux would mean downloading DuckDB to run the tests, and I didn't want that either.

And if an engine goes away, nothing breaks. Every plot still draws on Giggly's own lists, only slower on a big table.
