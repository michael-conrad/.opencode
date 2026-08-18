> **Full spec and artifacts: [`.opencode/.issues/2293/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2293/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2293/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

The "Submodule-only PR prohibition" (critical-rules-049) is worded as a global prohibition ("NEVER create a submodule-only PR in ANY context, for ANY reason") resident in `020-go-prohibitions.md` and the git-workflow skill task files. This wording is misapplied by agents to mean that a submodule repo (e.g. SHARED-DAO, DailiesDb, ProcessFinishedNotify, DaoCore2) cannot file its own PR for its own changes — a conflation of two distinct concepts: a parent-repo submodule-pointer PR (correctly prohibited) and a submodule repo's own PR for its own changes (completely normal).

### Root Cause / Motivation

The prohibition language does not scope itself to the parent repo. An agent reading "NEVER create a submodule-only PR in ANY context" can reasonably conclude that any PR touching only a submodule is forbidden, including a submodule repo's own PR for its own changes. Because agent-facing text is consumed as routing instructions, this misapplication blocks legitimate per-repo work and creates confusion. The defect must be resolved now because every agent that reads the prohibition inherits the misapplication.

Additionally, the prohibition is resident in the global guideline (`020-go-prohibitions.md`), which is loaded into every agent's context at session start. This violates the progressive disclosure mandate — the rule is only relevant in the parent-repo PR-creation/commit/cleanup execution paths, not in every agent's context. The enforcement already exists in a parent-repo-gated, action-scoped mechanism: the pre-push hook (`hooks/pre-push` Gate 2), which blocks submodule-pointer-only pushes only when the repo has a `.gitmodules` file and the entire branch diff is submodule-pointer-only. The global guideline copy is redundant with that hook and is the source of the misapplication.

### Approach Chosen

Remove the submodule-only-PR prohibition from the global guideline (`020-go-prohibitions.md`) entirely, and remove the global guidance from the root `AGENTS.md` (documented as a cross-repo change out of scope for this `.opencode` repo). Keep enforcement ONLY in the existing pre-push hook (`hooks/pre-push` Gate 2, already parent-repo-gated and action-scoped) and in the contextual skill/task cards that execute the parent-repo PR/commit/cleanup paths. Reword the surviving task-card references to be parent-repo + action-scoped (the prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers; a submodule repo filing its own PR for its own changes is normal and NOT covered). Add a release carve-out to `pr-creation.md` release pre-validation: dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release per AGENTS.md Release discipline and `create-pr.md` Step 6.8; the "no uncommitted submodule changes" check must not block the release path.

### Alternatives Considered & Why Discarded

- **Leave the wording as-is and rely on agent judgment to infer the parent-repo scope.** Discarded: agent-facing text is consumed as routing instructions, not advisory prose. An agent cannot reliably infer scope that the text does not state; the misapplication is a guaranteed defect vector, not a cosmetic ambiguity.
- **Add parent-repo scope qualifiers to the global guideline while keeping the rule resident there.** Discarded: this was the prior approach, but it contradicts the progressive disclosure mandate. The rule is only relevant in the parent-repo PR/commit/cleanup execution paths; keeping it in the global guideline means every agent carries it in context regardless of relevance. The enforcement already exists in the pre-push hook, so the global copy is redundant.
- **Remove the prohibition entirely with no surviving enforcement.** Discarded: the parent-repo submodule-pointer-only PR prohibition is correct and must remain enforced. The pre-push hook Gate 2 already enforces it in a parent-repo-gated, action-scoped way; the task cards retain the contextual guidance.

### Key Design Decisions

- **Full removal of the prohibition from the global guideline (`020-go-prohibitions.md`).** Tradeoff: the rule is no longer resident in every agent's context, satisfying progressive disclosure. Enforcement is preserved by the pre-push hook Gate 2 (parent-repo-gated, action-scoped) and the contextual task cards.
- **Surviving task-card references reworded to be parent-repo + action-scoped.** Tradeoff: the task cards that execute the parent-repo PR/commit/cleanup paths retain the prohibition with explicit scope, so agents in those paths still enforce it, while agents in unrelated contexts no longer inherit it.
- **Explicit permission language for submodule repos' own PRs.** Tradeoff: adding the positive statement removes ambiguity, at the cost of a small amount of additional text in the task cards.
- **Release carve-out in `pr-creation.md` release pre-validation.** Tradeoff: dirty/staged submodule pointers are EXPECTED in a parent-repo release (per AGENTS.md Release discipline and `create-pr.md` Step 6.8); the "no uncommitted submodule changes" check must not block the release path. This prevents the surviving prohibition from blocking legitimate releases.
- **Root `AGENTS.md` global guidance removal documented as cross-repo, out of scope.** Tradeoff: the root `AGENTS.md` lives in the parent repo (michael-conrad/opencode-config), not this `.opencode` submodule; its removal is tracked as a Not Included item for a separate parent-repo change.

### User Intent / Original Prompt

The bug report #2293: the submodule-only PR prohibition was misapplied to submodule repos filing their own PRs. The fix, reached through analysis and user direction, is to REMOVE the prohibition from the global guideline entirely and keep enforcement ONLY in the pre-push hook and the contextual skill/task cards, with parent-repo + action scoping and a release carve-out.

## 2. Not Included

- **Root `AGENTS.md` Submodule Pointer Updates section** — This file lives in the parent repo (michael-conrad/opencode-config), not this `.opencode` submodule. It is a cross-repo change and is out of scope for this `.opencode` repo's implementation (REQ-NON-1). The global guidance there is to be removed in a separate parent-repo change.
- **`hooks/pre-push` Gate 2 submodule-pointer-only push blocker** — Already parent-repo-gated and action-scoped; it is the retained enforcement mechanism and is NOT modified (REQ-NON-2).
- **`hooks/pre-commit` Gate 4 submodule-pointer-only commit blocker** — A separate mechanism, not in issue scope (REQ-NON-3).
- **Any change to submodule repos' own PR workflows** — Beyond removing the misapplied block (REQ-NON-4).
- **Changing the substance of the parent-repo submodule-pointer PR prohibition** — The prohibition substance is preserved in the pre-push hook and the reworded task cards; only its global residence and wording are changed (REQ-CON-1).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The submodule-only-PR prohibition SHALL be removed from the global guideline `020-go-prohibitions.md` (critical-rules-049 block). | behavioral | opencode run — dispatch a real-domain prompt asking whether a submodule repo may file its own PR; clean-room sub-agent inspects session.yaml for agent behavior confirming the global guideline no longer blocks submodule repos' own PRs |
| SC-2 | A submodule repo filing its own PR for its own changes SHALL be unambiguously permitted. | behavioral | opencode run — dispatch a real-domain prompt asking whether SHARED-DAO may file a PR for its own AGENTS.md change; clean-room sub-agent inspects session.yaml for agent behavior confirming permission |
| SC-3 | The surviving task-card references to the prohibition SHALL be parent-repo + action-scoped, stating the prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers. | behavioral | opencode run — dispatch a real-domain prompt in a parent-repo PR-creation context; clean-room sub-agent inspects session.yaml for agent behavior confirming the parent-repo scope is applied |
| SC-4 | The release path SHALL NOT be blocked by the "no uncommitted submodule changes" pre-validation when dirty/staged submodule pointers are expected in a parent-repo release. | behavioral | opencode run — dispatch a real-domain release-PR prompt with dirty/staged submodule pointers; clean-room sub-agent inspects session.yaml for agent behavior confirming the release path proceeds (release carve-out applied) |

## 4. Requirements

- R-1. The critical-rules-049 block SHALL be removed from `020-go-prohibitions.md`.
- R-2. The surviving task-card references SHALL be parent-repo + action-scoped, stating the prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers, and that a submodule repo filing its own PR for its own changes is normal and NOT covered.
- R-3. The surviving task-card references SHALL be reworded in: `git-workflow-commit/tasks/implementation.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-branch/tasks/pre-work.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`.
- R-4. The parent-repo submodule-pointer PR prohibition substance SHALL remain intact in the pre-push hook (`hooks/pre-push` Gate 2) and the reworded task cards; only the global residence and wording are changed.
- R-5. A release carve-out SHALL be added to `pr-creation.md` release pre-validation: dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release; the "no uncommitted submodule changes" check SHALL NOT block the release path.
- R-6. No change SHALL be made to the root `AGENTS.md` Submodule Pointer Updates section in this `.opencode` repo (parent repo, cross-repo change — documented in Not Included).
- R-7. No change SHALL be made to `hooks/pre-push` Gate 2 (retained enforcement mechanism).
- R-8. No change SHALL be made to `hooks/pre-commit` Gate 4 submodule-pointer-only commit blocker.
- R-9. No change SHALL be made to submodule repos' own PR workflows beyond removing the misapplied block.

## 5. Items

### Item 1 (SC-1): Remove the prohibition from the global guideline

- RED: behavioral test asserts the critical-rules-049 block is absent from `020-go-prohibitions.md` — fails on current global wording
- GREEN: remove the critical-rules-049 block from `020-go-prohibitions.md`
- verify: behavioral conformance via opencode run
- commit: `guidelines/020-go-prohibitions.md`

### Item 2 (SC-2): Add explicit permission language for submodule repos' own PRs

- RED: behavioral test asserts a submodule repo filing its own PR is unambiguously permitted — fails on current absence
- GREEN: add explicit language to the surviving task-card references stating a submodule repo filing its own PR for its own changes is normal and NOT covered by the prohibition
- verify: behavioral conformance via opencode run
- commit: `skills/git-workflow-commit/tasks/implementation.md`, `skills/git-workflow-pr/tasks/pr-creation.md`, `skills/git-workflow-branch/tasks/pre-work.md`, `skills/git-workflow-cleanup/SKILL.md`, `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

### Item 3 (SC-3): Reword surviving task-card references to be parent-repo + action-scoped

- RED: behavioral test asserts no agent reading the task cards concludes submodule repos cannot file their own PRs — fails on current misapplication
- GREEN: reword the surviving task-card references to be parent-repo + action-scoped: `git-workflow-commit/tasks/implementation.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-branch/tasks/pre-work.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- verify: behavioral conformance via opencode run
- commit: `skills/git-workflow-commit/tasks/implementation.md`, `skills/git-workflow-pr/tasks/pr-creation.md`, `skills/git-workflow-branch/tasks/pre-work.md`, `skills/git-workflow-cleanup/SKILL.md`, `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

### Item 4 (SC-4): Add release carve-out to pr-creation.md release pre-validation

- RED: behavioral test asserts the release path is NOT blocked by the "no uncommitted submodule changes" check when dirty/staged submodule pointers are expected — fails on current blocking
- GREEN: add the release carve-out to `pr-creation.md` release pre-validation (dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release; the check must not block the release path)
- verify: behavioral conformance via opencode run
- commit: `skills/git-workflow-pr/tasks/pr-creation.md`

## 6. Dependencies

- **Reference: `guidelines/020-go-prohibitions.md`** — Relationship: the critical-rules-049 block is the primary source of the misapplication; it MUST be removed (SC-1) before the task-card rewording (SC-2/3) reads the surviving references.
- **Reference: `hooks/pre-push` Gate 2** — Relationship: the retained enforcement mechanism; parent-repo-gated and action-scoped, NOT modified (REQ-NON-2, REQ-CON-1).
- **Reference: `skills/git-workflow-commit/tasks/implementation.md`** — Relationship: Pre-Commit Submodule Pointer Check (line 39) MUST be reworded to be parent-repo + action-scoped (SC-2/3).
- **Reference: `skills/git-workflow-pr/tasks/pr-creation.md`** — Relationship: Pre-Push Submodule Pointer Verification (line 54) MUST be reworded to be parent-repo + action-scoped (SC-2/3); release pre-validation (line 32) MUST receive the release carve-out (SC-4).
- **Reference: `skills/git-workflow-branch/tasks/pre-work.md`** — Relationship: No-Op Branch Guard (line 251) MUST be reworded to be parent-repo + action-scoped (SC-2/3).
- **Reference: `skills/git-workflow-cleanup/SKILL.md`** — Relationship: critical-rules-049 reference (lines 51, 87-91) MUST be reworded to be parent-repo + action-scoped (SC-2/3).
- **Reference: `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`** — Relationship: Dirty submodule pointer exemption (lines 172, 319) MUST be reworded to be parent-repo + action-scoped (SC-2/3).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | PHASE-1 |
| R-2 | SC-2, SC-3 | PHASE-2 |
| R-3 | SC-2, SC-3 | PHASE-2 |
| R-4 | SC-1, SC-2, SC-3 | PHASE-1, PHASE-2 |
| R-5 | SC-4 | PHASE-3 |
| R-6 | SC-1 | PHASE-1 |
| R-7 | SC-1, SC-2, SC-3 | PHASE-1, PHASE-2 |
| R-8 | SC-1 | PHASE-1 |
| R-9 | SC-2 | PHASE-2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `guidelines/020-go-prohibitions.md` | code | `.opencode/guidelines/` | read (live, current file) — critical-rules-049 block (lines 229-236) with global "in ANY context" wording |
| `hooks/pre-push` Gate 2 | code | `.opencode/hooks/` | read (live, current file) — submodule-pointer-only push blocker (lines 93-130), parent-repo-gated (`.gitmodules` check) and action-scoped (diffs against trunk tip) |
| `skills/git-workflow-commit/tasks/implementation.md` | code | `.opencode/skills/git-workflow-commit/tasks/` | read (live, current file) — Pre-Commit Submodule Pointer Check (line 39) |
| `skills/git-workflow-pr/tasks/pr-creation.md` | code | `.opencode/skills/git-workflow-pr/tasks/` | read (live, current file) — Pre-Push Submodule Pointer Verification (line 54), release pre-validation (line 32) |
| `skills/git-workflow-branch/tasks/pre-work.md` | code | `.opencode/skills/git-workflow-branch/tasks/` | read (live, current file) — No-Op Branch Guard (line 251) |
| `skills/git-workflow-cleanup/SKILL.md` | code | `.opencode/skills/git-workflow-cleanup/` | read (live, current file) — critical-rules-049 reference (lines 51, 87-91) |
| `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | code | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/` | read (live, current file) — Dirty submodule pointer exemption (lines 172, 319) |
| `skills/git-workflow-pr/tasks/pr-creation/create-pr.md` | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/` | read (live, current file) — Step 6.8 Submodule SHA Verification (--release Mode) (lines 232-238) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Removing the prohibition from the global guideline costs one behavioral test run. Skipping leaves the global wording resident in every agent's context, so agents continue to block submodule repos' own PRs and legitimate per-repo work stalls.
- **SC-2:** Adding explicit permission language for submodule repos' own PRs costs one behavioral test run. Skipping leaves the permission ambiguous, so agents still cannot reliably conclude a submodule repo may file its own PR.
- **SC-3:** Rewording the surviving task-card references to be parent-repo + action-scoped costs one behavioral test run. Skipping leaves task-file sub-agents blocking submodule repos' own PRs during commit/PR/cleanup, so the misapplication persists in the execution paths.
- **SC-4:** Adding the release carve-out costs one behavioral test run. Skipping leaves the release path blocked by the "no uncommitted submodule changes" check when dirty/staged submodule pointers are expected, so legitimate parent-repo releases stall.

## 11. Edge Cases

- **Input boundaries (SC-1/2/3):** The surviving task-card references SHALL handle both directions: a submodule repo filing its own PR (permitted) and a parent-repo submodule-pointer-only PR (still blocked). Resolution: the behavioral tests assert both behaviors to prevent over-correction.
- **State transitions (SC-1/2/3):** The prohibition SHALL transition from a global guideline resident in every agent's context to a parent-repo + action-scoped rule in the pre-push hook and contextual task cards. Resolution: the global block is removed; the surviving references are reworded; the pre-push hook is unchanged.
- **Failure modes (SC-3):** If a task file still blocks submodule repos' own PRs after the rewording, the SC FAILs and the missing scope qualifier is added. Resolution: grep-based verification catches residual references.
- **Release path (SC-4):** If the release pre-validation still blocks on dirty/staged submodule pointers, the release path stalls. Resolution: the release carve-out exempts the release path from the "no uncommitted submodule changes" check, consistent with AGENTS.md Release discipline and `create-pr.md` Step 6.8.
- **Concurrency (SC-1/2/3/4):** Multiple files are edited (guideline removal + 5 task files + release pre-validation). Resolution: items execute sequentially in the dependency DAG (SC-1 guideline removal, then SC-2/3 task-card rewording, then SC-4 release carve-out) to avoid conflicting edits.
- **Recovery (SC-3):** If a task file is missed in the rewording, the behavioral test catches the residual misapplication and the scope qualifier is added. Resolution: the audit covers all files referencing submodule-only PRs.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-17 | Initial spec creation from bug report #2293. | Bug report #2293: submodule-only PR prohibition misapplied to submodule repos filing their own PRs. | Spec creation pipeline |
| 2026-08-17 | Revised Approach Chosen, Alternatives, Key Design Decisions, Success Criteria, Requirements, Items, Traceability, and Not Included. | Revision reason: the prior approach (add parent-repo scope qualifiers to the global guideline while keeping the rule resident) contradicts the established intent and user direction. The directive is to REMOVE the prohibition from the global guideline entirely, keep enforcement ONLY in the pre-push hook and contextual skill/task cards, reword surviving task-card references to be parent-repo + action-scoped, and add a release carve-out to pr-creation.md release pre-validation. Root AGENTS.md global guidance removal documented as a cross-repo change in Not Included. | Spec revision pipeline |
