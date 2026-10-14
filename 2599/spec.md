number: 2599
title: "[BUG] skildeck validate flags MISSING_DISPATCH_TABLE on all 35 skill cards — deck-wide pre-existing finding"
state: OPEN
labels: [needs-approval, bug, spec]
---

# [BUG] skildeck validate flags MISSING_DISPATCH_TABLE on all 35 skill cards — deck-wide pre-existing finding

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | `skildeck validate` reports MISSING_DISPATCH_TABLE for every SKILL.md in the deck (35/35) — a deck-wide false red on a conforming deck. The finding surfaced 2026-10-13 during .opencode#2551 PR prep and is pre-existing on trunk (identical 35 findings at baseline 05eba9bb); #2551's PR prep passes through it only via this filed fix issue per the suite-green rule. The instrument demands a `## Trigger Dispatch Table` heading with a four-column table (`User says / Context`, `Task`, `Dispatch`, `Context passed`) in every skill card — a card shape the deck retired. |
| 2 | **Root Cause / Motivation** | Three causes, each verified against the repository on 2026-10-14: (1) The validator enforces the pre-rip deck's per-card trigger-dispatch-table standard. It was created 2026-06-15 (.opencode#1213, c6539d82) when 39 pre-rip cards carried the heading (verified by `git grep` at that commit); the #2490 rip-and-replace (stage 1, 6dbac1ae) moved the old deck to `attic/` and installed the current deck, in which zero cards carry the heading — routing is centralized in `routing.md` and per-card dispatch travels in the platform-presented frontmatter descriptions. (2) The #2490 skildeck alignment was incomplete: stage 4a (08112303, 2026-10-04) removed the retired dispatch-format machinery from `skildeck-lint` but never touched `skildeck-validate` — the script's git history is a single commit, its creation. (3) The stale check is wired into no automated gate — no hook, test, or CI reference exists (verified by repo-wide search) — so its staleness stayed silent until the manual run during #2551 PR prep, where its false red then obstructed the suite-green gate. |
| 3 | **Approach Chosen** | Retire the validate action (the developer-endorsed triage recommendation). The implementer removes every occurrence of the `validate` action from the dispatcher `tools/skildeck` — the ACTIONS mapping entry, the docstring's Actions line, and the usage example — and deletes `tools/impl/skildeck/skildeck-validate`. No replacement check is added: the card-shape facts `skildeck-lint` already checks (frontmatter at line 1; required `name` and `description`; `provenance` recognized) leave the dispatch-table check with no current standard to enforce — the deck's live governance requires no per-card dispatch table (verified: no dispatch-table requirement exists anywhere in the live deck), so the check's target standard does not exist in the current deck. How each cause is answered: (1) and (2) — the retired-standard instrument no longer exists on any live tool surface (SC-1, SC-2, SC-3); (3) — the false-red-on-manual-run failure class disappears because the action fails closed as unknown (SC-4), and no new gate is added because the retired standard has no successor to enforce. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Cards adopt the dispatch-table structure the validator enforces — discarded: it re-creates the machinery #2490 deliberately retired, is deck-wide churn across 35 governed files requiring deck governance per card, and the triage evidence shows the cards conform to the current deck standard. (b) Repurpose the validator to check the current card standard — discarded: the card-shape checks the current standard consists of (frontmatter at line 1; required `name` and `description`) are already owned by `skildeck-lint`; a second checker duplicates that ownership, and the dispatch-table standard the check was built for has no successor requiring a new one. (c) Keep validate and silence it via `.skilldeck-ignore` — not viable: `skildeck-validate` reads no ignore file (verified from its source), and a check that is permanently red on a conforming deck is not a check. (d) Retire the whole skildeck tool — discarded: exceeds the stated problem. The observed failure implicates only `validate`; `lint` is consumer-backed (the completeness test invokes it), and `verify-acceptance`/`verify-issue` are standalone actions of the surviving tool with no observed failure against them. |
| 5 | **Key Design Decisions** | (1) Clean break, not deprecation: the dispatcher is an internal agent tool with zero external consumers (verified by repo-wide search), so removal leaves no compatibility surface to preserve — internal refactors take clean breaks. (2) Deletion, not archival under `attic/`: `attic/` preserves the pre-rip deck, not dead tooling; the script's full content remains recoverable from git history, which is the archive mechanism for deleted tool code. (3) The behavioral SCs are direct command executions against the dispatcher — the tool is a script, so scripting its behavior is the honest instrument; no agent-behavior harness is warranted for a CLI surface with no model in the loop. (4) Zero deck-content change: no skill card, guideline, `floor.md`, or `routing.md` byte changes; the fix is entirely in the tool layer. |
| 6 | **User Intent / Original Prompt** | "I don't understand .opencode#2599, triage" → triage delivered 2026-10-14: validator-side, not card-side; the validator enforces a standard #2490 retired; recommended retiring the validate action over re-adopting dispatch tables or repurposing the check → "convert to spec per recommendation" (this spec). |

## 2. Not Included

- `skildeck-lint` — already aligned with the current deck by #2490 stage 4a; no change.
- `skildeck-verify-acceptance` and `skildeck-verify-issue` — verified free of dispatch-table content; untouched.
- Any new structural check replacing validate — no consumer mandates one; adding one is scope creep.
- The skill cards, `routing.md`, `floor.md`, any guideline — zero deck-content change.
- `tests-v2/test-skill-deck-completeness.sh` and the behavior fixtures — they exercise `skildeck lint` only; nothing references the retired action.
- The `.issues/` store's records of the triage and this spec — they name the retired action as history, not as consumers; untouched. (Verified: outside the store, the only working-tree matches for `skildeck-validate` / `skildeck validate` are the dispatcher and the script this change itself removes.)

## 3. Success Criteria

All structural except SC-4, SC-5 — runtime effects of the dispatcher, verified by direct command execution. Paths are submodule-relative (repository root `.opencode/`).

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The dispatcher `tools/skildeck` contains no occurrence of the `validate` action: the ACTIONS mapping declares no `validate` key, and the docstring's action list and usage examples no longer name `validate`. | structural | Read the dispatcher file; confirm absence of `validate` as an action definition and in the docstring action list and examples |
| SC-2 | `tools/impl/skildeck/skildeck-validate` does not exist. | structural | File-existence check on the path |
| SC-3 | No live consumer of the retired action remains in the submodule: a working-tree search for `skildeck-validate` and `skildeck validate` returns matches only within the `.issues/` store's historical records. Every match outside the store is a finding. | structural | Repo-wide content search over the submodule working tree; confirm every match lies within `.issues/` |
| SC-4 | Invoking the retired action fails closed: `./.opencode/tools/skildeck validate` exits non-zero with the unknown-action error naming the available actions. | behavioral | Run the dispatcher with the retired action name; observe non-zero exit and the error naming the surviving actions |
| SC-5 | `./.opencode/tools/skildeck lint` runs post-change and reports 0 findings on the deck as of 2026-10-14 — the observed pre-change state is preserved. | behavioral | Run `skildeck lint`; confirm 0 findings and exit 0 |
| SC-6 | The dispatcher's ACTIONS mapping declares exactly the surviving actions — lint, verify-acceptance, verify-issue — and each action's script exists under `tools/impl/skildeck/`. | structural | Read the ACTIONS mapping; file-existence checks on the three scripts |

### Cost Frame

The change is two file operations — one dispatcher edit, one file deletion — with zero deck-content growth and zero floor growth. Four SCs are file facts; two are single-command executions with no harness provisioning. Rollback is a single git revert: the deleted script's content lives in commit history, so the operation is fully reversible and no data-loss scenario exists. No behavioral test scenario is authored — the runtime checks are direct CLI executions, the same instruments this issue's triage evidence used.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
