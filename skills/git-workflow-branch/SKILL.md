---
name: git-workflow-branch
description: "Feature branch creation and management, submodule sync, and provenance verification. Load via skill() when the agent needs to create or manage feature branches, sync submodules, or verify provenance. Also load when setting up pair mode branches or resuming pair mode sessions. Branch creation is REQUIRED before any file modification. User phrases: create branch, manage branch, sync submodules, verify provenance, pair mode"
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-branch

## Overview

Branch management sub-skill of git-workflow. Handles feature branch creation, submodule synchronization, provenance verification, pair mode setup and resume, pre-commit pointer checks, and operating protocol enforcement. All branch operations require `for_implementation` or above authorization scope.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-work" / "setup branch" / "sync default branch" | `pre-work` | `sub-task` | {branch_name, worktree.path} |
| "pair-pre-work" / "setup pair branch" | `pair-pre-work` | `sub-task` | {branch_name} |
| "pair-mode-resume" / "resume pair session" | `pair-mode-resume` | `sub-task` | {branch_name} |
| "sync submodules" / "update submodules" | `submodule-sync` | `sub-task` | {submodule_paths} |
| "pre-commit-pointer-check" / "check submodule pointers" | `pre-commit-pointer-check` | `sub-task` | {branch_name} |
| "provenance" / "provenance check" | `provenance` | `sub-task` | {submodule_path} |
| "trunk-tip-verification" / "verify trunk tip" / "check trunk" | `trunk-tip-verification` | `sub-task` | {branch_name} |
| "operating-protocol" / "protocol" | `operating-protocol` | `sub-task` | {branch_name} |

## DISPATCH_GATE

### Orchestrator Entry Criteria

1. Confirm the next action is `task()` — not inline execution
2. Use the canonical dispatch string from the Trigger Dispatch Table verbatim
3. Do NOT preload file paths, step sequences, expected outcomes, or orchestrator reasoning
4. Task a clean-room sub-agent via `task(subagent_type="general")`
5. Receive result contract (status, finding_summary, artifact_path, blocker_reason)
6. Log in work state file — record which sub-agent was tasked and when
7. Proceed based on result contract — route to next pipeline step

### Sub-Agent Entry Criteria

2. Sub-agent loads task file content independently — never from orchestrator context
3. Sub-agent reads source files, runs analysis tools, executes tests freely
4. Sub-agent returns only routing-significant data: status, finding_summary, artifact_path, blocker_reason
5. Full evidence artifacts go to disk — never in the result contract

## Tasks

| Task | Description |
|------|-------------|
| `pre-work` | Create feature branch, verify git state, set up submodules |
| `pair-pre-work` | Set up pair mode branch and workspace |
| `pair-mode-resume` | Resume pair mode session from saved state |
| `submodule-sync` | Sync submodules to upstream default branch |
| `pre-commit-pointer-check` | Verify submodule pointers before commit |
| `provenance` | Verify provenance of submodule state |
| `trunk-tip-verification` | Verify parent repo and submodules are at trunk tip with clean working trees |
| `operating-protocol` | Enforce operating protocol and tag conventions |

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [approval-gate skill](skills/approval-gate/SKILL.md) for authorization scope requirements
- Read [critical-rules-005](guidelines/000-critical-rules.md) for branch creation rules
- Read [critical-rules-051](guidelines/000-critical-rules.md) for submodule tagging requirements
- Read [trunk-tip-verification task](tasks/trunk-tip-verification.md) for the 7-step trunk tip verification gate
- Read [submodule-divergence reference](reference/submodule-divergence.md) for submodule divergence detection and resolution
- Read [§1](guidelines/020-go-prohibitions.md) for `for_analysis` branch restrictions

### [critical-rules-042] Treating Branch Stacking as Optional
Skipping branch stacking means merging chaos into your commit history. Professional engineers stack branches as prerequisite — amateurs treat stacking as optional and produce unreviewable history.


### [critical-rules-051] Skipping mandatory submodule tagging at pre-work
Skipping submodule tagging means the starting SHA becomes unreachable after squash merge and branch deletion — the work still exists but nobody can find it. Professional engineers tag every submodule at pre-work. Amateurs lose history that their future selves need.


### [critical-rules-005] Direct-Branch Default — feature branch without worktree is the norm
Default: `git checkout -b feature/X` in main repo. Worktree opt-in when `WORKTREE_REQUIRED` set. Read [git-workflow --task pre-work](skills/git-workflow/SKILL.md).


### [critical-rules-005] Skipping Git Pre-Check — working without feature branch
Must verify git state and create feature branch before any file modification. Creating `feature/*` or `spec/*` branches additionally requires `for_implementation` or above authorization scope.

#### 🚫 FORBIDDEN

- Working without a feature branch
- Creating `feature/*` or `spec/*` branches without `for_implementation` or above authorization scope

#### ✅ REQUIRED

- Verify git state before any file modification
- Create feature branch before starting work
- Ensure `for_implementation` or above scope before creating `feature/*` or `spec/*` branches

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Working without feature branch | Changes land directly on trunk branches, breaking branch discipline |
| Creating branches without authorization | Feature/spec branches created without proper scope approval |


