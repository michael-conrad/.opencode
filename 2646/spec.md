# Bound per-turn generation in behavioral runs — output-token cap in the tests-v2 harness

## Summary

Six tier-2 behavioral runs for `.opencode#2639` SC-7 documented a recurring run-fatal shape: a single generation turn intermittently produces an unbounded reasoning block — 4,100–6,000+ tokens over 5–19 minutes with no tool-call flush — and the run dies there, at a different position every run (turn 1, mid-pipeline turns, implementation dispatches). Two deck fixes shipped on the #2639 branch (bounded trunk-freshness verification; short-path inline default) each verified effective at their target surfaces, and the stall relocated rather than disappeared: the only invariant across all six stalls is the model generating unbounded output within one turn against the deck-heavy context. The fix is at the harness layer — bound per-turn output for behavioral runs via opencode's `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` runtime flag, which the pinned binary (1.18.3) feeds into `maxOutputTokens` of every assistant generation. The model is unchanged; the runtime config bounds each turn the same way the bash-tool timeout bounds execution.

## Developer statements (provenance)

- D1 (2026-10-19): "no changing the model. you must fix the deck/spec/plan" — the model stays the single-source default (R-20); fixes land at the deck/spec/plan level.
- D2 (2026-10-19): after the sixth blocked attempt, "revise/add spec as needed to address the defect, then stack into existing feature branch" — the authorization for this spec and its stacking onto `feature/2639-scope-boundary-stacked-pr`.

## Root cause

1. **Unbounded per-turn generation.** The seeded test environment sets no per-turn output bound; opencode's own default (`SessionPrompt.OUTPUT_TOKEN_MAX`, 32k) is far above the turn sizes the harness's monitoring mandates assume (~2,300-token completed turns are the observed norm), so a degenerate reasoning block can run for many minutes before anything observes it. Verified against the pinned binary: `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` is parsed (positive-integer, optional) and flows into `maxOutputTokens` per generation (binary strings evidence, 2026-10-19).
2. **Relocating stall, constant mechanism.** The six #2639 attempt diagnoses show the runaway is not tied to any one deck surface (freshness verification, implementation dispatch, turn-1 opener all hosted it at least once). Deck-side fixes reduced the surfaces; the per-turn bound removes the mechanism itself.

## Evidence

- Six semantic-diagnosis records: `tmp/issue-2639/artifacts/sc7-attempt1/`, `sc7-attempt4/`, `sc7-attempt5/`, `sc7-attempt6/` (attempts 2 and 3 were aborted and their raw records removed in session cleanup; their shape is characterized by the cross-attempt summary in attempt 4's `semantic-diagnosis.md`).
- Degenerate turns observed: ~4,100 tokens/13 min (attempt 4 turn 1, completed); 22k flushed reasoning chars/0 tools/8.5 min (attempt 2); ~5,200 tokens/12 min (attempt 3 turn 1); ~6,030 tokens/19 min (attempt 4 turn 5); ~4,140 tokens/17 min dispatch (attempt 5); ~4,360 tokens/15 min (attempt 6 turn 3).
- Binary verification (2026-10-19): `strings .tools/opencode/opencode` shows `outputTokenMax:G("OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX")` and `maxOutputTokens:be.maxOutputTokens(e.model,e.flags.outputTokenMax)`; `--version` reports 1.18.3.

## Approach

Set `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=4000` for behavioral runs at every env surface the harness controls: the `with-test-home` `env -i` allowlist and its `set-env.sh` debug export, the Docker-tier `docker_env` passthrough in `docker-harness.sh`, and the §14 classifier-home seeder in `behaviors/helpers.sh` (parity). Document the cap in `tests-v2/AGENTS.md` (§5 infrastructure details and the §14/§17 monitoring context): a turn that hits the cap ends with a length finish and the session continues next turn — the harness's existing supervision observes normal cadence again. 4,000 tokens sits above the ~2,300-token completed-turn norm with headroom for tool-call JSON, and hard-bounds every degenerate shape observed. No isolation contract change: the env allowlist gains one entry, not a credential.

Predicate classification (skill-creator admission gate #4): fact-decidable — the cap's presence and value are file/env facts; a script may assert them. The cap's adequacy for a given scenario remains judgment (§17), never scripted.

Governance posture (admission gate): observed failure = the six #2639 run records (D1's fix directive + D2's stacking directive); consumer = every behavioral run through `behavior_run`/`with-test-home`; mechanism/trigger = existing harness load paths, unchanged; domain match = the failure is from this harness's own runs; root-agnostic = the amendment names no repo or absolute paths beyond the harness's own; what-it-replaces = the cap replaces the implicit 32k ceiling with an explicit harness-chosen bound — a bounded default displacing an unbounded one.

## Requirements

- R-1. The behavioral-run environment SHALL set `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=4000` at every surface the harness controls: the `with-test-home` `env -i` allowlist, the `set-env.sh` debug export, the Docker-tier `docker_env` passthrough, and the §14 classifier-home seeder in `behaviors/helpers.sh`.
- R-2. `tests-v2/AGENTS.md` SHALL document the cap in the infrastructure-details section: what it bounds (per-generation output, fed to `maxOutputTokens`), the value, the finish-then-continue behavior on hitting it, and its relationship to the §14 supervision mandates (a cap hit is observed as normal turn cadence, not an abort signal).
- R-3. The change SHALL NOT alter the isolation contract (no credential passthrough, no new mount, no model substitution — `DEFAULT_TEST_MODEL` remains the single source of truth) and SHALL NOT alter the env allowlist beyond this one entry.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | All four harness env surfaces carry the cap with value 4000 (R-1). | structural | Grep the four files for `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` with `4000`; assert all four hit. |
| SC-2 | `tests-v2/AGENTS.md` documents the cap per R-2 (bound semantics, value, finish-then-continue behavior, supervision relationship) (R-2). | structural | Read the added documentation; assert all four elements are stated. |
| SC-3 | The isolation contract is unchanged apart from the one allowlist entry, and the default model is unchanged (R-3). | structural | Diff the touched harness files against their pre-change state: the only env-related additions are the cap lines; `default-model.sh` is untouched; no `-e`/allowlist entry other than the cap is added. |
| SC-4 | A behavioral run under the capped environment completes turns at bounded length — a live `opencode run` in the harness produces session evidence where no single generation turn's output exceeds the cap (R-1 effect). | behavioral | tests-v2 scenario run (the stacked #2639 SC-7 scenario re-run serves as the instrument); assert from `session.yaml`/ollama service log that turns complete and none runs unbounded past the cap. |

SC-4's instrument is the existing stacked #2639 SC-7 scenario — the cap's effect is verified by the same run that verifies the deck amendments; no separate scenario is authored.

## Impact

- **Consumers**: every behavioral run (tier-2 and tier-3) through `with-test-home`/`behavior_run`; the §14 monitor and supervisor observe bounded turn cadence.
- **Blast radius**: three harness files plus the harness spec documentation; no isolation change; no model change; no scenario script change.
- **Risk**: truncation — a turn that legitimately needs more than 4,000 output tokens ends early and continues next turn; for the short-path scenarios in scope this is acceptable and observable. A cap too low would thrash long file writes — 4,000 is chosen above the observed completed-turn norm; raising it is a one-value change.

## Out of scope

1. Model substitution or `DEFAULT_TEST_MODEL` changes (R-20; D1).
2. The §14 monitor's early-death defect (dies after poll 2) — a separate harness defect, unfiled here; noted for a future ticket.
3. Deck card wording beyond what #2639/#2645 already ship.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
