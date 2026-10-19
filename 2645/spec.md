## Problem

During `.opencode#2639` behavioral verification (SC-7), five tier-2 harness attempts showed a recurring failure shape: single large-context dispatches intermittently degenerate into unbounded reasoning blocks. The bounded-freshness provision shipped by #2639 (git-workflow-branch rule 2) verified effective at its target — the freshness/store-verification stall cleared and the run agent reached the branch decision with correct one-scope framing (attempt 5: 80 tool calls, all pipeline cards loaded). But the stall relocated downstream: the implementation sub-dispatch (a ~52k-token-context sub-agent for a three-file short-path fix) generated ~4,140 tokens over ~17 minutes without completing or flushing, and the run was aborted at the pre-declared line. The same shape was observed in earlier attempts at other dispatch points (4,100–6,000+ token turns; five semantic-diagnosis records preserved under `tmp/issue-2639/artifacts/`).

The deck-side driver candidate: `implement`'s "sub-agents are judgment, not ritual" leaves the dispatch-size judgment entirely to the agent, and nothing bounds the context a dispatch carries. For trivial short-path work the agent dispatched a full-deck-context sub-agent (three consecutive dispatches at 51k/55k/52k observed in attempt 5) instead of working inline — each such dispatch is a fresh opportunity for the observed runaway.

## Scope

- A deck amendment bounding dispatch practice at the implement/short-path decision point (candidate surface: `implement` card, dispatch-judgment rule), so trivial work runs inline instead of through full-deck-context sub-dispatches.

## Requirements

- R-1. `implement` SHALL state that for short-path work (developer-specified small changes with no success-criteria machinery), the default is working inline in the agent's own context; a sub-agent dispatch for short-path work requires a scoped reason recorded in the work state.
- R-2. The amendment SHALL stay root-agnostic and carry provenance per deck convention.

## Impact

- Consumers: every session executing short-path implementation work.
- Risk: low — the rule states a default with a recorded-reason escape, not a prohibition.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2645
> Agent-facing artifacts pointer: `.issues/2645/`
