---
plan_schema_version: 1
issue: 2452
title: "Wire brainstorming handoff consumption into spec-creation analyze (belt-and-suspenders)"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase-1: test-driven-development (red, green, phase-4) + verification-before-completion (verify) + commit-inline (direct)
  - phase-2: test-driven-development (red, green, phase-4) + verification-before-completion (verify) + commit-inline (direct)
  - phase-3: test-driven-development (red, green, phase-4) + verification-before-completion (verify) + commit-inline (direct)
  - post: audit + finishing-a-development-branch (structural-checks) + verification-before-completion (pre-pr-gate) + test-driven-development (regression-check) + git-workflow-pr (review-prep, create-pr) + completion-core (exec-summary)
---

# Implementation Plan — .opencode#2452: Wire brainstorming handoff consumption into spec-creation analyze

**Issue:** .opencode/.issues/2452/spec.md
**Remote:** https://github.com/michael-conrad/.opencode/issues/2452

## Goal

Make the spec-creation analyze step consume the brainstorming handoff contract via two channels: an optional `brainstorm_handoff_path` dispatch-context field (primary) and a handoff pointer file written into the local issue directory at issue creation (fallback). Degraded mode (neither channel present) is documented behavior — no halt.

## Architecture

Belt-and-suspenders wiring (approved option 3): thread the optional field through the spec-creation TDT analyze dispatch AND add a pointer-write step to the brainstorming exploration-workflow at issue creation. Channel precedence: dispatch field > pointer. The handoff.yaml schema remains owned by brainstorming; analyze is a read-only consumer. Analyze never halts due to missing or stale handoff channels.

## Files

- `.opencode/skills/spec-creation/SKILL.md` — TDT analyze dispatch context gains optional `brainstorm_handoff_path` (Phase 1)
- `.opencode/skills/spec-creation/tasks/analyze.md` — handoff-consumption instructions, pointer-discovery instructions, degraded-mode paragraph (Phases 1 and 3)
- `.opencode/skills/brainstorming/SKILL.md` — exploration-workflow pointer-write step at issue creation (Phase 2)

## Blast Radius

LOW-MEDIUM. All changes are skill-deck text edits inside the .opencode submodule; no production source code is touched. Downstream impact is behavioral (dispatch routing and workflow steps), verified via tests-v2 behavioral runs. `.opencode/tests-v2/AGENTS.md` is a documentation reference only — no normative change expected. `.opencode/.issues/2451/` is read-only case evidence, explicitly excluded from remediation.

## Dispatch

- Phase 1: direct (commit) + task-card (red, green, post-regression, verify)
- Phase 2: direct (commit) + task-card (red, green, post-regression, verify)
- Phase 3: direct (commit) + task-card (red, green, post-regression, verify)
- Post-implementation: task-card (audit, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary) + direct (z3-check)

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|-----------|----------|
| 1 | Dispatch-field channel: brainstorm_handoff_path threading | dispatch-threading | SC-1 | none | 1-14 | direct (7-8, 11-14) + task-card (1-6, 9-10) |
| 2 | Pointer-file channel: brainstorming writes handoff pointer at issue creation | pointer-write | SC-2 | none | 15-28 | direct (21-22, 25-28) + task-card (15-20, 23-24) |
| 3 | Fallback discovery and degraded no-halt mode | fallback-discovery, degraded-mode | SC-3a, SC-3b | Phase 1, Phase 2 | 29-52 | direct (33-34, 38-39, 47-52) + task-card (29-32, 35-37, 40-46) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

1. C1 — SC-1 behavioral run passes: with `brainstorm_handoff_path` threaded, the analyze sub-agent's stderr shows a handoff-file read before spec production.
2. C2 — SC-2 behavioral run passes: after the brainstorming explore path creates an issue, the pointer file exists in the local issue directory and references the handoff artifact path.
3. C3 — SC-3a behavioral run passes: with the field absent and pointer present, stderr shows the discovery read of the pointer target.
4. C4 — SC-3b behavioral run passes: with neither channel present, analyze completes normally with no halt and no BLOCKED state.
5. C5 — All SC verdicts are PASS with behavioral evidence; no EVIDENCE_TYPE_MISMATCH; pre-pr-gate accepts.
6. C6 — PR created via stacked strategy; completion executive summary generated.

## Pre-Implementation (Tier 1 — Global)

- [ ] 1. (**task-card**) Run pre-regression — execute phase-0 task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-pre-regression-*`
  - Run existing regression test patterns to confirm a clean baseline before any RED
- [ ] 2. (**task-card**) Verify pre-regression results — execute verify task from verification-before-completion
  - Confirm baseline is green; record pre-regression verdict before RED begins

## Phase 1 — Dispatch-field channel: brainstorm_handoff_path threading

**Concern:** dispatch-threading. **SCs:** SC-1.
**Files:** `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/spec-creation/tasks/analyze.md`
**Dependencies:** none. **Entry:** baseline green. **Exit:** SC-1 committed and pushed; behavioral run shows handoff-file read in analyze stderr.

### Code Path Coverage

- `.opencode/skills/spec-creation/SKILL.md` — TDT analyze dispatch context definition — gains optional `brainstorm_handoff_path` field. Runtime observable: handoff-file read appears in analyze sub-agent stderr tool actions.
- `.opencode/skills/spec-creation/tasks/analyze.md` — analyze task card — gains handoff-consumption instruction preceding its analysis steps.

### Cross-Cutting SCs

- None in this phase. SC-3a/SC-3b (Phase 3) exercise this phase's channel as the absent-field variant.

### Interface Boundaries

- spec-creation TDT analyze dispatch context (SKILL.md → analyze task card): optional `brainstorm_handoff_path` field added; backward-compatible — absent field yields behavior identical to today.

### State Transitions

- handoff-channel-state: none → dispatch-field-present (dispatch supplies `brainstorm_handoff_path`); analyze reads handoff artifact as primary design input.

### Step-by-step

- [ ] 3. (**task-card**) Item 1 (SC-1) RED — execute red task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-red-*`
  - Write a behavioral enforcement test for SC-1: run via `bash .opencode/tests-v2/with-test-home opencode run` with a brainstorming handoff present and `brainstorm_handoff_path` threaded into the analyze dispatch; assert stderr shows the analyze dispatch and a handoff-file read (`assert_stderr_pattern_present`; no prose-recall prompts)
  - RED condition: test FAILS because the dispatch field and consumption instructions do not exist yet
- [ ] 4. (**task-card**) Item 1 (SC-1) GREEN — execute green task from test-driven-development
  - GREEN condition: add the optional `brainstorm_handoff_path` field to the TDT analyze dispatch context in spec-creation SKILL.md; add handoff-consumption instructions to the analyze task card preceding its analysis steps; minimum change only — no scope creep
- [ ] 5. (**task-card**) Item 1 (SC-1) post-regression — execute phase-4 task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-post-regression-*`
  - Re-run regression test patterns after GREEN
- [ ] 6. (**task-card**) Item 1 (SC-1) verify — execute verify task from verification-before-completion
  - Verify SC-1 against its success criterion with behavioral evidence (`assert_stderr_pattern_present`); no prose-recall substitution
- [ ] 7. (**direct**) Item 1 (SC-1) commit-inline
  - Stage skill-deck change + behavioral test; single atomic slice, no co-author trailers during implementation commits
- [ ] 8. (**direct**) Item 1 (SC-1) push — behavioral variant requirement
  - Push the commit to the remote branch; fresh `git fetch`; verify the effective commit is contained in a remote ref BEFORE the behavioral test run
- [ ] 9. (**task-card**) Item 1 (SC-1) behavioral test run
  - Run the SC-1 behavioral test against the pushed effective commit; record verdict as evidence

### Phase completion block

- [ ] 10. (**task-card**) Phase 1 verification — execute verify task from verification-before-completion
  - Assert SC-1 verdict is PASS with behavioral evidence type matching the spec's declared evidence type; any DONE_WITH_CONCERNS is coerced to FAIL
- [ ] 11. (**direct**) Record phase 1 completion and SC-1 evidence artifact path under `{project_root}/tmp/{issue-2452}/artifacts/`
- [ ] 12. (**direct**) Confirm daisy chain: phase 2 may begin only after this phase's commit is in place

**Cost frame:** Threading the dispatch field and running its behavioral test costs one context-field edit plus one behavioral run (minutes). Skipping costs every handoff-enabled dispatch re-investigating from scratch — or silently diverging from the approved design — a full revise cycle per occurrence, invisible until the developer rejects the spec.

**Concern transition:** dispatch-threading complete; pointer-write (Phase 2) is independent and next.

## Phase 2 — Pointer-file channel: brainstorming writes handoff pointer at issue creation

**Concern:** pointer-write. **SCs:** SC-2.
**Files:** `.opencode/skills/brainstorming/SKILL.md`
**Dependencies:** none. **Entry:** baseline green (parallel-safe with Phase 1). **Exit:** SC-2 committed and pushed; behavioral run shows pointer file present after issue creation.

### Code Path Coverage

- `.opencode/skills/brainstorming/SKILL.md` — exploration-workflow issue-creation step — gains pointer-file write alongside the Step 2.5 handoff contract. Runtime observable: pointer file exists in `{issues_prefix}{N}/` after issue creation.

### Cross-Cutting SCs

- None in this phase. SC-3a/SC-3b (Phase 3) exercise this phase's channel as the pointer-present variant.

### Interface Boundaries

- Brainstorming handoff pointer file (producer → local issue directory `{issues_prefix}{N}/` → analyze consumer): new pointer file written at issue creation; additive — no existing consumer disrupted; follows issue-directory naming/frontmatter conventions (R-3).
- Handoff contract schema: UNCHANGED — brainstorming Step 2.5 remains owner; analyze is read-only consumer (one-directional coupling).

### State Transitions

- handoff-channel-state: none → pointer-present (brainstorming exploration-workflow writes pointer at issue creation); pointer exists in `{issues_prefix}{N}/` referencing handoff artifact.
- pointer-target-currency: design revision during brainstorming → pointer write refreshes pointer target alongside handoff contract update (R-5).

### Step-by-step

- [ ] 13. (**task-card**) Item 2 (SC-2) RED — execute red task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-red-*`
  - Write a behavioral enforcement test for SC-2: behavioral run of the brainstorming explore path; assert the pointer file exists in `{issues_prefix}{N}/` after issue creation and references the handoff artifact path (file existence observed as runtime output; structural path check secondary corroboration only)
  - RED condition: test FAILS because the exploration-workflow pointer-write step does not exist yet
- [ ] 14. (**task-card**) Item 2 (SC-2) GREEN — execute green task from test-driven-development
  - GREEN condition: add the pointer-write step to the brainstorming exploration-workflow at issue creation, alongside the Step 2.5 handoff contract; pointer refresh covered whenever the design is revised alongside the handoff contract update (R-5); minimum change only
- [ ] 15. (**task-card**) Item 2 (SC-2) post-regression — execute phase-4 task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-post-regression-*`
  - Re-run regression test patterns after GREEN
- [ ] 16. (**task-card**) Item 2 (SC-2) verify — execute verify task from verification-before-completion
  - Verify SC-2 against its success criterion with behavioral evidence (pointer file existence from the run); structural check secondary only
- [ ] 17. (**direct**) Item 2 (SC-2) commit-inline
  - Stage skill-deck change + behavioral test; single atomic slice, no co-author trailers during implementation commits
- [ ] 18. (**direct**) Item 2 (SC-2) push — behavioral variant requirement
  - Push the commit to the remote branch; fresh `git fetch`; verify the effective commit is contained in a remote ref BEFORE the behavioral test run
- [ ] 19. (**task-card**) Item 2 (SC-2) behavioral test run
  - Run the SC-2 behavioral test against the pushed effective commit; record verdict as evidence

### Phase completion block

- [ ] 20. (**task-card**) Phase 2 verification — execute verify task from verification-before-completion
  - Assert SC-2 verdict is PASS with behavioral evidence type matching the spec's declared evidence type; any DONE_WITH_CONCERNS is coerced to FAIL
- [ ] 21. (**direct**) Record phase 2 completion and SC-2 evidence artifact path under `{project_root}/tmp/{issue-2452}/artifacts/`
- [ ] 22. (**direct**) Confirm daisy chain: phase 3 may begin only after this phase's commit AND phase 1's commit are in place

**Cost frame:** Writing the pointer file costs one additional exploration-workflow step and one behavioral run (minutes). Skipping costs the belt in belt-and-suspenders: any dispatch that bypasses the context field sees a title-only stub and drifts undetected — the exact .opencode#2451 failure.

**Concern transition:** pointer-write complete; both channels exist — Phase 3 wires fallback discovery and degraded mode.

## Phase 3 — Fallback discovery and degraded no-halt mode

**Concern:** fallback-discovery, degraded-mode. **SCs:** SC-3a, SC-3b.
**Files:** `.opencode/skills/spec-creation/tasks/analyze.md`
**Dependencies:** Phase 1 (dispatch-field semantics), Phase 2 (pointer file). **Entry:** SC-1 and SC-2 committed. **Exit:** SC-3a and SC-3b committed and pushed; behavioral runs show discovery read (3a) and no-halt completion (3b).

### Code Path Coverage

- `.opencode/skills/spec-creation/tasks/analyze.md` — gains pointer-discovery instructions (glob/read of issue-directory pointer when dispatch field absent; SC-3a) and a degraded-mode paragraph (neither channel → current behavior, no halt; SC-3b). Runtime observables: discovery read of pointer target in stderr (3a); run completes without BLOCKED state (3b).

### Cross-Cutting SCs

- SC-3a and SC-3b are cross-cutting: both exercise BOTH channels from Phases 1 and 2 — SC-3a spans the dispatch field (absent variant) and the pointer (present variant); SC-3b asserts absence of both channels.
- Shared-file discipline: `.opencode/skills/spec-creation/tasks/analyze.md` is edited by Items 1, 3a, and 3b — sequential execution only; 3a/3b sections append after Item 1's consumption instructions.

### Interface Boundaries

- spec-creation TDT analyze dispatch context: unchanged from Phase 1; SC-3a tests the absent-field path only.
- Handoff contract schema: read-only consumer; channel precedence fixed — dispatch field > pointer (both channels present with conflicting paths → field wins).

### State Transitions

- handoff-channel-state: pointer-present with field absent → discovery-read (analyze follows pointer and loads approved design; SC-3a).
- neither-present → current empty-stub behavior, no halt — documented degraded mode, not an error (SC-3b).
- Error states preserved: stale pointer → record handoff-unavailable, proceed, no halt; pointer target outside the issue's `tmp/{issue-N}/` scope → record handoff-unavailable, do not follow the out-of-scope path (read-scope discipline).

### Step-by-step

- [ ] 23. (**task-card**) Item 3a (SC-3a) RED — execute red task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-red-*`
  - Write a behavioral enforcement test for SC-3a: behavioral run with `brainstorm_handoff_path` absent from dispatch context but the issue-directory pointer present; assert stderr shows the discovery read of the pointer target (`assert_stderr_pattern_present`; no prose-recall prompts)
  - RED condition: test FAILS because pointer-discovery instructions do not exist in the analyze task card yet
- [ ] 24. (**task-card**) Item 3a (SC-3a) GREEN — execute green task from test-driven-development
  - GREEN condition: add pointer-discovery instructions to the analyze task card (discover the issue-directory pointer when the dispatch context field is absent, load the approved design from the pointer target, field > pointer precedence); minimum change only
- [ ] 25. (**task-card**) Item 3a (SC-3a) post-regression — execute phase-4 task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-post-regression-*`
  - Re-run regression test patterns after GREEN
- [ ] 26. (**task-card**) Item 3a (SC-3a) verify — execute verify task from verification-before-completion
  - Verify SC-3a against its success criterion with behavioral evidence (`assert_stderr_pattern_present` for the discovery read)
- [ ] 27. (**direct**) Item 3a (SC-3a) commit-inline
  - Stage skill-deck change + behavioral test; single atomic slice, no co-author trailers during implementation commits
- [ ] 28. (**direct**) Item 3a (SC-3a) push — behavioral variant requirement
  - Push the commit to the remote branch; fresh `git fetch`; verify the effective commit is contained in a remote ref BEFORE the behavioral test run
- [ ] 29. (**task-card**) Item 3a (SC-3a) behavioral test run
  - Run the SC-3a behavioral test against the pushed effective commit; record verdict as evidence
- [ ] 30. (**task-card**) Item 3b (SC-3b) RED — execute red task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-red-*`
  - Write a behavioral enforcement test for SC-3b: behavioral run with neither channel present; assert analyze completes without halt (run exits normally, no BLOCKED state)
  - RED condition: test FAILS because degraded-mode behavior is not documented in the analyze task card yet
- [ ] 31. (**task-card**) Item 3b (SC-3b) GREEN — execute green task from test-driven-development
  - GREEN condition: document degraded mode in the analyze task card (neither channel → current behavior, record handoff-unavailable, proceed — no halt); minimum change only
- [ ] 32. (**task-card**) Item 3b (SC-3b) post-regression — execute phase-4 task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-post-regression-*`
  - Re-run regression test patterns after GREEN
- [ ] 33. (**task-card**) Item 3b (SC-3b) verify — execute verify task from verification-before-completion
  - Verify SC-3b against its success criterion with behavioral evidence (run completes without halt, no BLOCKED state)
- [ ] 34. (**direct**) Item 3b (SC-3b) commit-inline
  - Stage skill-deck change + behavioral test; single atomic slice, no co-author trailers during implementation commits
- [ ] 35. (**direct**) Item 3b (SC-3b) push — behavioral variant requirement
  - Push the commit to the remote branch; fresh `git fetch`; verify the effective commit is contained in a remote ref BEFORE the behavioral test run
- [ ] 36. (**task-card**) Item 3b (SC-3b) behavioral test run
  - Run the SC-3b behavioral test against the pushed effective commit; record verdict as evidence

### Phase completion block

- [ ] 37. (**task-card**) Phase 3 verification — execute verify task from verification-before-completion
  - Assert SC-3a and SC-3b verdicts are PASS with behavioral evidence types matching the spec's declared evidence types; any DONE_WITH_CONCERNS is coerced to FAIL
- [ ] 38. (**direct**) Record phase 3 completion and SC-3a/SC-3b evidence artifact paths under `{project_root}/tmp/{issue-2452}/artifacts/`

**Cost frame:** Implementing fallback discovery and degraded mode costs one task-card section plus one behavioral run variant each (minutes). Skipping costs the deterministic guarantee that approved designs survive dispatch-path variance, and the no-halt regression coverage — without it, spurious BLOCKED states would surface across every non-brainstorm spec.

## Post-Implementation (Tier 1 — Global)

- [ ] 39. (**task-card**) Adversarial audit — execute verification-audit DiMo investigator from audit (read `audit/tasks/verification-audit-investigator.md` first), followed by validator, evaluator, arbiter in sequence
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-audit-*`
  - Audit the deliverable against all four SCs; record verdicts
- [ ] 40. (**direct**) Z3 constraint check — run `.opencode/tools/solve check --state-path ... --contract-path ...` directly
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-z3-check-*`
- [ ] 41. (**task-card**) Structural checks — execute checklist task from finishing-a-development-branch
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-structural-checks-*`
  - Run the finishing checklist (lint, format check, markdown lint on modified skill files)
- [ ] 42. (**task-card**) Pre-PR gate — execute verify task from verification-before-completion
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-pre-pr-gate-*`
  - Read all SC verdicts; BLOCK if any is FAIL (DONE_WITH_CONCERNS coerces to FAIL); EVIDENCE_TYPE_MISMATCH is a hard FAIL
- [ ] 43. (**task-card**) Final regression check — execute phase-4 task from test-driven-development
  - Pre-clean prior artifacts: remove `{project_root}/tmp/{issue-2452}/artifacts/pipeline-regression-check-*`
- [ ] 44. (**task-card**) Review prep — execute review-prep from git-workflow-pr (read `git-workflow-pr/tasks/review-prep.md` first)
- [ ] 45. (**task-card**) Create PR — execute create task from git-workflow-pr
  - Stacked strategy: one branch, squashed to one commit per issue, single PR targeting the trunk; HALT after PR creation — human-only merge
- [ ] 46. (**task-card**) Completion executive summary — execute completion task from completion-core
  - Emit the single `plan_created` lifecycle event with `plan_file` and `phase_count: 3` alongside completion reporting per pipeline conventions
  - Report completion; HALT

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
