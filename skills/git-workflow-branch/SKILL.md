---
name: git-workflow-branch
description: "Dispatch when the agent needs to create or manage feature branches, sync submodules, or verify provenance. Also dispatch when the agent needs to set up pair mode branches or resume pair mode sessions. Triggers when: agent determines a branch operation is needed, agent needs to sync submodules, agent needs to verify provenance, agent needs to set up pair mode."
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

1. Sub-agent MUST return `PRELOADED_CONTEXT_REJECTED` if the task() prompt contains preloaded file paths, step definitions, expected outcomes, or orchestrator reasoning
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
| `operating-protocol` | Enforce operating protocol and tag conventions |

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [approval-gate skill](skills/approval-gate/SKILL.md) for authorization scope requirements
- Read [critical-rules-005](guidelines/000-critical-rules.md) for branch creation rules
- Read [critical-rules-051](guidelines/000-critical-rules.md) for submodule tagging requirements
- Read [§1](guidelines/020-go-prohibitions.md) for `for_analysis` branch restrictions
