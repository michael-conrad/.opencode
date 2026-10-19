# Bound dispatch practice for short-path work — amend the `implement` card's dispatch-judgment rule

## Summary

During `.opencode#2639` behavioral verification (SC-7), five tier-2 harness attempts showed a recurring failure shape: single large-context dispatches intermittently degenerate into unbounded reasoning blocks. The bounded-freshness provision shipped by #2639 (`git-workflow-branch` rule 2) verified effective at its target — the freshness/store-verification stall cleared and the run agent reached the branch decision with correct one-scope framing (attempt 5: 80 tool calls, all pipeline cards loaded). But the stall relocated downstream: the implementation sub-dispatch (a ~52k-token-context sub-agent for a three-file short-path fix) generated ~4,140 tokens over ~17 minutes without completing or flushing, and the run was aborted at the pre-declared line. The same shape was observed in earlier attempts at other dispatch points (4,100–6,000+ token turns; preserved diagnosis records cited under Evidence).

The fix: `implement`'s dispatch-judgment rule gains an inline-by-default provision for short-path work — the default is working in the agent's own context; a sub-agent dispatch for short-path work requires a scoped reason recorded in the work state.

## Developer statements (provenance)

- D1 (2026-10-19): the developer directed the #2639 fix at the deck/spec/plan level ("no changing the model. you must fix the deck/spec/plan"), grounding the bounded-freshness amendment; the residual dispatch stall discovered by that fix's verification run is the observed failure this spec hardens.
- D2 (2026-10-19): the developer directed stacking this issue onto #2639's branch ("stack .opencode#2645") — the authorization basis for this spec and its pipeline.

## Root cause

1. **Unbounded dispatch judgment.** `implement` rule 9 reads "Sub-agents are judgment, not ritual. Dispatch one when a scoped task genuinely benefits; work inline when that is simply better." Nothing bounds the context a dispatch carries or states the short-path default; the run agent filled the gap by dispatching full-deck-context sub-agents for trivial work — three consecutive dispatches at 51k/55k/52k tokens observed in attempt 5 — and each large dispatch is a fresh opportunity for the runaway shape the runs documented.
2. **Runaway recurrence by dispatch count.** The five #2639 attempts show the degenerate turn is not tied to one deck surface: it appeared at the freshness pass (attempts 1–4, since fixed by R-7 there), at turn-1 openers, and at implementation dispatches. What the occurrences share is a large-context single generation. Reducing the number of large-context dispatches on short-path work reduces the exposure.

## Evidence

- Semantic-diagnosis records from the #2639 SC-7 runs, preserved at `tmp/issue-2639/artifacts/sc7-attempt1/`, `sc7-attempt4/`, and `sc7-attempt5/` (attempts 2 and 3 were aborted and their raw records removed in session cleanup; their shape is characterized by the cross-attempt summary in attempt 4's `semantic-diagnosis.md`).
- Attempt 5's record: the implementation dispatch (task 14920, ~52.5k-token context) generated ~4,140 tokens over ~17 minutes with no completion; killed at the pre-declared line.

## Approach

Amend `implement` rule 9 in place: after the existing judgment sentence, state the short-path default (inline) and the recorded-reason escape for dispatching on short-path work. The card's existing triggers already fire at implementation start, so no description change or new routing surface is needed. Full-path work keeps its existing clean-room dispatch practice untouched.

Predicate classification (skill-creator admission gate #4): intent-decidable — the inline-vs-dispatch judgment is exactly what scripts must not decide; the rule text directs judgment. No enforcement script.

Governance posture (admission gate): observed failure = the #2639 run records (D1); consumer = every session at implementation start; mechanism/trigger = the card's existing load trigger, unchanged; domain match = the failure is from this deck's own behavioral verification; root-agnostic = the amended text carries no repo names or absolute paths; what-it-replaces = the amendment replaces unbounded dispatch latitude on short-path work with a stated default — a net addition of a few sentences, displacing no content.

## Requirements

- R-1. `implement` rule 9 SHALL state that for short-path work (developer-specified small changes with no success-criteria machinery), the default is working inline in the agent's own context; a sub-agent dispatch for short-path work requires a scoped reason recorded in the work state.
- R-2. The amendment SHALL be confined to rule 9 of the `implement` card: every other clause of the rule and card SHALL survive unchanged, each of the card's two provenance lines (frontmatter `provenance:` and the HTML provenance comment) SHALL gain one provenance entry per deck convention, and the amended text SHALL stay root-agnostic — no repo names, no absolute paths.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | `implement` rule 9 states the short-path inline default with both elements — the default (inline in the agent's own context for short-path work) and the escape (a sub-agent dispatch requires a scoped reason recorded in the work state) (R-1). | structural | Read the amended rule text; assert both elements are stated. |
| SC-2 | The amendment is confined to rule 9 with the deck's invariants preserved (R-2). | structural | Diff the amended card against its trunk state: removed or rewritten lines are confined to rule 9; every other clause appears unchanged in the diff context; each of the two provenance lines gains exactly one new entry; the amended text contains no repo names and no absolute paths. |

The structural criteria are content checks run against the amended file. No behavioral SC is added: the defect this amendment targets is observable only through the #2639 harness instrument, whose SC-7/SC-8 runs (on the same stacked branch) exercise the amended card directly — the stacked verification covers the behavioral surface without duplicating an instrument.

## Impact

- **Consumers**: every session executing implementation work; short-path sessions get the inline default, full-path sessions are unchanged.
- **Blast radius**: one card body, rule-level text only; provenance line gains one entry; no description changes, no floor changes. The card is a submodule file; the submodule pointer rides with a real parent-repo change per submodule pointer discipline.
- **Risk**: under-dispatching — a short-path task that genuinely benefited from a clean-room dispatch now needs a recorded reason; the escape exists and costs one line of work-state prose.

## Out of scope

1. Dispatch practice for full-path work — the observed failure is on short-path; full-path clean-room dispatch stays as-is.
2. Model or harness changes — excluded by developer direction (D1); the instrument runs on the single-source default model.
3. Retrospective work in the #2639 run records — they are evidence, not remediation targets.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
