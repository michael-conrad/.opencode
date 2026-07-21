---
title: "[SPEC] Enforce trunk-tip verification and submodule pointer sync before pre-work"
status: draft
created: 2026-07-21
license: MIT
provenance: AI-generated
issue: 2058
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-21

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The orchestrator routinely bypasses the `git-workflow --task pre-work` pipeline step, which includes mandatory `trunk-tip-verification.md` and submodule pointer synchronization. This produces PRs built on stale bases with dirty submodule state and missing submodule pointer updates, causing failed deploys.

## Root Cause Analysis

The `trunk-tip-verification.md` gate (at `git-workflow-branch/tasks/trunk-tip-verification.md`) defines a 6-step verification procedure that checks parent repo trunk tip, submodule trunk tip, and submodule pointer cleanliness. This gate exists but is never reached because the orchestrator skips the `pre-work` dispatch entirely.

The `pre-commit-pointer-check.md` task (at `git-workflow-branch/tasks/pre-commit-pointer-check.md`) detects dirty submodule pointers before commit and ensures they are staged alongside non-submodule changes. This task is also routinely skipped.

The root cause is twofold:
1. **No enforcement at the orchestrator level** — there is no mechanism that forces the orchestrator to call `skill({name: "git-workflow"})` -> `task("execute pre-work from git-workflow-branch")` before any file modification. The pre-work step is advisory, not mandatory.
2. **No enforcement at the commit/push gate** — there is no pre-commit or pre-push gate that verifies submodule pointer updates are included in commits when submodule changes are part of the PR scope.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Goals

1. The orchestrator MUST call `skill({name: "git-workflow"})` -> `task("execute pre-work from git-workflow-branch")` before any file modification, and the pre-work task MUST fail BLOCKED if trunk-tip verification fails.
2. The pre-commit or pre-push gate MUST verify that if a submodule pointer is dirty AND the submodule has changes that are part of the PR scope, the pointer update is included in the commit.

## Non-Goals

- **Submodule pointer auto-commit** — This spec does NOT add automatic submodule pointer commits. The pointer update must be verified as included, not auto-included.
- **Pre-work task redesign** — The existing `pre-work.md` and `trunk-tip-verification.md` task files are correct. This spec only adds enforcement that they are called.
- **Git hook changes** — This spec does NOT modify `.opencode/hooks/`. Enforcement is at the orchestrator dispatch level and the pre-commit/pre-push gate level.

## Constraints and Scope

- Changes are limited to `.opencode/` submodule (guidelines, skills, enforcement tests)
- The existing `trunk-tip-verification.md` and `pre-commit-pointer-check.md` task files MUST NOT be modified — they are correct
- Enforcement MUST be behavioral (agent dispatch behavior), not structural (file existence)

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Add a git hook that blocks commits without pre-work | Git hooks are bypassable with `--no-verify`. The orchestrator-level enforcement is the only non-bypassable gate. |
| Modify `trunk-tip-verification.md` to be self-enforcing | The task file is correct — the problem is that it is never called. Adding self-enforcement to a task file that is never reached does not solve the problem. |
| Add a pre-commit hook that verifies submodule pointers | The `pre-commit-pointer-check.md` task already exists and is correct. The problem is that it is never dispatched. |

## Safety Considerations

- No destructive operations are involved
- The enforcement is behavioral (agent dispatch), not structural (file modification)
- Rollback: revert the guideline/skill changes and behavioral test changes

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#2058](https://github.com/michael-conrad/.opencode/issues/2058) | SELF | This spec |

## Evidence/Provenance

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `git-workflow-branch/tasks/trunk-tip-verification.md` | Verify existing 6-step gate procedure |
| Direct source search | `git-workflow-branch/tasks/pre-work.md` | Verify pre-work task includes trunk-tip verification as Step 0 |
| Direct source search | `git-workflow-branch/tasks/pre-commit-pointer-check.md` | Verify pre-commit pointer check task exists |
| Direct source search | `git-workflow/SKILL.md` | Verify Invocation section and canonical dispatch strings |
| Direct source search | `git-workflow-branch/SKILL.md` | Verify Trigger Dispatch Table and task list |
| Live verification | `gh issue view 2058 --repo michael-conrad/.opencode` | Read bug report body |

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | A critical violation section is added to `000-critical-rules.md` stating that the orchestrator MUST call `skill({name: "git-workflow"})` -> `task("execute pre-work from git-workflow-branch")` before any file modification, and that starting work from a non-trunk-tip state is a CRITICAL VIOLATION | `behavioral` — `bash .opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` produces PASS with `assert_semantic` confirming agent dispatches pre-work before file modification | On FAIL: verify the critical violation section text is present and the behavioral test assertion matches the required dispatch pattern | red-green | `.opencode/.issues/2058/behavioral/` | Root Cause: orchestrator skips pre-work dispatch entirely | Phase 1 | pre-commit | sequential | A | null | `trunk-tip-enforcement.sh` | Phase 1 |
| SC-2 | A critical violation section is added to `000-critical-rules.md` stating that the pre-commit or pre-push gate MUST verify submodule pointer updates are included in commits when submodule changes are part of the PR scope | `behavioral` — `bash .opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` produces PASS with `assert_semantic` confirming agent verifies submodule pointer inclusion before commit/push | On FAIL: verify the critical violation section text is present and the behavioral test assertion matches the required verification pattern | red-green | `.opencode/.issues/2058/behavioral/` | Root Cause: pre-commit-pointer-check task is routinely skipped | Phase 1 | pre-commit | sequential | A | null | `submodule-pointer-enforcement.sh` | Phase 1 |
| SC-3 | Behavioral enforcement tests exist at `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` and `.opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` that verify RED state (test fails before change) and GREEN state (test passes after change) | `behavioral` — `bash .opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` fails before change and passes after change; same for `submodule-pointer-enforcement.sh` | On FAIL: verify test files exist and produce correct RED/GREEN behavior | red-green | `.opencode/.issues/2058/behavioral/` | Root Cause: no behavioral enforcement tests exist for either rule | Phase 1 | pre-commit | sequential | A | null | `trunk-tip-enforcement.sh`, `submodule-pointer-enforcement.sh` | Phase 1 |
| SC-4 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` — `bash .opencode/tests-v2/behaviors/sc-lobotomy-enforcement.sh` with `assert_semantic` confirming agent does not weaken SCs | On FAIL: restore original SC evidence type and re-verify | post-implementation | `.opencode/.issues/2058/behavioral/` | Anti-Lobotomization mandate | Phase 1 | post-implementation | sequential | A | null | `sc-lobotomy-enforcement.sh` | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/2058/plan.md` before implementation begins.

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation | Verifying SC |
|------|-----------|--------|------------|--------------|
| Behavioral test times out due to model unavailability | Medium | High — test cannot verify agent behavior | Apply remediation-first protocol: increase timeout, try alternative model, inspect stdout/stderr logs | SC-3 |
| Existing behavioral tests break due to new enforcement | Low | Medium — CI pipeline fails | Run full behavioral suite after change to verify no regressions | SC-3 |
| Agent finds a way to bypass the new critical violation | Low | High — defeats the purpose of the spec | The behavioral test is the enforcement — if the agent bypasses, the test fails | SC-1, SC-2 |

## Implementation Approach

This is a single-phase, single-task spec. The implementation plan will:

1. Add critical violation sections to `000-critical-rules.md` for:
   - [critical-rules-XXX] Starting work from non-trunk-tip state (Tier 1)
   - [critical-rules-XXX] Pre-commit/pre-push submodule pointer verification (Tier 1)
2. Create behavioral enforcement tests at `.opencode/tests-v2/behaviors/`:
   - `trunk-tip-enforcement.sh` — verifies agent dispatches pre-work before file modification
   - `submodule-pointer-enforcement.sh` — verifies agent checks submodule pointer inclusion before commit/push
3. Run RED phase (tests fail before change), then GREEN phase (tests pass after change)

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Add critical violation sections to `000-critical-rules.md` | The existing `trunk-tip-verification.md` and `pre-commit-pointer-check.md` task files are correct — the problem is they are never dispatched. Adding Tier 1 critical violations creates non-waivable enforcement at the orchestrator level. | MUST | SC-1, SC-2 |
| DEC-2 | Behavioral enforcement tests use `assert_semantic` for primary evidence | Per the Evidence Type Taxonomy, behavioral SCs require behavioral evidence. `assert_semantic` with a clean-room AI inspector is the only valid assertion type for verifying agent dispatch decisions. | MUST | SC-1, SC-2, SC-3 |
| DEC-3 | Single-phase implementation | The two critical violations are independent but closely related (both address pre-work enforcement). A single phase with sequential RED/GREEN per item is appropriate. | MUST | SC-1, SC-2, SC-3, SC-4 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Phase Artifact Requirements | PR Strategy |
| -------------- | ---------------- | --------------------------- | ----------- |
| single-task | 1 | Single `plan.md` file | single PR |

## Regression Invariants

- [ ] 1. Existing `trunk-tip-verification.md` task file MUST NOT be modified
- [ ] 2. Existing `pre-commit-pointer-check.md` task file MUST NOT be modified
- [ ] 3. Existing `pre-work.md` task file MUST NOT be modified
- [ ] 4. Existing behavioral enforcement tests MUST continue to pass

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `git-workflow-branch/tasks/trunk-tip-verification.md` | Verify existing 6-step gate procedure |
| Direct source search | `git-workflow-branch/tasks/pre-work.md` | Verify pre-work task includes trunk-tip verification as Step 0 |
| Direct source search | `git-workflow-branch/tasks/pre-commit-pointer-check.md` | Verify pre-commit pointer check task exists |
| Direct source search | `git-workflow/SKILL.md` | Verify Invocation section and canonical dispatch strings |
| Direct source search | `git-workflow-branch/SKILL.md` | Verify Trigger Dispatch Table and task list |
| Live verification | `gh issue view 2058 --repo michael-conrad/.opencode` | Read bug report body |

Co-authored with AI: OpenCode (deepseek-v4-flash)
