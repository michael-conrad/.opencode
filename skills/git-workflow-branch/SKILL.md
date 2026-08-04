---
name: git-workflow-branch
description: "Create and manage feature branches, sync submodules, verify provenance, set up pair mode branches, and resume pair mode sessions. Branch creation is REQUIRED before any file modification and requires `for_implementation` or above authorization scope."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-branch

## Overview

Branch management sub-skill of git-workflow. Handles feature branch creation, submodule synchronization, provenance verification, pair mode setup and resume, pre-commit pointer checks, and operating protocol enforcement.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Set up a feature branch

When the agent needs to create a feature branch before any implementation work, syncing submodules and verifying trunk tip first.

1. **Verify trunk tip** — Verifies that parent repo and submodules are at trunk tip with clean working trees.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/trunk-tip-verification.md](.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md). branch_name: {branch_name}"`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Sync submodules** — Syncs dirty submodule pointers to latest trunk tip.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/submodule-sync.md](.opencode/skills/git-workflow-branch/tasks/submodule-sync.md). branch_name: {branch_name}, submodule_paths: {submodule_paths}"`
   - Context: `{branch_name, submodule_paths}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

3. **Pre-work** — Creates the feature branch and sets up the working environment.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/pre-work.md](.opencode/skills/git-workflow-branch/tasks/pre-work.md). branch_name: {branch_name}, worktree.path: {worktree.path}"`
   - Context: `{branch_name, worktree.path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Set up a pair mode branch

When the agent needs to set up a pair mode branch or resume a pair mode session.

1. **Pair pre-work** — Sets up a pair mode branch and workspace.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/pair-pre-work.md](.opencode/skills/git-workflow-branch/tasks/pair-pre-work.md). branch_name: {branch_name}"`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Pair mode resume** — Resumes a pair mode session from saved state.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/pair-mode-resume.md](.opencode/skills/git-workflow-branch/tasks/pair-mode-resume.md). branch_name: {branch_name}"`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage submodule pointers before commit

When the agent needs to verify submodule pointers are staged alongside non-submodule changes before committing.

1. **Pre-commit pointer check** — Verifies submodule pointers are staged before commit.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/pre-commit-pointer-check.md](.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md). branch_name: {branch_name}"`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Verify provenance

When the agent needs to create provenance tracking issues and PRs in submodule repositories after push operations.

1. **Provenance** — Verifies provenance of submodule state.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/provenance.md](.opencode/skills/git-workflow-branch/tasks/provenance.md). submodule_path: {submodule_path}"`
   - Context: `{submodule_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Enforce operating protocol

When the agent needs to enforce the git operating protocol and tag conventions.

1. **Operating protocol** — Enforces operating protocol and tag conventions.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-branch/tasks/operating-protocol.md](.opencode/skills/git-workflow-branch/tasks/operating-protocol.md). branch_name: {branch_name}"`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

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
