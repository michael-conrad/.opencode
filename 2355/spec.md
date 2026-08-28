> **Full spec and artifacts: [`.opencode/.issues/2355/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2355)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2355/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Condense 091-incremental-build.md — move per-item TDD detail to tdd skill

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Preloaded `.opencode/guidelines/091-incremental-build.md` (50 lines, ~1.0k tokens) is ~60% procedural detail (per-item TDD cycle, scope classification table, anti-patterns) that duplicates the `test-driven-development` skill, and it carries two stale cross-references on line 9. |
| 2 | **Root Cause / Motivation** | Tier-1 preloaded guidelines should hold mandate-level rules only; procedural detail belongs in the owning skill loaded on demand via `skill()`. The current 091 loads ~0.6k tokens of duplicated procedure into every session's preload, and two of its references point to content that no longer exists. |
| 3 | **Approach Chosen** | Condense 091 to retain only the decomposition mandate (top-down decomposition → bottom-up design → per-item TDD cycle); relocate the procedural detail (scope classification table, per-item TDD cycle, behavioral variant, anti-patterns) to the `test-driven-development` skill; remove the two stale cross-references; add a behavioral enforcement test proving the mandate is still followed. |
| 4 | **Alternatives Considered & Why Discarded** | **Leave 091 unchanged** — discarded because it leaves the token-cost duplication and stale references in place, defeating the issue's purpose. **Delete 091 entirely** — discarded because the decomposition mandate must remain preloaded and Tier-1 (Scope: Out). |
| 5 | **Key Design Decisions** | **Mandate stays preloaded** — `opencode.jsonc` line 88 retains 091 in the instructions array; only the referenced content shrinks. **tdd skill becomes the single source for TDD procedure** — loaded on demand, not preloaded. **Relocation must be lossless** — no procedural content is dropped; it moves. **Behavioral test accompanies the change** — per the tdd Enforcement Test Mandate. |
| 6 | **User Intent / Original Prompt** | Condense `.opencode/guidelines/091-incremental-build.md`; move per-item TDD detail to the `test-driven-development` skill; keep the decomposition mandate preloaded. |

## 2. Not Included

- **[Removing the incremental-build mandate]** — Scope: Out. The mandate that all implementation follows top-down decomposition → bottom-up design → per-item TDD cycle is retained and remains preloaded.
- **[Changing the preloading mechanism]** — 091 stays preloaded in `opencode.jsonc`; only the file content shrinks.
- **[Rewriting the tdd skill's core TDD logic]** — This is a content-movement/condense task, not a TDD redesign.
- **[Removing the behavioral evidence definition or prose-recall prohibition]** — These are canonical in the tdd SKILL.md and must be preserved.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|-----------------------|
| SC-1 | The `.opencode/guidelines/091-incremental-build.md` file SHALL retain the decomposition mandate text (top-down decomposition → bottom-up design → per-item TDD cycle) and SHALL no longer contain the scope classification table, the per-item TDD cycle detail, the behavioral variant, or the anti-patterns sections. | string | `grep` the condensed 091 for the mandate text (present) and for `Scope Classification`, `Per-Item TDD Cycle`, `Anti-Patterns` (absent) | `.opencode/guidelines/091-incremental-build.md` |
| SC-2 | The condensed `.opencode/guidelines/091-incremental-build.md` SHALL NOT contain a cross-reference to `000-critical-rules.md` section `Monolithic Implementation`. | string | `grep -n "Monolithic Implementation"` on 091 returns no match | `.opencode/guidelines/091-incremental-build.md` |
| SC-3 | The condensed `.opencode/guidelines/091-incremental-build.md` SHALL NOT contain a cross-reference to the file `tests-v2/behaviors/tier1-mandate-enforcement.sh`. | string | `grep -n "tier1-mandate-enforcement.sh"` on 091 returns no match | `.opencode/guidelines/091-incremental-build.md` |
| SC-4 | The `.opencode/skills/test-driven-development` skill SHALL contain the scope classification table with the four scope terms `GREENFIELD`, `NEW_FEATURE`, `FIX`, and `ENHANCEMENT`. | string | `grep` the tdd skill files for each scope term (all present) | `.opencode/skills/test-driven-development/SKILL.md`, `.opencode/skills/test-driven-development/tasks/` |
| SC-5 | The condensed 091 SHALL NOT contain the scope classification table terms `GREENFIELD`, `NEW_FEATURE`, `FIX`, or `ENHANCEMENT` in the scope-classification context. | string | `grep` 091 for the four scope terms returns no match | `.opencode/guidelines/091-incremental-build.md` |
| SC-6 | The `.opencode/skills/test-driven-development` skill SHALL preserve the behavioral variant and behavioral evidence definition (stderr-based helpers, prose-recall prohibition) relocated from 091. | semantic | Clean-room sub-agent reads the tdd SKILL.md and confirms the behavioral variant and behavioral evidence definition are present and intact | `.opencode/skills/test-driven-development/SKILL.md` |
| SC-7 | The `.opencode/skills/test-driven-development/tasks/anti-patterns.md` SHALL preserve the incremental-build anti-patterns (Monolithic implementation, Code-first, Batching items, Merging without tests, Phase-scoped over-verification). | string | `grep` anti-patterns.md for each of the five incremental-build anti-pattern names (all present) | `.opencode/skills/test-driven-development/tasks/anti-patterns.md` |
| SC-8 | A behavioral enforcement test SHALL exist that verifies the agent follows the decomposition mandate (top-down decomposition → bottom-up design → per-item TDD cycle) after the condense. | behavioral | Run the behavioral test via `bash .opencode/tests-v2/with-test-home opencode run '<prompt>'` and assert RED before the change, GREEN after, using stderr-based assertion helpers on the exported session.yaml | `.opencode/tests-v2/behaviors/` |
| SC-9 | The `opencode.jsonc` instructions array SHALL retain the preload entry for `.opencode/guidelines/091-incremental-build.md`. | string | `grep -n "091-incremental-build"` on `opencode.jsonc` returns the preload entry | `.opencode/opencode.jsonc` |

## 4. Requirements

- R-1. The condensed `.opencode/guidelines/091-incremental-build.md` SHALL retain the decomposition mandate text verbatim.
- R-2. The condensed `.opencode/guidelines/091-incremental-build.md` SHALL remove the scope classification table, the per-item TDD cycle detail, the behavioral variant, and the anti-patterns sections.
- R-3. The condensed `.opencode/guidelines/091-incremental-build.md` SHALL remove both stale cross-references on line 9 (the `000-critical-rules.md` `Monolithic Implementation` section and the `tier1-mandate-enforcement.sh` file).
- R-4. The `.opencode/skills/test-driven-development` skill SHALL contain the scope classification table relocated from 091.
- R-5. The `.opencode/skills/test-driven-development` skill SHALL preserve the per-item TDD cycle detail, behavioral variant, and behavioral evidence definition relocated from 091 without content loss.
- R-6. The `.opencode/skills/test-driven-development/tasks/anti-patterns.md` SHALL preserve the five incremental-build anti-patterns, reconciled with the existing generic TDD anti-patterns.
- R-7. The `opencode.jsonc` instructions array SHALL retain the 091 preload entry.
- R-8. The change SHALL be accompanied by a behavioral enforcement test per the tdd Enforcement Test Mandate, executed via `with-test-home` `opencode run`.

## 5. Items

### Item 1 (SC-1): Condense 091-incremental-build.md to retain only the decomposition mandate

- RED: Grep the current 091 and confirm the mandate text is present (it is); this test targets the post-condense absence of the procedural sections, which currently exist (RED).
- GREEN: Reduce 091 to the mandate plus minimal framing; remove the scope classification table, per-item TDD cycle detail, behavioral variant, and anti-patterns sections; retain Tier-1 frontmatter.
- verify: `grep` 091 for the mandate text (present) and for the procedural section headers (absent).
- commit: Commit the condensed `091-incremental-build.md`.

### Item 2 (SC-2, SC-3): Remove stale cross-references from 091 line 9

- RED: Grep 091 line 9 for `Monolithic Implementation` and `tier1-mandate-enforcement.sh` — both matches exist (RED).
- GREEN: Remove or re-point both stale references so no dead links remain in the condensed 091.
- verify: `grep -n` for `Monolithic Implementation` and `tier1-mandate-enforcement.sh` on 091 returns no match.
- commit: Commit the reference cleanup with the 091 condense.

### Item 3 (SC-4, SC-5): Relocate scope classification table to test-driven-development skill

- RED: Grep the tdd skill for the four scope terms — absent (RED); 091 currently contains them.
- GREEN: Add the scope classification table to the tdd skill and remove it from 091.
- verify: `grep` the tdd skill for `GREENFIELD`, `NEW_FEATURE`, `FIX`, `ENHANCEMENT` (present); `grep` 091 for the same (absent).
- commit: Commit the scope table relocation.

### Item 4 (SC-6): Relocate per-item TDD cycle detail to test-driven-development skill

- RED: Semantic read of the tdd skill confirms the behavioral variant and behavioral evidence definition are not fully present (RED).
- GREEN: Reconcile the tdd skill (SKILL.md / operating-protocol.md) so the behavioral variant and behavioral evidence definition are present without loss.
- verify: Clean-room sub-agent semantic read confirms no content loss.
- commit: Commit the per-item TDD relocation.

### Item 5 (SC-7): Relocate anti-patterns to test-driven-development skill

- RED: Grep anti-patterns.md for the five incremental-build anti-pattern names — absent (RED).
- GREEN: Reconcile the five incremental-build anti-patterns into anti-patterns.md alongside the existing generic TDD anti-patterns, preserving the critical-rules-042 framing.
- verify: `grep` anti-patterns.md for each of the five anti-pattern names (all present).
- commit: Commit the anti-patterns relocation.

### Item 6 (SC-8): Add behavioral enforcement test for the condensed mandate

- RED: Run the behavioral test against the pre-condense state; the agent may follow the mandate but the test asserts the post-condense behavior (RED before the change).
- GREEN: Create the behavioral test scenario in `tests-v2/behaviors/` and run it against the condensed state via `with-test-home` `opencode run`; assert the agent follows the decomposition mandate using stderr-based helpers.
- verify: `assert_stderr_pattern_present` for tdd skill dispatch / tool invocations in the exported session.yaml; the test must be behavioral (not prose-recall).
- commit: Commit the behavioral test.

### Item 7 (SC-9): Verify 091 preload retention in opencode.jsonc

- RED: Confirm the preload entry currently exists (it does) — no RED test; this item verifies retention.
- GREEN: No source change expected; verify the `opencode.jsonc` preload entry for 091 remains in the instructions array.
- verify: `grep -n "091-incremental-build"` on `opencode.jsonc` returns the preload entry.
- commit: No commit expected unless `opencode.jsonc` is touched.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/skills/test-driven-development` skill | Relocation target; per-item TDD cycle detail, scope table, and anti-patterns move here. Issue #2367 (tdd skill update) is the canonical home for per-item TDD cycle. | Pending |
| `.opencode/opencode.jsonc` (instructions array line 88) | Preloads 091; retained unchanged. | Satisfied |
| `.opencode/guidelines/INDEX.md` (line 27) | Routes to 091; trigger patterns unchanged. | Satisfied |
| `.opencode/tests-v2/with-test-home` | Behavioral test harness for SC-8. | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-2, SC-3 | Phase 1 |
| R-4 | SC-4, SC-5 | Phase 2 |
| R-5 | SC-6 | Phase 2 |
| R-6 | SC-7 | Phase 2 |
| R-7 | SC-9 | Phase 1 |
| R-8 | SC-8 | Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 091-incremental-build.md | guideline | `.opencode/guidelines/091-incremental-build.md` | `read` + `grep` |
| test-driven-development SKILL.md | skill | `.opencode/skills/test-driven-development/SKILL.md` | `read` + `grep` |
| tdd operating-protocol.md | task file | `.opencode/skills/test-driven-development/tasks/operating-protocol.md` | `read` + `grep` |
| tdd anti-patterns.md | task file | `.opencode/skills/test-driven-development/tasks/anti-patterns.md` | `read` + `grep` |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | `grep` |
| with-test-home harness | test harness | `.opencode/tests-v2/with-test-home` | `bash` execution |
| Issue #2367 | issue | `.opencode/.issues/2367/` | `local-issues read` |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Grepping the condensed 091 for mandate presence and procedural-section absence costs seconds. Skipping it ships a 091 that either drops the mandate or retains the duplicated procedure, reintroducing the token-cost defect at the next session preload.
- SC-2: Grepping 091 for `Monolithic Implementation` costs one search. Skipping it leaves a dead link that routes agents to a section that does not exist, wasting every agent that follows it.
- SC-3: Grepping 091 for `tier1-mandate-enforcement.sh` costs one search. Skipping it leaves a dead reference to a file that does not exist, misleading agents about where the incremental-build discipline is enforced.
- SC-4: Grepping the tdd skill for the four scope terms costs seconds. Skipping it loses the scope classification table during relocation, a content-loss defect.
- SC-5: Grepping 091 for the four scope terms costs seconds. Skipping it leaves the scope table duplicated in both files, reintroducing the content-ownership overlap the issue removes.
- SC-6: A clean-room sub-agent semantic read of the tdd skill costs minutes. Skipping it risks losing the behavioral variant or behavioral evidence definition, a content-loss defect that silently weakens TDD enforcement.
- SC-7: Grepping anti-patterns.md for the five anti-pattern names costs seconds. Skipping it risks dropping incremental-build anti-pattern guidance during the reconcile.
- SC-8: Running the behavioral test via `with-test-home` costs minutes of execution time. Skipping it means a guideline change ships without behavioral enforcement, violating the Enforcement Test Mandate and masking whether the mandate is still followed.
- SC-9: Grepping `opencode.jsonc` for the 091 preload entry costs one search. Skipping it risks dropping the preload, which would remove the decomposition mandate from every session.

## 11. Edge Cases

- **Input boundaries:** The condensed 091 must not be empty — the mandate text must remain non-empty and the frontmatter intact. An empty 091 is a defect.
- **State transitions:** 091 transitions from FULL to CONDENSED only when the mandate is retained. If the condense removes the mandate, the transition violates Scope: Out and is BLOCKED.
- **Failure modes:** If the scope table or anti-patterns are dropped during relocation (not preserved in tdd), the relocation is non-lossless and SC-4/SC-6/SC-7 fail. If the preload entry is dropped from `opencode.jsonc`, SC-9 fails.
- **Concurrency:** The behavioral test (SC-8) must run via `with-test-home` isolation to avoid SQLite session conflicts; a stale `tmp/.behavior-run.lock` must be removed before re-running.
- **Recovery:** If the behavioral test cannot execute, remediation (alternative model selection, infrastructure check) must be attempted before escalation; the test must be behavioral (not prose-recall), and a RED-before-GREEN ordering must be preserved.
