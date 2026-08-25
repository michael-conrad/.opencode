> **Full spec and artifacts: [`.opencode/.issues/2320/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2320/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2320/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Fix submodule pointer guidance — pointer rides alongside real root changes (not dropped)

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Agent-facing guidance is ambiguous about whether a merged submodule PR resolves the parent repo's submodule pointer. The enforcement-gate message "Submodule SHA already updated by submodule PR merge. No parent PR needed." can be misread as permission to drop the root pointer, contradicting the mandate that the pointer must be committed alongside real root-repo changes. |
| 2 | **Root Cause / Motivation** | The root AGENTS.md and the git-workflow skill task files describe the pointer lifecycle inconsistently. The enforcement-gate's "No parent PR needed" wording conflates the submodule-merge event with the root pointer update, so an agent may conclude the pointer is resolved and never commit it. This produces a stale root pointer that breaks downstream builds. |
| 3 | **Approach Chosen** | Revise the agent-facing guidance text (root AGENTS.md §Submodule Pointer Updates, enforcement-gate.md Step 0.5, pre-commit-pointer-check.md, pr-creation.md Pre-Push verification, branch-cleanup.md Step 1.7) so every location states the same unambiguous rule: the pointer rides ALONGSIDE the next real root-repo change on a feature branch and is never dropped and never pushed in a standalone pointer-only commit. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: change the submodule-bump-only PR prohibition itself** (allow standalone pointer-only parent PRs). Discarded because the prohibition exists to prevent review overhead for pointer-only PRs with zero functional change; loosening it would reintroduce that overhead and contradict the established invariant. |
| 5 | **Key Design Decisions** | (1) Preserve the submodule-bump-only PR prohibition — the fix only reconciles wording, never the invariant. (2) Preserve the dirty-pointer-cleanup-exemption — cleanup leaves dirty pointers uncommitted. (3) All changes are agent-facing documentation text; no code, hooks, or git tooling change. (4) Verification is behavioral — an agent must follow the updated guidance, so structural/string evidence is EVIDENCE_TYPE_MISMATCH. |
| 6 | **User Intent / Original Prompt** | "[SPEC] Fix submodule pointer guidance: pointer rides alongside real root changes (not dropped)" — the issue title requesting reconciliation of the pointer-drop ambiguity. |

## 2. Not Included

- **[Changing the submodule-bump-only PR prohibition]** — The invariant that a parent-repo submodule-pointer-only PR is blocked is preserved and not loosened.
- **[Creating new git tooling or hooks]** — The change is limited to agent-facing guidance text (AGENTS.md, skill task files); no code or hook changes.
- **[Modifying the submodule repo's own PR workflow]** — A submodule repo filing its own PR for its own changes is normal and out of scope.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | Root AGENTS.md §Submodule Pointer Updates states that the submodule pointer rides ALONGSIDE the next real root-repo change on a feature branch and is NOT dropped when a submodule PR merges. | behavioral | `opencode run` with a sub-agent prompt where a root repo has a dirty pointer and a real root change pending; assert the agent stages and commits the pointer alongside the root change and does not create a pointer-only commit. | `AGENTS.md` §Submodule Pointer Updates |
| SC-2 | enforcement-gate.md Step 0.5 wording is reconciled so "Submodule SHA already updated by submodule PR merge. No parent PR needed." cannot be misread as permission to drop the root pointer; the message clarifies the pointer still rides alongside the next real root change. | behavioral | `opencode run` with a sub-agent prompt describing a submodule-bump-only branch; assert the agent closes the branch per the gate AND records that the root pointer rides alongside the next real root change (does not claim the pointer was resolved/dropped by the submodule merge). | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` Step 0.5 |
| SC-3a | pre-commit-pointer-check.md uses unambiguous pointer-rides-alongside language: a dirty pointer is staged and committed alongside a real root change, never dropped and never committed standalone. | behavioral | `opencode run` with a sub-agent prompt where the agent reads pre-commit-pointer-check.md and a root repo has a dirty pointer plus a real root change; assert the agent stages and commits the pointer alongside the root change. | `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` |
| SC-3b | pr-creation.md §Pre-Push Submodule Pointer Verification uses unambiguous pointer-rides-alongside language: a merged submodule PR does NOT resolve the root pointer; the pointer rides alongside the next real root change. | behavioral | `opencode run` with a sub-agent prompt where the agent reads pr-creation.md §Pre-Push and a root repo has a dirty pointer before pushing; assert the agent verifies the pointer is committed alongside a real root change and does not treat the submodule merge as resolving it. | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` §Pre-Push |
| SC-3c | branch-cleanup.md Step 1.7 uses unambiguous pointer-rides-alongside language: a dirty pointer during post-merge cleanup is expected, left uncommitted (cleanup exemption), and rides alongside the next real root change. | behavioral | `opencode run` with a sub-agent prompt where the agent reads branch-cleanup.md Step 1.7 and observes a dirty submodule pointer during cleanup; assert the agent leaves the pointer uncommitted and records that it rides alongside the next real root change. | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` §Step 1.7 |

## 4. Requirements

- R-1. The root AGENTS.md §Submodule Pointer Updates SHALL state that the submodule pointer update rides ALONGSIDE the next real root-repo change on a feature branch and is NOT dropped when a submodule PR merges.
- R-2. The enforcement-gate.md Step 0.5 closure message SHALL clarify that a merged submodule PR does NOT resolve the root pointer; the pointer still rides alongside the next real root change.
- R-3. The submodule-bump-only parent PR prohibition SHALL be preserved; the pointer MUST NOT be committed in a standalone parent-repo commit/PR.
- R-4. The pointer SHALL ride alongside the next real root-repo change on a feature branch, not be dropped and not be separately pushed.
- R-5. The dirty-pointer-cleanup-exemption SHALL be preserved: during post-merge cleanup, dirty submodule pointers are acknowledged as expected and left uncommitted.
- R-6. All three task files (pre-commit-pointer-check.md, pr-creation.md §Pre-Push, branch-cleanup.md Step 1.7) SHALL use consistent, unambiguous pointer-rides-alongside language.
- R-7. All changes SHALL be limited to agent-facing documentation/guidance text; no code, hooks, or git tooling changes SHALL be made.
- R-8. Verification of each change SHALL be behavioral (an agent follows the updated guidance) via `opencode run` under the with-test-home harness.

## 5. Items

### Item 1 (SC-1): Clarify root AGENTS.md §Submodule Pointer Updates

- RED: Behavioral test asserting the current agent does NOT clearly state the pointer rides alongside a real root change (ambiguity allows pointer-drop).
- GREEN: Revise root AGENTS.md §Submodule Pointer Updates to state the pointer must be committed alongside the next real root-repo change, never dropped.
- verify: `opencode run` with a sub-agent prompt; assert the agent commits the pointer alongside a real root change and does not create a pointer-only commit.
- commit: Root AGENTS.md revision + behavioral test.

### Item 2 (SC-2): Reconcile enforcement-gate.md Step 0.5 wording

- RED: Behavioral test asserting the agent reads "No parent PR needed" as permission to drop the root pointer.
- GREEN: Revise enforcement-gate.md Step 0.5 closure message to clarify the merged submodule PR does NOT drop the root pointer; the pointer still rides alongside the next real root change.
- verify: `opencode run` with a sub-agent prompt; assert the agent closes the branch per the gate AND records that the pointer rides alongside the next real root change.
- commit: enforcement-gate.md revision + behavioral test.

### Item 3a (SC-3a): Align pre-commit-pointer-check.md pointer-rides-alongside language

- RED: Behavioral test asserting the agent reads pre-commit-pointer-check.md and does NOT clearly stage/commit the dirty pointer alongside a real root change.
- GREEN: Revise pre-commit-pointer-check.md to state the pointer must be committed alongside a real root change, never dropped and never standalone.
- verify: `opencode run` with a sub-agent prompt where the agent reads pre-commit-pointer-check.md; assert the agent commits the pointer alongside a real root change.
- commit: pre-commit-pointer-check.md revision + behavioral test.

### Item 3b (SC-3b): Align pr-creation.md §Pre-Push pointer-rides-alongside language

- RED: behavioral test asserting the agent reads pr-creation.md §Pre-Push and treats the submodule merge as resolving the root pointer.
- GREEN: Revise pr-creation.md §Pre-Push to clarify the submodule merge does NOT resolve the pointer; it rides alongside the next real root change.
- verify: `opencode run` with a sub-agent prompt where the agent reads pr-creation.md §Pre-Push; assert the agent verifies the pointer is committed alongside a real root change.
- commit: pr-creation.md §Pre-Push revision + behavioral test.

### Item 3c (SC-3c): Align branch-cleanup.md Step 1.7 pointer-rides-alongside language

- RED: behavioral test asserting the agent reads branch-cleanup.md Step 1.7 and mishandles a dirty pointer during cleanup.
- GREEN: Revise branch-cleanup.md Step 1.7 to state a dirty pointer is expected, left uncommitted (cleanup exemption), and rides alongside the next real root change.
- verify: `opencode run` with a sub-agent prompt where the agent reads branch-cleanup.md Step 1.7; assert the agent leaves the pointer uncommitted and records it rides alongside the next real root change.
- commit: branch-cleanup.md Step 1.7 revision + behavioral test.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `AGENTS.md` §Submodule Pointer Updates (root) | Establishes the pointer-rides-alongside principle; Item 2 and Items 3a-3c align to it | Satisfied (existing guidance) |
| `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` | Item 3a aligns its wording to the principle | Satisfied (existing task file) |
| `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` §Pre-Push | Item 3b aligns its wording to the principle | Satisfied (existing task file) |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` §Step 1.7 | Item 3c aligns its wording to the principle | Satisfied (existing task file) |
| `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` Step 0.5 | Item 2 reconciles its wording against the principle | Satisfied (existing task file) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-1, SC-2, SC-3a, SC-3b, SC-3c | Phase 1 |
| R-4 | SC-1, SC-3a, SC-3b | Phase 1 |
| R-5 | SC-3c | Phase 1 |
| R-6 | SC-3a, SC-3b, SC-3c | Phase 1 |
| R-7 | SC-1, SC-2, SC-3a, SC-3b, SC-3c | Phase 1 |
| R-8 | SC-1, SC-2, SC-3a, SC-3b, SC-3c | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Root AGENTS.md §Submodule Pointer Updates | doc | `AGENTS.md` | read |
| enforcement-gate.md Step 0.5 | doc | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` | read |
| pre-commit-pointer-check.md | doc | `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` | read |
| pr-creation.md §Pre-Push | doc | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | read |
| branch-cleanup.md §Step 1.7 | doc | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral test costs minutes of execution time. Skipping means the ambiguous root guidance lets an agent drop the pointer, shipping a stale root pointer that breaks downstream builds — a defect discovered in production at 1000× the fix cost.
- SC-2: Running the behavioral test costs minutes of execution time. Skipping means the "No parent PR needed" message continues to read as pointer-drop authorization, and the root pointer is silently never committed.
- SC-3a: Running the behavioral test costs minutes of execution time. Skipping means pre-commit-pointer-check.md guidance lets an agent drop the pointer before commit, shipping a stale root pointer that breaks downstream builds.
- SC-3b: Running the behavioral test costs minutes of execution time. Skipping means pr-creation.md §Pre-Push guidance lets an agent treat the submodule merge as resolving the pointer, and the root pointer is silently never committed.
- SC-3c: Running the behavioral test costs minutes of execution time. Skipping means branch-cleanup.md Step 1.7 guidance misleads an agent into mishandling a dirty pointer during cleanup.

## 11. Edge Cases

- **Condition:** A submodule repo PR merges while the root repo has no pending real change.
  - **Expected behavior:** The root pointer stays dirty; it is NOT dropped and NOT committed standalone.
  - **Resolution:** The pointer rides alongside the next real root-repo change on a feature branch.
- **Condition:** Post-merge cleanup observes a dirty submodule pointer.
  - **Expected behavior:** The pointer is acknowledged as expected and left uncommitted.
  - **Resolution:** The dirty-pointer-cleanup-exemption applies; the pointer rides alongside the next real change.
- **Condition:** An agent encounters a submodule-bump-only branch during PR creation.
  - **Expected behavior:** The branch is closed per the enforcement gate; the message clarifies the pointer still rides alongside the next real root change.
  - **Resolution:** The submodule-bump-only PR prohibition is preserved; the closure message no longer implies pointer-drop.
- **Condition:** A real root change is committed while the pointer is dirty.
  - **Expected behavior:** The pointer is staged and committed alongside the real change.
  - **Resolution:** The pointer-rides-alongside rule applies; the pointer transitions from DIRTY to CLEAN.
- **Condition:** An agent reads different task files in the same session.
  - **Expected behavior:** The agent applies the identical pointer lifecycle rule regardless of source file.
  - **Resolution:** Consistent language across pre-commit-pointer-check.md, pr-creation.md §Pre-Push, and branch-cleanup.md Step 1.7 prevents divergent behavior.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-24 | Decomposed compound SC-3 into atomic SC-3a (pre-commit-pointer-check.md), SC-3b (pr-creation.md §Pre-Push), and SC-3c (branch-cleanup.md Step 1.7), each with its own behavioral evidence method and Documentation Source. Updated Item 3→3a/3b/3c, Dependencies, Traceability, Cost Frame, and Edge Cases to reference the decomposed SCs. | Validation finding: SC-3 was a compound SC bundling three task-file changes via comma-separated list + "and", failing Atomicity and Single Deliverable decomposition criteria. | Spec-creation validation pipeline |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
