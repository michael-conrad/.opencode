> **Full spec and artifacts: [`.opencode/.issues/2293/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2293/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2293/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

The "Submodule-only PR prohibition" (critical-rules-049) is worded as a global prohibition ("NEVER create a submodule-only PR in ANY context, for ANY reason") across `020-go-prohibitions.md` and the git-workflow skill task files. This wording is misapplied by agents to mean that a submodule repo (e.g. SHARED-DAO, DailiesDb, ProcessFinishedNotify, DaoCore2) cannot file its own PR for its own changes — a conflation of two distinct concepts: a parent-repo submodule-pointer PR (correctly prohibited) and a submodule repo's own PR for its own changes (completely normal).

### Root Cause / Motivation

The prohibition language does not scope itself to the parent repo. An agent reading "NEVER create a submodule-only PR in ANY context" can reasonably conclude that any PR touching only a submodule is forbidden, including a submodule repo's own PR for its own changes. Because agent-facing text is consumed as routing instructions, this misapplication blocks legitimate per-repo work and creates confusion. The defect must be resolved now because every agent that reads the prohibition inherits the misapplication.

### Approach Chosen

Add explicit parent-repo scope qualifiers to the critical-rules-049 block in `020-go-prohibitions.md` and to every git-workflow task file that references the prohibition, while preserving the parent-repo prohibition substance intact. Explicitly state that a submodule repo filing its own PR for its own changes is normal and NOT covered by the prohibition.

### Alternatives Considered & Why Discarded

- **Leave the wording as-is and rely on agent judgment to infer the parent-repo scope.** Discarded: agent-facing text is consumed as routing instructions, not advisory prose. An agent cannot reliably infer scope that the text does not state; the misapplication is a guaranteed defect vector, not a cosmetic ambiguity.
- **Remove the prohibition entirely.** Discarded: the parent-repo submodule-pointer-only PR prohibition is correct and must remain enforced. Only the scope qualifiers are added.

### Key Design Decisions

- **Parent-repo scope qualifier added to the critical-rules-049 block.** Tradeoff: the prohibition text becomes longer and more explicit, but agents can no longer misread it as a global ban.
- **Explicit permission language for submodule repos' own PRs.** Tradeoff: adding the positive statement removes ambiguity, at the cost of a small amount of additional text.
- **Consistent "parent-repo" qualifier across all files.** Tradeoff: consistent wording avoids introducing a new misapplication vector, at the cost of editing every referencing file.

### User Intent / Original Prompt

The bug report #2293: the submodule-only PR prohibition was misapplied to submodule repos filing their own PRs. The fix is to scope the prohibition to the parent repo and explicitly permit submodule repos' own PRs.

## 2. Not Included

- **Root `AGENTS.md` Submodule Pointer Updates section** — This file lives in the parent repo (michael-conrad/opencode-config), not this `.opencode` submodule. It is a cross-repo change and is out of scope for this `.opencode` repo's implementation (REQ-NON-1).
- **`hooks/pre-commit` Gate 4 submodule-pointer-only commit blocker** — A separate mechanism, not in issue scope (REQ-NON-2).
- **Changing the substance of the parent-repo submodule-pointer PR prohibition** — Only scope qualifiers are added; the prohibition substance is preserved (REQ-CON-1).
- **Any change to submodule repos' own PR workflows** — Beyond removing the misapplied block (REQ-NON-3).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The prohibition language in `020-go-prohibitions.md` (critical-rules-049 block) SHALL be explicitly scoped to the parent repo. | behavioral | opencode run — dispatch a real-domain prompt asking whether a submodule repo may file its own PR; clean-room sub-agent inspects session.yaml for agent behavior confirming the parent-repo scope is applied |
| SC-2 | A submodule repo filing its own PR for its own changes SHALL be unambiguously permitted. | behavioral | opencode run — dispatch a real-domain prompt asking whether SHARED-DAO may file a PR for its own AGENTS.md change; clean-room sub-agent inspects session.yaml for agent behavior confirming permission |
| SC-3 | No agent reading the guidelines SHALL be able to reasonably conclude that submodule repos cannot file their own PRs. | behavioral | opencode run — dispatch a real-domain prompt asking whether a submodule repo can file its own PR; clean-room sub-agent inspects session.yaml for absence of the misapplied block |

## 4. Requirements

- R-1. The critical-rules-049 block in `020-go-prohibitions.md` SHALL be scoped to the parent repo, stating the prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers.
- R-2. `020-go-prohibitions.md` SHALL explicitly state that a submodule repo filing its own PR for its own changes is normal and NOT covered by the prohibition.
- R-3. Every git-workflow task file referencing the submodule-only PR prohibition SHALL carry the parent-repo scope qualifier: `git-workflow-commit/tasks/implementation.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-branch/tasks/pre-work.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`.
- R-4. The parent-repo submodule-pointer PR prohibition substance SHALL remain intact in every file; only scope qualifiers are added.
- R-5. The "parent-repo" scope qualifier SHALL be worded consistently across all files to avoid introducing new ambiguity.
- R-6. No change SHALL be made to the root `AGENTS.md` Submodule Pointer Updates section (parent repo, cross-repo change).
- R-7. No change SHALL be made to `hooks/pre-commit` Gate 4 submodule-pointer-only commit blocker.
- R-8. No change SHALL be made to submodule repos' own PR workflows beyond removing the misapplied block.

## 5. Items

### Item 1 (SC-1): Scope the critical-rules-049 block to the parent repo

- RED: behavioral test asserts the critical-rules-049 block in `020-go-prohibitions.md` is scoped to the parent repo — fails on current global wording
- GREEN: add the parent-repo scope qualifier to the critical-rules-049 block in `020-go-prohibitions.md`
- verify: behavioral conformance via opencode run
- commit: `guidelines/020-go-prohibitions.md`

### Item 2 (SC-2): Add explicit permission language for submodule repos' own PRs

- RED: behavioral test asserts a submodule repo filing its own PR is unambiguously permitted — fails on current absence
- GREEN: add explicit language to `020-go-prohibitions.md` stating a submodule repo filing its own PR for its own changes is normal and NOT covered by the prohibition
- verify: behavioral conformance via opencode run
- commit: `guidelines/020-go-prohibitions.md`

### Item 3 (SC-3): Audit and add parent-repo scope qualifier to all task files

- RED: behavioral test asserts no agent reading the guidelines concludes submodule repos cannot file their own PRs — fails on current misapplication
- GREEN: audit and add the parent-repo scope qualifier to all task files referencing submodule-only PRs: `git-workflow-commit/tasks/implementation.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-branch/tasks/pre-work.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- verify: behavioral conformance via opencode run
- commit: `skills/git-workflow-commit/tasks/implementation.md`, `skills/git-workflow-pr/tasks/pr-creation.md`, `skills/git-workflow-branch/tasks/pre-work.md`, `skills/git-workflow-cleanup/SKILL.md`, `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

## 6. Dependencies

- **Reference: `guidelines/020-go-prohibitions.md`** — Relationship: the critical-rules-049 block is the primary source of the misapplication; it MUST be scoped to the parent repo (SC-1/2) before the task-file audit (SC-3) reads it.
- **Reference: `skills/git-workflow-commit/tasks/implementation.md`** — Relationship: Pre-Commit Submodule Pointer Check (line 39) MUST carry the parent-repo scope qualifier (SC-3).
- **Reference: `skills/git-workflow-pr/tasks/pr-creation.md`** — Relationship: Pre-Push Submodule Pointer Verification (line 54) MUST carry the parent-repo scope qualifier (SC-3).
- **Reference: `skills/git-workflow-branch/tasks/pre-work.md`** — Relationship: No-Op Branch Guard (line 251) MUST carry the parent-repo scope qualifier (SC-3).
- **Reference: `skills/git-workflow-cleanup/SKILL.md`** — Relationship: critical-rules-049 reference (lines 51, 87-91) MUST carry the parent-repo scope qualifier (SC-3).
- **Reference: `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`** — Relationship: Dirty submodule pointer exemption (lines 172, 319) MUST carry the parent-repo scope qualifier (SC-3).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | PHASE-1 |
| R-2 | SC-2 | PHASE-1 |
| R-3 | SC-3 | PHASE-2 |
| R-4 | SC-1, SC-2, SC-3 | PHASE-1, PHASE-2 |
| R-5 | SC-1, SC-2, SC-3 | PHASE-1, PHASE-2 |
| R-6 | SC-1, SC-2, SC-3 | PHASE-1, PHASE-2 |
| R-7 | SC-1, SC-2, SC-3 | PHASE-1, PHASE-2 |
| R-8 | SC-2 | PHASE-1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `guidelines/020-go-prohibitions.md` | code | `.opencode/guidelines/` | read (live, current file) — critical-rules-049 block (lines 229-236) with global "in ANY context" wording |
| `skills/git-workflow-commit/tasks/implementation.md` | code | `.opencode/skills/git-workflow-commit/tasks/` | read (live, current file) — Pre-Commit Submodule Pointer Check (line 39) |
| `skills/git-workflow-pr/tasks/pr-creation.md` | code | `.opencode/skills/git-workflow-pr/tasks/` | read (live, current file) — Pre-Push Submodule Pointer Verification (line 54) |
| `skills/git-workflow-branch/tasks/pre-work.md` | code | `.opencode/skills/git-workflow-branch/tasks/` | read (live, current file) — No-Op Branch Guard (line 251) |
| `skills/git-workflow-cleanup/SKILL.md` | code | `.opencode/skills/git-workflow-cleanup/` | read (live, current file) — critical-rules-049 reference (lines 51, 87-91) |
| `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | code | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/` | read (live, current file) — Dirty submodule pointer exemption (lines 172, 319) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Scoping the critical-rules-049 block to the parent repo costs one behavioral test run. Skipping leaves the global wording in place, so agents continue to block submodule repos' own PRs and legitimate per-repo work stalls.
- **SC-2:** Adding explicit permission language for submodule repos' own PRs costs one behavioral test run. Skipping leaves the permission ambiguous, so agents still cannot reliably conclude a submodule repo may file its own PR.
- **SC-3:** Auditing and adding the parent-repo scope qualifier to all task files costs one behavioral test run. Skipping leaves task-file sub-agents blocking submodule repos' own PRs during commit/PR/cleanup, so the misapplication persists in the execution paths.

## 11. Edge Cases

- **Input boundaries (SC-1/2/3):** The scope qualifier SHALL handle both directions: a submodule repo filing its own PR (permitted) and a parent-repo submodule-pointer-only PR (still blocked). Resolution: the behavioral tests assert both behaviors to prevent over-correction.
- **State transitions (SC-1/2):** The critical-rules-049 block SHALL transition from a global prohibition to a parent-repo-scoped prohibition. Resolution: the scope qualifier is added to the block; the parent-repo prohibition substance is unchanged.
- **Failure modes (SC-3):** If a task file still blocks submodule repos' own PRs after the audit, the SC FAILs and the missing scope qualifier is added. Resolution: grep-based verification catches residual references.
- **Concurrency (SC-1/2/3):** Multiple files are edited (guideline + 5 task files). Resolution: items execute sequentially in the dependency DAG (SC-1/2 guideline scoping, then SC-3 task-file audit) to avoid conflicting edits.
- **Recovery (SC-3):** If a task file is missed in the audit, the behavioral test catches the residual misapplication and the scope qualifier is added. Resolution: the audit covers all files referencing submodule-only PRs.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-17 | Initial spec creation from bug report #2293. | Bug report #2293: submodule-only PR prohibition misapplied to submodule repos filing their own PRs. | Spec creation pipeline |
