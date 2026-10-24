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

Three causes, all in the scenario/fixture and harness layer — none in the
deck change under test.

1. **The per-turn output budget is smaller than the work the model does.**
   `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` is 4,000 on every surface
   (`with-test-home`'s `env -i` allowlist and `set-env.sh` export, the
   `docker_env` passthrough, and the classifier-home seeder). On this deck the
   model's *first* turn routinely exceeds it: in the 2657-sc3 RED the agent
   burned six generations (~24 minutes) deliberating a two-line heading
   addition and never reached the edit; in the 2657-sc1 GREEN it composed a
   complete specification, hit the cap three times, and ended with the final
   message truncated at 4,000 output tokens mid-sentence. The reasoning
   counter stays flat while the turn's token count climbs, so the bulk is
   text, not deliberation. Each capped turn is resumed by re-generating the
   same message, so a composition that cannot fit in one turn cannot
   complete. The harness names this condition and its remedy: *"a scenario
   whose legitimate turns routinely hit the cap is re-scoped at the spec (value
   raises are a one-line change to the four surfaces), never by model
   substitution (R-20)."* Raising the cap instead re-opens the unbounded-turn
   failure `#2646` set the 4,000 default to prevent.
   *Fix:* re-scope the scenarios so the criteria judge what the model
   actually does in the run it gets — the route it announces and the cards it
   loads — rather than artifacts it never writes. A spec-card revision,
   validated afresh, not an implementor-side change to an approved criterion.

2. **The fixture's repository state makes the branch card's trunk-tip
   verification ambiguous.** The harness's own `behavior_run` commits `init`
   onto the test project's `main`, and the per-scenario fixture commits the
   seed content on top, so `main` sits ahead of `origin/main`. The branch
   card's rule 2 says to verify the trunk tip before branching and to state
   it in the work record, and with the local branch ahead of the remote tip
   the agent cannot tell at a glance which tip the branch is cut from. The
   agent resolves it by reasoning: in the first 2657-sc3 RED, `git
   merge-base main origin/main; git log --oneline -8 main` was its last
   action for seven consecutive polls, with no edit. (A rebase does not
   discard the commits ahead of the remote tip — it replays them — so the
   cost here is the verification, not a conflict.) This is R-18's "fixture
   state" cause class.
   *Fix applied:* the fixture now moves `main` back to the remote tip and
   leaves the seed content staged, so the content is present and the
   divergence is not. Verified: `main` and `origin/main` are the same commit
   (0 ahead, 0 behind) and the agent reached the branch card in ten minutes
   instead of twenty-two, without the merge-base detour.

3. **A scenario with no declared goal condition cannot be judged, and
   cannot recover.** The §14 monitor's classifier is anchored on the
   scenario's `goal_condition`; with none declared it returns `undetermined`,
   the SC-8 determination gate then refuses the resume path, and a run that
   hits the cap dies where it stands. Observed in the first 2657-sc3 RED:
   three `FATAL: resume failed - no non-undetermined determination exists`
   lines, the monitor halting with `classification: undetermined`, and the
   orchestrator decision recorded as `terminate-with-root-cause` for
   "orphaned/left-running run processes" — a diagnosis that named the
   harness's own state, not the run's behaviour.
   *Fix applied:* each scenario now declares `BEHAVIOR_EXPECTED_ARTIFACT`,
   `BEHAVIOR_EXPECTED_ARTIFACT_GREP`, and `BEHAVIOR_GOAL_ACTIONS`. Verified
   on the post-fix 2657-sc3 RED: the monitor emitted no `undetermined`
   classification, no `FATAL: resume failed` line appeared, and the run was
   not halted by the monitor.

## Consequence for the criteria

- SC-6, SC-7 and SC-9 each require "a full-path spec artifact" in the run.
  Cause 1 explains why: the anchorless cap-hit resume made every capped turn
  re-derive the session's history and issue no tool call, so the run could
  not finish its artifact no matter how many resumes it got. R-13 is the
  remedy — the resume now carries the recorded tail, so a resumed turn
  continues the recorded work. **This record's original claim that the
  artifact is "not producible in this harness" was written before R-13
  landed and described the anchorless resume's effect, not a limit of the
  harness.** The re-runs decide it: if the artifact still does not appear, the
  three criteria are re-scoped at the spec (a smaller artifact) and the spec
  is revised and re-validated, per the harness's own rule — "a scenario
  whose legitimate turns routinely hit the cap is re-scoped at the spec".
- SC-6's instrument additionally fails to *discriminate* the two decks as
  written: both failed for artifact reasons rather than for the routing
  reasons the criterion is about. R-13 is what makes the routing observable
  in the run, so the criterion is judged from the re-run.
- SC-8 and SC-10 require no spec artifact, so they are measurable as
  instrumented — and with causes 2 and 3 fixed the monitor can conclude a
  run as soon as the criterion's decisive fact appears, rather than waiting
  out the model's deliberation.
- The deck change itself is not implicated in any of the three causes. In the
  SC-6 GREEN the new deck routed to the named stage in two polls with the
  developer's approval gate explicitly identified, where the pre-change deck
  spent the whole run on archaeology and a hunt for a skill that does not
  exist in the deck. In the SC-8 RED the pre-change deck's own words are the
  defect: *"Direct single-file change with the request as spec — short
  path."*
- The work card's length is **not** the verbosity driver, contrary to an
  earlier reading here: the pre-change 53-line card produced the same
  4,000-token first turn, so the model's deliberation on the deck prompt —
  not the size of the card this change rewrites — is what fills the budget.

## Suite-wide result

`bash .opencode/tests-v2/test-enforcement.sh` — 20 passed, 0 failed, 0
skipped. `./.opencode/tools/reference-integrity --scan` — PASS, 63 files, all
Read-links resolve.
