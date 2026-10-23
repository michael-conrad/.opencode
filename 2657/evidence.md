# Behavioral evidence record — .opencode#2657

Execution record for the behavioral success criteria SC-6, SC-7, SC-8. Each
run's artifacts are under `tmp/behavioral-evidence-<scenario>-<phase>-<model>/`
in the project root, with the clean-room evaluator's verdict written into the
same directory as `evaluation-<timestamp>.yaml`. Every verdict below comes
from the evaluator's reading of `session.yaml` (the primary evidence source),
not from a file-existence or string check.

## Runs completed

| Criterion | Phase | Scenario | Deck | Verdict | Artifact directory |
|---|---|---|---|---|---|
| SC-6 | RED | `2657-sc1-stage-request-runs-stage` | pre-change `a1fb61c6` | **FAIL** (the criterion's positive fact absent) | `tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-RED-ollama-qwen3.8-27b-256k-gguf4` |
| SC-7 | RED | `2657-sc2-complicated-change-full-path` | pre-change `a1fb61c6` | **FAIL** (no spec artifact; the short-path route taken with the ambiguity seen and declined) | `tmp/behavioral-evidence-2657-sc2-complicated-change-full-path-RED-ollama-qwen3.8-27b-256k-gguf4` |
| SC-6 | GREEN | `2657-sc1-stage-request-runs-stage` | new `85c525e3` | **FAIL** (routing correct; the artifact still not produced — see cause analysis) | `tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4` |
| SC-8 | RED | `2657-sc3-short-path-collapsed-form` | pre-change `a1fb61c6` | concluded before the edit landed (see cause analysis) | `tmp/behavioral-evidence-2657-sc3-short-path-collapsed-form-RED-ollama-qwen3.8-27b-256k-gguf4` |

## What the REDs establish

**SC-6 (RED).** The pre-change deck produced the spec stage's *route* and not
its *artifact*. The evaluator's tool census: no `write`, `edit`, or `patch`
call anywhere in the run; the only non-empty assistant text parts defer the
write ("before writing the spec", "before writing anything"); the final step
ends `reason: "length"` with zero tool calls. The agent loaded the `work` and
`spec` cards, read the store's issue directory, the validation-standards
reference, and hunted for an `approval-gate` skill that does not exist in the
deck — roughly twenty tool calls of archaeology — and never wrote the spec.
`src/upload.py` was only read, so the criterion's no-implementation half held.

**SC-7 (RED).** The pre-change deck classified a one-line, materially
underspecified request as the short path, in the agent's own words: *"The
`work` card routes this as a direct developer order — single file
(`src/search.py`), short path: branch → implement → verify"*. The `spec` and
`explore` cards were never loaded. Decisively, at seq=174 the agent's
reasoning *identified* the open material choices the criterion is about —
"which documents, what match semantics, where does the cache live, TTL,
invalidation" — weighed halting ("*Hmm, but is it really ambiguous enough to
warrant halting?*") and decided against it, then branched
`feature/search-caching` and loaded the `implement` card. The deck let the
agent see the ambiguity and talk itself out of it.

## What the GREEN establishes

**SC-6 (GREEN).** The new deck's routing is right, in the agent's own words:
*"I've confirmed that a full-path specification is required before any
implementation, with an explicit human gate for developer approval."* It
reached the spec card within two polls of the prompt, against the pre-change
deck's thirty-plus polls of exploration. The stage's artifact, however, was
never written: the final assistant message ended `reason: "length"` with
4,000 output tokens and only a reasoning part, cut off mid-sentence while
drafting the spec's success criteria, and the harness's cap-resume ceiling
(3) was exhausted.

## R-18 cause analysis (tests-v2/AGENTS.md §17)

Two causes, both in the scenario/fixture and harness layer — neither in the
deck change under test.

1. **The spec-stage artifact exceeds the harness's per-turn output budget.**
   `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` is 4,000 on every surface
   (`with-test-home`'s `env -i` allowlist and `set-env.sh` export, the
   `docker_env` passthrough, and the classifier-home seeder). The spec card
   requires a complete specification, and the model composes it in one turn:
   the reasoning counter stays flat while the turn's token count climbs, so
   the bulk is the specification *text*, not deliberation. Each capped turn is
   resumed by re-generating the same message, so a composition that cannot
   fit in one turn cannot complete — the run exhausts the resume ceiling with
   no artifact. The harness names this condition and its remedy:
   *"a scenario whose legitimate turns routinely hit the cap is re-scoped at
   the spec (value raises are a one-line change to the four surfaces), never
   by model substitution (R-20)."* Raising the cap instead re-opens the
   unbounded-turn failure `#2646` set the 4,000 default to prevent.
   *Fix:* re-scope the scenarios that require a spec artifact so the artifact
   is brief enough to fit the budget — a spec-card revision, validated
   afresh, not an implementor-side change to an approved criterion.

2. **The fixture's repository state trips the branch card's rebase rule.**
   The harness's own `behavior_run` commits `init` onto the test project's
   `main`, and the per-scenario fixture commits the seed content on top, so
   `main` sits ahead of `origin/main`. The branch card's rule 2 says to
   "sync and rebase if the trunk moved", and a rebase would discard the
   fixture's seed content. The agent resolves that conflict by reasoning
   about it for ten-plus minutes — in the SC-8 RED, `git merge-base main
   origin/main; git log --oneline -8 main` was its last action for seven
   consecutive polls. This is R-18's "fixture state" cause class, and it is
   this scenario's own fixture design.
   *Fix:* make the fixture's seed state not present as a local divergence
   from the remote tip, so the branch card's rebase path never fires.

## Consequence for the criteria

- SC-6, SC-7 and SC-9 each require "a full-path spec artifact" in the run.
  Under cause 1 that artifact is not producible in this harness with the
  default model, so those three criteria are not measurable as instrumented.
  SC-6's instrument additionally fails to *discriminate* the two decks: both
  fail for artifact reasons rather than for the routing reasons the criterion
  is about, which is a second, independent argument for re-scoping it.
- SC-8 and SC-10 require no spec artifact, so they are measurable as
  instrumented once cause 2 is fixed.
- The deck change itself is not implicated in either cause: in the SC-6 GREEN
  the new deck routed to the named stage in two polls with the developer's
  approval gate explicitly identified, where the pre-change deck spent the
  whole run on archaeology and a nonexistent-skill hunt.

## Suite-wide result

`bash .opencode/tests-v2/test-enforcement.sh` — 20 passed, 0 failed, 0
skipped. `./.opencode/tools/reference-integrity --scan` — PASS, 63 files, all
Read-links resolve.
