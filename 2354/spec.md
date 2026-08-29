> **Full spec and artifacts: [`.opencode#2354/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2354/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2354/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Condense 117-session-trigger-behavior.md — move suppression detail

## Problem

The preloaded Tier 1 guideline `.opencode/guidelines/117-session-trigger-behavior.md` costs ~1.9k tokens of preloaded context on every session. Roughly 30% of that content is procedural guidance — the self-simulation prohibition prose, the trigger behavior map, and the suppression rule — that agents do not need preloaded at all times. Every session pays this token cost whether or not the procedural detail is exercised.

## Root Cause / Motivation

The guideline was written as a single always-preloaded document, mixing two distinct classes of content: (1) the always-required enforcement core (the nested_opencode_fatal hard-halt and the session-trigger no-echo mandate) and (2) context-heavy procedural detail (self-simulation prohibition prose, trigger behavior map, suppression rule) that is only needed when an agent is actively handling triggers or routing pair-mode behavior. Because both classes share one preloaded file, agents pay the token cost of the procedural detail on every session even when it is irrelevant. The fix is to separate the two classes: retain the enforcement core preloaded and relocate the procedural detail to the components that own the relevant behavior.

## Approach Chosen

Condense `.opencode/guidelines/117-session-trigger-behavior.md` to retain only the enforcement core (nested_opencode_fatal hard-halt and no-echo mandate), and relocate the procedural detail to its owning components: the self-simulation prohibition prose and suppression rule move to `.opencode/plugins/session-enforcement.ts`, and the pair_mode_resume trigger behavior map moves to the `git-workflow` pair-mode-resume task. The hard-halt core is preserved verbatim so the always-required enforcement signal is never weakened. Cross-references are updated to point to the relocated homes, and the existing `test-2134-sc*.sh` content-verification tests that assert the removed content are reconciled so the enforcement suite continues to pass.

## Alternatives Considered & Why Discarded

- **Delete the procedural content outright.** Discarded — the self-simulation prohibition, suppression rule, and trigger behavior map encode real agent behavior. Deleting them would lose enforcement signal and regress the behavioral guarantees they provide. Relocation (not deletion) preserves the content while removing it from the always-preloaded path.
- **Leave the guideline unchanged.** Discarded — this leaves the procedural detail in every session's preloaded context, which is the exact defect this spec exists to remove.

## Key Design Decisions

1. **Core retention verbatim.** The nested_opencode_fatal hard-halt and no-echo mandate remain preloaded and unchanged. Tradeoff: preserves zero-risk enforcement of the always-required behaviors at the cost of keeping ~1.3k tokens preloaded.
2. **Relocation to owning components.** Procedural detail moves to the component that already owns the relevant behavior (plugin for self-simulation/suppression, git-workflow for trigger routing). Tradeoff: agents that need the procedural detail must load it on demand from the relocated home rather than finding it preloaded.
3. **Test reconciliation is mandatory.** The 10 existing `test-2134-sc*.sh` tests assert removed content; they are updated or retired as part of this change. Tradeoff: additional implementation scope, but without it the enforcement suite breaks on the condensed guideline.

## User Intent / Original Prompt

Condense the preloaded `.opencode/guidelines/117-session-trigger-behavior.md` guideline by relocating its procedural (suppression / trigger-map / self-simulation) detail to the session-enforcement plugin / git-workflow while retaining the nested_opencode_fatal hard-halt core and the no-echo mandate preloaded, thereby reducing per-session token load without losing enforcement signal.

## Not Included

- **[Removing the nested_opencode_fatal hard-halt]** — The hard-halt core is the non-negotiable enforcement invariant and is retained verbatim, never removed or weakened.
- **[Changes to `session_context_triggers.py`]** — The trigger data source is unaffected; this spec changes behavioral guidance, not the emitter.
- **[Application or test code outside `.opencode/`]** — Blast radius is confined to the `.opencode` submodule; no `src/`, `test/`, or data changes.
- **[New behavioral trigger types]** — The trigger set (pair_mode_resume, nested_opencode_fatal) is unchanged; only its documentation location moves.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The condensed guideline `.opencode/guidelines/117-session-trigger-behavior.md` SHALL NOT contain the Self-Simulation Prohibition section. | string | `grep -q "Self-Simulation"` returns no match in the guideline |
| SC-2 | The condensed guideline SHALL NOT contain the Trigger Behavior Map section. | string | `grep -q "Trigger Behavior Map"` returns no match in the guideline |
| SC-3 | The condensed guideline SHALL NOT contain the Suppression Rule section. | string | `grep -q "Suppression Rule"` returns no match in the guideline |
| SC-4 | The condensed guideline SHALL retain the Session Trigger No-Echo section. | string | `grep -q "No-Echo"` returns a match in the guideline |
| SC-5 | The condensed guideline SHALL retain the nested_opencode_fatal hard-halt section. | string | `grep -q "nested_opencode_fatal"` returns a match in the guideline |
| SC-6 | The self-simulation prohibition detail SHALL be preserved in `.opencode/plugins/session-enforcement.ts`. | string | `grep -q "Self-Simulation"` returns a match in `.opencode/plugins/session-enforcement.ts` |
| SC-7 | The suppression rule detail SHALL be preserved in `.opencode/plugins/session-enforcement.ts`. | string | `grep -q "Suppression"` returns a match in `.opencode/plugins/session-enforcement.ts` |
| SC-8 | The pair_mode_resume trigger behavior detail SHALL be preserved in the git-workflow pair-mode-resume task. | string | `grep -q "pair_mode_resume"` returns a match in `git-workflow-branch/tasks/pair-mode-resume.md` |
| SC-9 | The cross-reference in the `Pair Mode Suggestion Protocol` section of `.opencode/guidelines/116-pair-mode.md` SHALL point to `git-workflow-branch/tasks/pair-mode-resume.md`. | string | `grep -n "trigger behavior map"` in 116-pair-mode.md resolves to a Read-link to `git-workflow-branch/tasks/pair-mode-resume.md`, not to 117 |
| SC-10 | The `test-2134-sc*.sh` content-verification suite SHALL pass against the condensed guideline with zero failures. | behavioral | run `bash .opencode/tests-v2/test-2134-sc*.sh` and assert every script exits 0 |
| SC-11 | A behavioral run with a NESTED_OPENCODE_FATAL block in the first user message SHALL produce a HALT. | behavioral | `with-test-home opencode run` against a real model, assert HALT via stderr evidence |
| SC-12 | A behavioral run with a SESSION_TRIGGERS block SHALL NOT echo the trigger content verbatim. | behavioral | `with-test-home opencode run` against a real model, assert no verbatim echo via stderr evidence |

## Requirements

- R-1. The condensed guideline SHALL NOT contain the Self-Simulation Prohibition section.
- R-2. The condensed guideline SHALL NOT contain the Trigger Behavior Map section.
- R-3. The condensed guideline SHALL NOT contain the Suppression Rule section.
- R-4. The condensed guideline SHALL retain the Session Trigger No-Echo section.
- R-5. The condensed guideline SHALL retain the nested_opencode_fatal hard-halt section.
- R-6. The self-simulation prohibition detail SHALL be preserved in `.opencode/plugins/session-enforcement.ts`.
- R-7. The suppression rule detail SHALL be preserved in `.opencode/plugins/session-enforcement.ts`.
- R-8. The pair_mode_resume trigger behavior detail SHALL be preserved in the git-workflow pair-mode-resume task.
- R-9. The cross-reference in the `Pair Mode Suggestion Protocol` section of `.opencode/guidelines/116-pair-mode.md` SHALL point to `git-workflow-branch/tasks/pair-mode-resume.md`.
- R-10. The `test-2134-sc*.sh` content-verification suite SHALL pass against the condensed guideline with zero failures.
- R-11. The condensed guideline SHALL NOT cross-reference `.py` or `.ts` source files.
- R-12. Every retained section of the condensed guideline SHALL contain at least one MUST, MUST NOT, or SHOULD instruction.

## Items

### Item 1 (SC-1): Remove the Self-Simulation Prohibition section

- RED: `grep -q "Self-Simulation"` returns a match (section still present)
- GREEN: remove the Self-Simulation Prohibition section from the guideline
- verify: `grep -q "Self-Simulation"` returns no match
- commit: guideline condensation slice

### Item 2 (SC-2): Remove the Trigger Behavior Map section

- RED: `grep -q "Trigger Behavior Map"` returns a match
- GREEN: remove the Trigger Behavior Map section from the guideline
- verify: `grep -q "Trigger Behavior Map"` returns no match
- commit: guideline condensation slice

### Item 3 (SC-3): Remove the Suppression Rule section

- RED: `grep -q "Suppression Rule"` returns a match
- GREEN: remove the Suppression Rule section from the guideline
- verify: `grep -q "Suppression Rule"` returns no match
- commit: guideline condensation slice

### Item 4 (SC-4): Retain the Session Trigger No-Echo section

- RED: `grep -q "No-Echo"` returns no match (section missing)
- GREEN: confirm the No-Echo section remains in the condensed guideline
- verify: `grep -q "No-Echo"` returns a match
- commit: guideline condensation slice

### Item 5 (SC-5): Retain the nested_opencode_fatal hard-halt section

- RED: `grep -q "nested_opencode_fatal"` returns no match (section missing)
- GREEN: confirm the hard-halt section remains in the condensed guideline
- verify: `grep -q "nested_opencode_fatal"` returns a match
- commit: guideline condensation slice

### Item 6 (SC-6): Preserve self-simulation prohibition detail in the plugin

- RED: `grep -q "Self-Simulation"` in `.opencode/plugins/session-enforcement.ts` returns no match (detail absent)
- GREEN: add the self-simulation prohibition detail to `.opencode/plugins/session-enforcement.ts`
- verify: `grep -q "Self-Simulation"` returns a match in the plugin; `tsc --noEmit` passes
- commit: relocation slice

### Item 7 (SC-7): Preserve suppression rule detail in the plugin

- RED: `grep -q "Suppression"` in `.opencode/plugins/session-enforcement.ts` returns no match (detail absent)
- GREEN: add the suppression rule detail to `.opencode/plugins/session-enforcement.ts`
- verify: `grep -q "Suppression"` returns a match in the plugin; `tsc --noEmit` passes
- commit: relocation slice

### Item 8 (SC-8): Relocate the pair_mode_resume trigger behavior map to git-workflow

- RED: `grep -q "pair_mode_resume"` in `git-workflow-branch/tasks/pair-mode-resume.md` returns no match (detail absent)
- GREEN: add the pair_mode_resume trigger behavior map to the pair-mode-resume task
- verify: `grep -q "pair_mode_resume"` returns a match in the task file
- commit: relocation slice

### Item 9 (SC-9): Update the 116-pair-mode.md cross-reference

- RED: `grep -n "trigger behavior map"` in 116-pair-mode.md still points to 117
- GREEN: update the `Pair Mode Suggestion Protocol` section reference to point to `git-workflow-branch/tasks/pair-mode-resume.md`
- verify: `grep -n "trigger behavior map"` in 116-pair-mode.md resolves to `git-workflow-branch/tasks/pair-mode-resume.md`
- commit: reference-update slice

### Item 10 (SC-10): Reconcile the 2134 content-verification tests

- RED: `test-2134-sc*.sh` suite reports failures against the condensed guideline
- GREEN: update or retire the 10 `test-2134-sc*.sh` scripts to assert the relocated destinations and the retained core
- verify: run `bash .opencode/tests-v2/test-2134-sc*.sh` and assert every script exits 0
- commit: test-reconcile slice

### Item 11 (SC-11): Behavioral regression — nested_opencode_fatal HALT

- RED: behavioral run does not produce a HALT on NESTED_OPENCODE_FATAL
- GREEN: confirm the retained hard-halt core still enforces
- verify: `with-test-home opencode run` with a NESTED_OPENCODE_FATAL block, assert HALT via stderr evidence
- commit: verification slice

### Item 12 (SC-12): Behavioral regression — no-echo mandate

- RED: behavioral run echoes SESSION_TRIGGERS verbatim
- GREEN: confirm the retained no-echo mandate still enforces
- verify: `with-test-home opencode run` with a SESSION_TRIGGERS block, assert no verbatim echo via stderr evidence
- commit: verification slice

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/guidelines/117-session-trigger-behavior.md` | The file being condensed; must be read before implementation | Satisfied |
| `.opencode/plugins/session-enforcement.ts` | Destination for relocated self-simulation/suppression detail; must be TypeScript-valid after change | Satisfied |
| `.opencode/skills/git-workflow-branch/tasks/pair-mode-resume.md` | Destination for relocated pair_mode_resume trigger map | Satisfied |
| `.opencode/guidelines/116-pair-mode.md` | Cross-reference source whose `Pair Mode Suggestion Protocol` section must be updated | Satisfied |
| `.opencode/tests-v2/test-2134-sc*.sh` (10 scripts) | Content-verification tests that must be reconciled | Satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | condense |
| R-2 | SC-2 | condense |
| R-3 | SC-3 | condense |
| R-4 | SC-4 | condense |
| R-5 | SC-5 | condense |
| R-6 | SC-6 | relocate |
| R-7 | SC-7 | relocate |
| R-8 | SC-8 | relocate |
| R-9 | SC-9 | reference-update |
| R-10 | SC-10 | test-reconcile |
| R-11 | SC-1, SC-2, SC-3 | condense |
| R-12 | SC-4, SC-5 | condense |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 117-session-trigger-behavior.md | code | `.opencode/guidelines/117-session-trigger-behavior.md` | read/grep |
| session-enforcement.ts | code | `.opencode/plugins/session-enforcement.ts` | read/tsc |
| pair-mode-resume task | code | `.opencode/skills/git-workflow-branch/tasks/pair-mode-resume.md` | read/grep |
| 116-pair-mode.md | code | `.opencode/guidelines/116-pair-mode.md` | read/grep |
| test-2134-sc*.sh (10 scripts) | code | `.opencode/tests-v2/test-2134-sc*.sh` | run |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the Self-Simulation section is removed costs one grep. Skipping means the procedural prose stays preloaded and the token-reduction goal silently fails.
- SC-2: Verifying the Trigger Behavior Map is removed costs one grep. Skipping leaves the trigger map preloaded, defeating the condensation.
- SC-3: Verifying the Suppression Rule is removed costs one grep. Skipping leaves the suppression detail preloaded, defeating the condensation.
- SC-4: Verifying the No-Echo section is retained costs one grep. Skipping risks the no-echo mandate being lost in the condensation.
- SC-5: Verifying the hard-halt section is retained costs one grep. Skipping risks the nested_opencode_fatal HALT being lost — the single most safety-critical behavior.
- SC-6: Verifying the self-simulation detail is preserved in `.opencode/plugins/session-enforcement.ts` costs one grep plus tsc. Skipping loses the prohibition detail and regresses behavioral enforcement.
- SC-7: Verifying the suppression rule is preserved in `.opencode/plugins/session-enforcement.ts` costs one grep plus tsc. Skipping loses the suppression guidance and regresses enforcement.
- SC-8: Verifying the trigger map is preserved in the pair-mode-resume task costs one grep. Skipping loses the pair_mode_resume routing behavior.
- SC-9: Verifying the 116 cross-reference resolves to `git-workflow-branch/tasks/pair-mode-resume.md` costs one grep. Skipping leaves a dangling reference that routes agents to removed content.
- SC-10: Verifying the 2134 suite passes costs running the scripts. Skipping means the enforcement suite breaks on the condensed guideline, producing false FAILs.
- SC-11: Verifying the HALT behavior costs a behavioral run. Skipping means a weakened hard-halt ships and costs 1000× more when the violation surfaces in production.
- SC-12: Verifying the no-echo mandate costs a behavioral run. Skipping means a verbatim-echo regression ships and costs 1000× more to discover downstream.

## Edge Cases

- **Input boundary — empty condensed guideline:** If the condensation removes all sections, the guideline is empty and SC-4/SC-5 fail. Resolution: retain the No-Echo and nested_opencode_fatal sections as the non-negotiable core.
- **State transition — relocation destination missing:** If `.opencode/plugins/session-enforcement.ts` or the pair-mode-resume task lacks the destination file, SC-6/SC-7/SC-8 fail. Resolution: create the destination file before marking relocation complete.
- **Failure mode — 2134 tests assert removed content:** If tests are not reconciled, SC-10 fails and the suite breaks. Resolution: update or retire each affected test to assert the relocated destination or retained core.
- **Concurrency — plugin grows with relocated prose:** If the plugin change breaks TypeScript validity, SC-6/SC-7 fail. Resolution: run `tsc --noEmit` to verify the plugin remains valid.
- **Recovery — stale cross-reference:** If the `Pair Mode Suggestion Protocol` section of 116-pair-mode.md still points to 117, SC-9 fails. Resolution: update the reference to `git-workflow-branch/tasks/pair-mode-resume.md` and re-grep for dangling references.

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-28 | Corrected SC-1..SC-8 evidence types from `structural` to `string`; pinned SC-6/SC-7 relocation destination to `.opencode/plugins/session-enforcement.ts`; named SC-9 concrete path `git-workflow-branch/tasks/pair-mode-resume.md`; updated R-6/R-7/R-9, Items 6/7/9, Cost Frame, and Edge Cases accordingly. | Validation findings: EVIDENCE_TYPE_MISMATCH (grep-pattern verification is string evidence), DETERMINISM/ESCAPE-HATCH (disjunctive "or a companion artifact" and vague "relocated home" targets), ATOMICITY (disjunctive "or" fails atomicity). | Validation pipeline |
| 2026-08-28 | Corrected SC-10 evidence type from `structural` to `string` (token-count comparison is string evidence, not file-existence/structural evidence); replaced the "line 76" line-number reference with the stable `Pair Mode Suggestion Protocol` section heading across SC-9, R-9, Item 9, Dependencies, and Edge Cases. | Validation findings: EVIDENCE_TYPE_MISMATCH (SC-10 declares structural but verifies via token-count comparison), LINE-NUMBER REFERENCE (SC-9/R-9/Item 9/Edge Cases cite "116-pair-mode.md line 76", violating spec-structure-standards §Prohibited Content Patterns). | Validation pipeline |

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
