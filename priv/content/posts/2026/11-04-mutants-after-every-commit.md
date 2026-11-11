%{
  title: "Filthy Mutants",
  description: "One of the more interesting parts of our toolset is mutation testing - I think it's making our library better, but it's not cheap.",
  residents: [:giggly],
  tags: ["testing", "agents", "mutation-testing"]
}
---
Like most folks in 2026, I have spent a lot of time polishing the tools I use to try to manage the LLM that does my coding. Giggly relies on several skills, a few hooks, static analysis tools like credo and sobelow and the `boundary` package. I'll get to each of them in future posts. This one is about the one that I still don't totally get: mutation testing, using the muex package.

## What it is

Mutation testing breaks the code one small edit at a time, swapping `==` for `!=` or deleting a function clause, and reruns the suite against each broken copy. A mutant the tests catch is "killed." One that "survives" is a change in behaviour nobody noticed.

I initially thought of this as a way to find junk tests - if you change code and the test doesn't find it - that's a bad test right? Maybe, but what is more likely to happen is that you will find error conditions that your tests don't cover. And you occasionally find bugs, period.

## What it seems to be good for

As of this writing, 121 commits so far have acted on a mutation pass, and 78 of them changed the library, not just its tests. Most of those cut a dead branch or a redundant guard. Some fixed real bugs: 

- **Box plots vanished when you zoomed.** If `xlim()` cut through one side of a box, Giggly dropped the whole box. R draws what's left.
- **Histograms crashed on a log axis.** A break at 0 became a bin of infinite width. R draws it.
- **Axis breaks crashed on ranges R draws fine**, like 321908391.83 to …838. Checking against R across 3,505 ranges turned up 19.
- **A smooth through perfectly straight data crashed.** The sum of squares came out at −6e-16, and its square root raised.
- **One infinite value emptied a whole 2D density panel.** R just drops that row.

At least two of those weren't found by the mutant itself. It identified missing test coverage, and the added tests surfaced the bug. Claude provide the numbers above - I'd just add that my gut feeling is that there are four or five real findings per commit that result in added tests, and maybe one bug per two commits.

## The downsides 

**Time.** Muex is re-running your whole test suite hundreds of times. And (at least according to Claude) it is spinning up a new BEAM instance each time. This can take forever. It has various knobs one can use to limit the scope of the mutation testing, but in my experience anything that made it not interminable didn't find much. Claude had the interesting idea to rewrite the test runner to re-use warm VMs, since Giggly is purely functional. That cut the time down significantly. I wish I understood the inner workings well enough to extract that behavior and contribute it back to the libary. It cut the time down from hours to minutes. 

**Noise.** There are a ton of false positives. For example, it might re-order the keys in a map and say, "look, nothing raised!" which of course is pointless because key order doesn't mean anything for Elixir maps. 10-20% false positive rates are the norm. Claude triages the report; I'm not quite sure how much work it would be if you had to go through it yourself. 

**Resources** On my machine we spin up one VM per core and it fills them up. I like to have a few sessions spun up and working and that is a struggle whenever one of them starts a mutation pass. Running a test suite in another session that fails on a timeout somewhere suddenly becomes roll of the dice.

## Why I keep using it 

One thing I've learned as we built Giggly was the degree to which ggplot2 will accept weird inputs and do unexpected things with them. I think that probably is unavoidable given the scope of its potential inputs and outputs. My sense is that the added coverage I get from employing mutation testing will help Giggly avoid those outcomes more often that ggplot2 is able to.