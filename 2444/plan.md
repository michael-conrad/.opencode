---
plan_schema_version: 1
issue: 2444
title: "spec-creation reference-deck path integrity: correct 7 stale task-relative reference links"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - phase: 1
    tasks: [test-driven-development:pre-regression, verification-before-completion:pre-regression-verify, test-driven-development:red, test-driven-development:green, test-driven-development:post-regression, verification-before-completion:verify]
  - phase: 2
    tasks: [test-driven-development:red, test-driven-development:green, test-driven-development:post-regression, verification-before-completion:verify]
---

# Implementation Plan — #2444 — spec-creation reference-deck path integrity

**Issue:** `.opencode#2444` — https://github.com/michael-conrad/.opencode/issues/2444
**Spec:** `.opencode/.issues/2444/spec.md`
**Structure artifact:** `.opencode/.issues/2444/artifacts/structure.yaml`

## Goal / Architecture / Files / Dispatch

**Goal:** Rewrite the 7 stale task-relative `reference/` links in the spec-creation task cards (4 link instances across 4 unique targets in `validate.md`; 2 in sibling `create.md`) with the `../../../` prefix so every link resolves to its canonical file under `.opencode/reference/` and `.opencode/audit/reference/`, then confirm via one isolated behavioral run that a validate dispatch passes the reference-deck integrity gate.

**Architecture:** Two-phase fix per the structure artifact. Phase 1 makes the structural path corrections with a per-item RED/GREEN/COMMIT cycle: a resolver check that fails on the current broken state (SC-1), then a full-directory grep audit that closes the sibling `create.md` defect (SC-3). Phase 2 proves the corrections end-to-end: a behavioral enforcement scenario exercised through the `with-test-home` isolation harness shows a validate dispatch passing the reference-deck integrity gate without `reference-deck-integrity: FAIL` (SC-2). No reference-file content changes, no new files (except the behavioral scenario script if retained as enforcement artifact), no procedure-logic changes. The `.opencode` submodule carries all edits; the parent-repo submodule pointer rides along with the next real parent-repo change (never standalone).

**Files:**
- `.opencode/skills/spec-creation/tasks/validate.md` — 4 reference path corrections (5 link instances: 3 unique targets to `.opencode/reference/`, 1 prose mention to `.opencode/audit/reference/`)
- `.opencode/skills/spec-creation/tasks/create.md` — 2 reference path corrections (same defect pattern, sibling file)
- `.opencode/tests-v2/behaviors/<scenario>.sh` (new, Phase 2 only) — behavioral enforcement scenario script, if retained as enforcement artifact
- Unchanged by design: `.opencode/reference/holistic-dimensions.yaml`, `.opencode/reference/spec-structure-standards.md`, `.opencode/reference/cost-model-standards.md`, `.opencode/audit/reference/decomposition-criteria.md` (canonical targets — read targets only, byte-identical before/after)

**Dispatch:** `test-driven-development` (pre-regression, RED/GREEN cycles, post-regression, final regression), `verification-before-completion` (pre-regression verify, per-item verify, phase VbC, pre-PR gate), `audit` (adversarial verification audit), `finishing-a-development-branch` (structural checklist), `git-workflow-pr` (review-prep, PR creation), `completion-core` (executive summary). `commit-inline`, push/fetch-verify, and `z3-check` steps are orchestrator-direct per the implementation-workflow reference card.

## Blast Radius

- `.opencode/skills/spec-creation/tasks/validate.md` — 4 reference paths corrected; text-only link-target change; blast radius LOW (SC-1)
- `.opencode/skills/spec-creation/tasks/create.md` — 2 reference paths corrected; same idiom; blast radius LOW (SC-3)
- `.opencode/reference/*.yaml,md` and `.opencode/audit/reference/decomposition-criteria.md` — content unchanged; only link targets in task cards are corrected
- Unaffected but adjacent (verified in blast-radius artifact): `SKILL.md`, `tasks/analyze.md`, `tasks/revise.md`, `tasks/reconcile-push.md` — no `reference/` path mentions; `SKILL.md` line-160 repo-root-relative links resolve correctly and are out of defect scope
- Downstream impact is positive: spec-creation validate/create dispatches unblock (reference-deck integrity gate passes instead of BLOCKED)
- Worst-case regression: a mistyped corrected path re-breaks resolution — caught by SC-1/SC-3 structural checks and the SC-2 behavioral gate

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 — Structural reference-path corrections (A) | path-corrections | Rewrite stale task-relative Read-link targets in spec-creation task cards to the `../../../` canonical prefix; full-directory grep audit closes the sibling `create.md` defect | SC-1, SC-3 | — | 3–17 | direct (3, 10, 11, 16) + task-card (4–9, 12–15, 17) |
| 2 — Behavioral validation (B) | behavioral-gate | One isolated `with-test-home` validate dispatch proves the reference-deck integrity gate locates all 4 canonical files at the corrected paths, with no `reference-deck-integrity: FAIL` | SC-2 | Phase 1 | 18–25 | direct (18, 20, 22, 23) + task-card (19, 21, 24, 25) |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **Phase 1:** Verifying the path corrections costs one grep plus a path-existence check — seconds. Skipping means a mistyped corrected path re-breaks the reference-deck integrity gate, and the pipeline BLOCKS again at the next validate dispatch — discovered only when a real spec pipeline run halts, costing a full rework cycle.
- **Phase 2:** Running the isolated behavioral validate dispatch costs minutes of model execution — the bounded break cost. Skipping means the corrected paths ship unproven end-to-end and the first real validate dispatch in production use hits `reference-deck-integrity: FAIL` again — 1000× more expensive downstream, discovered only when a spec pipeline halts.

## Exit Criteria

- [ ] C1: All 3 SCs (SC-1, SC-2, SC-3) verified PASS with evidence artifacts
- [ ] C2: `validate.md` carries the 4 corrected `../../../` reference paths and no reference link in it resolves to a nonexistent path (SC-1)
- [ ] C3: `create.md` carries its 2 corrected reference paths and the full-directory grep audit of `.opencode/skills/spec-creation/` reports zero unresolvable `reference/` or `audit/reference/` mentions (SC-3)
- [ ] C4: One isolated behavioral validate run (via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`, standalone binary, bash timeout >= 600000 ms) passes the reference-deck integrity gate without `reference-deck-integrity: FAIL` (SC-2)
- [ ] C5: Behavioral-ordering invariant honored — the SC-2 commit and push (with fresh-fetch verification that the effective commit is contained in a remote ref) preceded the behavioral run
- [ ] C6: Audit DiMo chain, z3-check, structural checks, pre-PR gate, and final regression check all pass; the PR is created (stacked, one branch) and the completion summary is reported

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**direct**).** Read the spec at `.opencode/.issues/2444/spec.md` and this plan; confirm the plan's phase structure, SC assignments, dependency ordering (Phase 1 → Phase 2), and per-item SC mapping match the spec's Success Criteria and the structure artifact's phase decomposition. If any mismatch is found, return BLOCKED with `COHERENCE_FAIL`.
  - Verify the spec's SC table covers exactly the 3 SCs this plan maps, and that triplet colocation holds (no SC's steps split across phases)
  - SC reference: all (structure-level gate)

- [ ] 2. **Baseline check (**direct**).** Verify the current state of all affected files before modification — confirm the content matches the "before" state described in the spec. If any file has already been modified, return BLOCKED with `BASELINE_CHANGED`.
  - `.opencode/skills/spec-creation/tasks/validate.md`: task-relative `reference/` paths present (4 unique targets, 5 link instances, uncorrected)
  - `.opencode/skills/spec-creation/tasks/create.md`: same broken task-relative `reference/` pattern present (2 link instances, uncorrected)
  - `.opencode/skills/spec-creation/reference/`: contains only `sc-table-columns.md`; `.opencode/skills/audit/reference/`: does not exist
  - All 4 canonical target files exist at `.opencode/reference/` and `.opencode/audit/reference/`
  - SC reference: all (structure-level gate)

---

## Phase 1 — Structural Reference-Path Corrections (A)

**Concern:** Rewrite stale task-relative Read-link targets in spec-creation task cards to the `../../../` canonical prefix; full-directory grep audit closes the sibling `create.md` defect.

**Files:** `.opencode/skills/spec-creation/tasks/validate.md`, `.opencode/skills/spec-creation/tasks/create.md`

**SCs:** SC-1, SC-3

**Dependencies:** None (first phase)

**Entry Conditions:**
- Coherence gate and baseline check passed (steps 1–2)
- `.opencode` submodule on its feature branch at remote-tracking tip with zero pending changes (pre-work complete; parent-repo submodule pointer rides with the next real parent-repo change)
- `{project_root}/tmp/` exists for pipeline artifacts (`mkdir -p tmp/2444/artifacts`)

**Exit Conditions:**
- No reference link in `validate.md` resolves to a nonexistent path; all 4 corrected targets exist on disk (SC-1)
- `create.md`'s 2 link instances corrected; the full-directory grep audit reports zero unresolvable `reference/` or `audit/reference/` mentions in `.opencode/skills/spec-creation/` (SC-3)

### Code Path Coverage

- `validate.md` — 4 unique stale targets, 5 link instances, all corrected to the `../../../` prefix (tasks → spec-creation → skills → `.opencode`):
  - Read-link to `reference/spec-structure-standards.md` → `../../../reference/spec-structure-standards.md` (spec structure steps, early in the task)
  - Inline-code-path and Read-link mentions of `reference/holistic-dimensions.yaml` → `../../../reference/holistic-dimensions.yaml` (dimension-list load steps)
  - Read-link to `reference/cost-model-standards.md` → `../../../reference/cost-model-standards.md` (cost-frame step)
  - Prose see-reference to `audit/reference/decomposition-criteria.md` → `../../../audit/reference/decomposition-criteria.md` (decomposition-criteria step)
- `create.md` — 2 link instances, same idiom: Read-links to `reference/spec-structure-standards.md` and `reference/cost-model-standards.md` → `../../../reference/...` counterparts
- Canonical targets (read-only, unchanged): `.opencode/reference/holistic-dimensions.yaml`, `.opencode/reference/spec-structure-standards.md`, `.opencode/reference/cost-model-standards.md`, `.opencode/audit/reference/decomposition-criteria.md`

### Cross-Cutting SCs

- SC-3's audit scope includes SC-1's edit target (`validate.md`) — a verification-overlap, not a true cross-cutting concern; SC-3 must run after SC-1's corrections land, enforced by the within-phase item order (Item 1 → Item 2)
- Shared defect pattern across SC-1 and SC-3: task-relative `reference/` link; shared fix idiom: `../../../` prefix; no multi-concern coordination required (per the cross-cutting matrix artifact)

### Interface Boundaries

- task-card Read-link → canonical reference file boundary: link target strings change only; canonical file locations, names, and content are unchanged; compatibility risk NONE (per the interface-compatibility artifact)
- Constraint: canonical reference files must NOT be relocated or copied (spec Alternatives 1 and 2 ruled out — single-source-of-truth)
- Constraint: `validate.md` loads dimensions/taxonomy dynamically from the reference files and must NOT inline that content (spec Alternative 3 ruled out — reverses a design decision)

### State Transitions

- SC-1: `validate.md` reference links BROKEN (4 targets resolve to nonexistent paths; reference-deck-integrity: FAIL) → VALID (all targets resolve to existing canonical files) — filesystem-content, persistent, rollback via git revert
- SC-3: skill-directory grep audit state 7 stale mentions (5 in `validate.md` + 2 in `create.md`) → 0 stale mentions — filesystem-content, persistent, rollback via git revert of the `create.md` commit
- Global invariants: no reference-file content changes (canonical documents byte-identical); no new files in this phase; submodule discipline per the spec

**Cost frame:** Verifying the Phase 1 path corrections costs one grep plus a path-existence check — seconds. Skipping means a mistyped corrected path re-breaks the reference-deck integrity gate, and the pipeline BLOCKS again at the next validate dispatch — discovered only when a real spec pipeline run halts, costing a full rework cycle.

### Item 1 — validate.md 4 reference paths corrected (SC-1)

- [ ] 3. **Pre-clean (**direct**).** Remove stale pipeline artifacts for this step and subsequent steps: `rm -f tmp/2444/artifacts/pipeline-pre-regression-* tmp/2444/artifacts/pipeline-pre-regression-verify-* tmp/2444/artifacts/pipeline-red-* tmp/2444/artifacts/pipeline-green-* tmp/2444/artifacts/pipeline-post-regression-* tmp/2444/artifacts/pipeline-verify-*`
  - SC reference: SC-1

- [ ] 4. **Pre-regression (**task-card**).** Dispatch regression-test-pattern run before RED — verify current behavior against existing regression patterns so the baseline is green before the path-correction work begins.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - SC reference: SC-1

- [ ] 5. **Pre-regression verify (**task-card**).** Verify the pre-regression results; block the RED phase if the baseline is not green.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1

- [ ] 6. **RED (**task-card**).** Write a failing structural enforcement check for SC-1: a resolver that extracts every `reference/` or `audit/reference/` mention from `validate.md`, resolves each relative to the task-file directory, and asserts every resolved path exists on the filesystem. The check FAILS today because 4 link targets (3 under `reference/`, 1 under `audit/reference/`) do not exist at the task-relative locations.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED describes what fails: task-relative resolution misses the canonical files that live at `.opencode/reference/` and `.opencode/audit/reference/`
  - SC reference: SC-1

- [ ] 7. **GREEN (**task-card**).** Implement the minimum change that makes the RED check pass: rewrite the stale task-relative targets in `validate.md` with the `../../../` prefix — 3 targets to `.opencode/reference/` counterparts and 1 prose mention to `../../../audit/reference/decomposition-criteria.md`. No other content edits, no new files, no reference-file changes.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN describes what must be true: every `reference/` or `audit/reference/` mention in `validate.md` resolves to an existing path when resolved from the task-file directory
  - SC reference: SC-1

- [ ] 8. **Post-regression (**task-card**).** Run regression test patterns after GREEN — confirm the corrections did not disturb any existing behavior.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-1

- [ ] 9. **Verify (**task-card**).** Verify SC-1 against its success criterion: re-run the resolver over `validate.md` — every reference link resolves; the 4 corrected targets exist on disk (filesystem check, not memory).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1

- [ ] 10. **Commit-inline (**direct**).** Stage and commit the path corrections: `git add .opencode/skills/spec-creation/tasks/validate.md && git commit -m "spec-creation: correct 4 stale reference paths in validate.md (.opencode#2444 SC-1)"`
  - Test and implementation committed as one atomic slice; no co-author trailers
  - SC reference: SC-1

### Item 2 — create.md sibling fix + full-directory grep audit (SC-3)

- [ ] 11. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2444/artifacts/pipeline-red-* tmp/2444/artifacts/pipeline-green-* tmp/2444/artifacts/pipeline-post-regression-* tmp/2444/artifacts/pipeline-verify-*`
  - SC reference: SC-3

- [ ] 12. **RED (**task-card**).** Write a failing full-directory audit for SC-3: grep every `reference/` or `audit/reference/` mention across `.opencode/skills/spec-creation/` (all task cards, `SKILL.md`, skill `reference/`), resolve each mention relative to its containing file's directory, and assert zero failing resolutions. The audit FAILS today because `create.md` still carries 2 stale task-relative mentions (`validate.md` was corrected in Item 1).
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED describes what fails: the sibling `create.md` defect leaves the pipeline blocked at the create step even after `validate.md` is corrected
  - SC reference: SC-3

- [ ] 13. **GREEN (**task-card**).** Implement the minimum change that makes the audit pass: rewrite `create.md`'s 2 stale targets (Read-links to the spec-structure and cost-model references) with the `../../../` prefix. No other content edits, no new files, no reference-file changes.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN describes what must be true: every `reference/` or `audit/reference/` mention anywhere in `.opencode/skills/spec-creation/` resolves to an existing path
  - SC reference: SC-3

- [ ] 14. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-3

- [ ] 15. **Verify (**task-card**).** Verify SC-3 against its success criterion: re-run the full-directory grep audit — zero unresolvable `reference/` or `audit/reference/` mentions across `.opencode/skills/spec-creation/` (covers both corrected files; `SKILL.md`'s repo-root-relative links resolve correctly and are out of defect scope).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-3

- [ ] 16. **Commit-inline (**direct**).** Stage and commit the sibling fix: `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "spec-creation: correct stale reference paths in create.md (.opencode#2444 SC-3)"`
  - SC reference: SC-3

#### Phase 1 VbC

- [ ] 17. **VbC (**task-card**).** Verify Phase 1 completion: every `reference/` or `audit/reference/` mention in `.opencode/skills/spec-creation/` resolves to an existing path (SC-1, SC-3); both commits present on the branch; canonical reference files byte-identical (no content drift). All SCs carry evidence artifacts.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1, SC-3

**Concern transition:** Leaving structural reference-path corrections → entering behavioral validation. Phase 2 measures the corrected paths (Phase 1) through one isolated real validate dispatch.

---

## Phase 2 — Behavioral Validation (B)

**Concern:** One isolated `with-test-home` validate dispatch proves the reference-deck integrity gate locates all 4 canonical files at the corrected paths, with no `reference-deck-integrity: FAIL`.

**Files:** `.opencode/tests-v2/behaviors/<scenario>.sh` (new scenario script, if retained as enforcement artifact), `{project_root}/tmp/2444/artifacts/` (behavioral evidence)

**SCs:** SC-2

**Dependencies:** Phase 1 (SC-2's behavioral run exercises `validate.md`'s corrected reference paths — the corrections must be committed and pushed before the isolated validate dispatch can pass the gate)

**Entry Conditions:**
- Phase 1 complete with VbC passed; both path-correction commits present on the branch
- Standalone opencode binary cached at `.tools/opencode/opencode` (spec Implicit Preconditions; harness copies it to `$TEST_HOME/bin` during setup)
- `{project_root}/tmp/` clean of stale locks (`rm -f tmp/.behavior-run.lock` before the run)
- Bash tool timeout >= 600000 ms available for the behavioral run (default 120 s kills model inference mid-run)

**Exit Conditions:**
- The isolated behavioral validate run passes the reference-deck integrity gate without `reference-deck-integrity: FAIL` (SC-2)
- Behavioral-ordering invariant honored: the SC-2 commit and push (with fresh-fetch verification that the effective commit is contained in a remote ref) preceded the behavioral run

### Code Path Coverage

- New behavioral scenario script (artifact-only generator per the tests-v2 AGENTS.md artifact paradigm): harness invocation `bash .opencode/tests-v2/with-test-home opencode run '<message>'` → isolated session executes the validate task → session.yaml export to the evidence directory
- `validate.md` executed as a task card at dispatch time — its 4 corrected links resolve at dispatch time inside the reference-deck integrity check
- Harness path: standalone binary resolution → test-home setup → session export (`__export_sqlite_to_yaml` searches stderr for `TEST_HOME=<path>` as fallback when stdout is empty — the timeout case)

### Cross-Cutting SCs

- SC-2 is behavioral but confined to the validate concern's file — it does NOT exercise `create.md`, so it does not span the sibling-audit concern (per the cross-cutting matrix artifact)
- SC-2 depends on SC-1 (behavioral gate verification requires the 4 corrected paths to exist first) — satisfied by the Phase 1 → Phase 2 DAG edge; producer phases precede consumer phases

### Interface Boundaries

- `with-test-home` CLI contract: invocation form is `bash .opencode/tests-v2/with-test-home opencode run '<message>'` — direct `opencode run` is PROHIBITED (test-framework discipline; causes SQLite session conflicts with the desktop app)
- Behavioral evidence source: the run's session export (agent actions), never stdout prose recall
- Substitution prohibited (critical-rules-060): if the behavioral test cannot execute, the only valid outcome is FAIL — grep/structural substitutes are forbidden; harness breakage remediates via harness repair, never evidence substitution
- Artifact-only generator paradigm: the scenario script generates artifacts and exits 0 — it does not evaluate model output inline

### State Transitions

- SC-2: reference-deck integrity gate BLOCKED (every validate dispatch fails; observed 2026-09-12 on the NewSRX-Tech-LLC/Butter#346 spec-issue run with `reference-deck-integrity: FAIL`) → PASS (isolated validate run passes the gate without `reference-deck-integrity: FAIL`) — runtime-agent-dispatch, not persistent; regression detected by re-running the scenario
- Precondition chain: SC-1 complete → with-test-home harness functional → standalone binary cached → behavioral run executes

**Cost frame:** Running the isolated behavioral validate dispatch costs minutes of model execution — the bounded break cost. Skipping means the corrected paths ship unproven end-to-end and the first real validate dispatch in production use hits `reference-deck-integrity: FAIL` again — 1000× more expensive downstream, discovered only when a spec pipeline halts.

### Item 3 — isolated behavioral validate dispatch passes reference-deck gate (SC-2)

- [ ] 18. **Pre-clean (**direct**).** Remove stale artifacts and locks: `rm -f tmp/2444/artifacts/pipeline-red-* tmp/2444/artifacts/pipeline-green-* tmp/2444/artifacts/pipeline-post-regression-* tmp/2444/artifacts/pipeline-verify-* tmp/.behavior-run.lock`
  - SC reference: SC-2

- [ ] 19. **RED (**task-card**).** Write the failing behavioral enforcement check for SC-2: an artifact-only scenario script that drives `bash .opencode/tests-v2/with-test-home opencode run '<message>'` through a validate-task dispatch and asserts the run passes the reference-deck integrity gate without `reference-deck-integrity: FAIL`. The RED state is demonstrated against the pre-fix failure evidence — the 2026-09-12 blocked validate run (NewSRX-Tech-LLC/Butter#346) documented in the spec's Evidence section — recorded from the documented pre-fix state, not by re-breaking the corrected files.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED describes what fails: on the pre-fix state, every validate dispatch BLOCKS at the reference-deck integrity gate; the scenario's pass-assertion is unmeetable
  - SC reference: SC-2

- [ ] 20. **GREEN — n/a (**direct**).** GREEN is n/a for this item: the path corrections landed in Phase 1 Items 1–2; this item re-verifies end-to-end that the behavioral assertions hold. Record the n/a rationale in the step's evidence artifact (precedent: the behavioral end-to-end item in the #2434 plan).
  - SC reference: SC-2

- [ ] 21. **Post-regression (**task-card**).** Run regression test patterns after GREEN — confirm the new scenario coexists with the existing behavioral suite without disturbing it.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-2

- [ ] 22. **Commit-inline (**direct**).** Stage and commit the scenario script: `git add .opencode/tests-v2/behaviors/<scenario>.sh && git commit -m "test-framework: SC-2 behavioral scenario — validate dispatch reference-deck gate (.opencode#2444 SC-2)"`
  - SC reference: SC-2

- [ ] 23. **Push + fresh-fetch verify (**direct**).** Push the `.opencode` submodule branch to its remote, run a fresh `git fetch`, and verify the effective commit is contained in a remote ref. Mandatory per the 091-incremental-build behavioral variant: COMMIT and PUSH precede the behavioral test run — the harness pre-flight gate hard-FAILs on uncommitted or unpushed submodule state, so the run would otherwise never execute.
  - SC reference: SC-2

- [ ] 24. **Verify — behavioral run (**task-card**).** Execute the isolated behavioral validate dispatch: `bash .opencode/tests-v2/with-test-home opencode run '<message>'` via the bash tool with timeout >= 600000 ms. Assert the run passes the reference-deck integrity gate without `reference-deck-integrity: FAIL`. Evidence from the session export (agent actions in session.yaml), never prose recall. If the harness cannot execute, the verdict is FAIL with harness repair as remediation — no evidence substitution.
  - Launch with the full >= 600000 ms bash timeout (behavioral runs die at the default 120 s); remove `tmp/.behavior-run.lock` before any re-run
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-2

#### Phase 2 VbC

- [ ] 25. **VbC (**task-card**).** Verify Phase 2 completion: SC-2 behavioral evidence artifact exists (session export showing the validate dispatch passed the reference-deck integrity gate); the behavioral-ordering invariant held (commit + push + fresh-fetch verification before the run). SC-2 carries an evidence artifact.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-2

**Concern transition:** Leaving behavioral validation → entering post-implementation gates. All 3 SCs must be verified PASS before the audit and PR gates run.

---

## Post-Implementation Steps

- [ ] 26. **Audit (**task-card**).** Adversarial audit of the deliverable against the spec — plan fidelity (per-phase cost frames per dark-prose-007, daisy-chain, per-item SC mapping), cross-validation of verification results, and independent re-verification of deliverables modified in response to audit findings.
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - SC reference: all

- [ ] 27. **z3-check (**direct**).** Run the Z3 constraint solver verification of the phase state against the dependency contract: `.opencode/tools/solve check --state-path .opencode/.issues/2444/artifacts/state-z3-goal.yaml --contract-path .opencode/.issues/2444/dependency-contract.yaml`. Record the output to `tmp/2444/artifacts/pipeline-z3-check-*` and compare against the research-phase solver result recorded in `.opencode/.issues/2444/artifacts/solve-output.yaml`.
  - SC reference: all

- [ ] 28. **Structural checks (**task-card**).** Run the finishing checklist — lint, typecheck, markdown format checks, dead-code scan as applicable to the modified files (markdown-only edits: markdown lint and format check are the applicable advisory checks).
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - SC reference: all

- [ ] 29. **Pre-PR gate (**task-card**).** Read all SC verdicts — SC-1, SC-2, SC-3 — and BLOCK if any verdict is FAIL (DONE_WITH_CONCERNS coerces to FAIL per the implementation-workflow coercion rules; EVIDENCE_TYPE_MISMATCH coerces to FAIL).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: all

- [ ] 30. **Regression check (**task-card**).** Final regression check before PR.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: all

- [ ] 31. **Review-prep (**task-card**).** Prepare PR review context.
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - SC reference: all

- [ ] 32. **Create PR (**task-card**).** Create the pull request (stacked strategy — one branch, squashed commits per issue, PR targets the trunk).
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Co-author trailers are added during squash at PR time, never in implementation commits
  - Parent-repo submodule pointer rides along with the next real parent-repo change — never a standalone pointer-only PR
  - SC reference: all

- [ ] 33. **Executive summary (**task-card**).** Generate the completion executive summary and append the lifecycle event.
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - SC reference: all

---

## Verification Coverage Matrix

| SC | Item | Phase | Evidence Type | Verification |
|----|------|-------|---------------|--------------|
| SC-1 | Item 1 | 1 | structural | Resolver check — every `reference/` or `audit/reference/` mention in `validate.md` resolves; the 4 corrected targets exist on disk |
| SC-2 | Item 3 | 2 | behavioral | Isolated `with-test-home` validate dispatch passes the reference-deck integrity gate without `reference-deck-integrity: FAIL` |
| SC-3 | Item 2 | 1 | structural | Full-directory grep audit — zero unresolvable `reference/` or `audit/reference/` mentions in `.opencode/skills/spec-creation/` |

## Lifecycle Events

- **20260913192543** — `plan_created` — plan file: `.opencode/.issues/2444/plan.md` — phase count: 2 (+ post-implementation). Appended by writing-plans create task.
