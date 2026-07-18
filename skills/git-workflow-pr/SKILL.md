---
name: git-workflow-pr
description: "Pull request creation, review preparation, and PR lifecycle management. Load via skill() when the agent needs to create pull requests, prepare reviews, or handle PR lifecycle completion. Also load when handling pair mode PR creation or post-implementation tasks. Every PR MUST be an authorized, intentional delivery. User phrases: create PR, prepare review, complete PR lifecycle, pair mode PR"
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-pr

## Overview

Pull request management sub-skill of git-workflow. Handles PR creation, review preparation, pair mode PR creation, post-implementation tasks, and PR lifecycle completion. Enforces stacked PR strategy — one branch, N commits, one PR. PR creation requires `for_pr` authorization scope or explicit developer instruction.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pr-creation" / "create PR" | `pr-creation` | `sub-task` | {branch_name, spec_summary, is_release} |
| "review-prep" / "prepare review" | `review-prep` | `sub-task` | {branch_name} |
| "pair-pr-creation" / "pair PR" | `pair-pr-creation` | `sub-task` | {branch_name} |
| "post-implementation" / "post-impl" | `post-implementation` | `sub-task` | {branch_name} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

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
| `pr-creation` | Create pull request with structured body and compare URL |
| `review-prep` | Prepare branch for review — verify readiness, generate context |
| `pair-pr-creation` | Create PR from pair mode branch |
| `post-implementation` | Post-implementation tasks — verification, finishing checklist |
| `completion` | PR lifecycle completion — final status, URL reporting |

## Cross-References

- Load [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Load [pr-creation-workflow skill](skills/pr-creation-workflow/SKILL.md) for PR authorization and readiness verification
- Load [critical-rules-016](guidelines/000-critical-rules.md) for PR body format requirements
- Load [critical-rules-016](guidelines/000-critical-rules.md) for compare URL base branch rules
- Load [critical-rules-019](guidelines/000-critical-rules.md) for PR creation authorization
- Load [critical-rules-PR-ORG](guidelines/000-critical-rules.md) for stacked PR strategy
- Load [critical-rules-040](guidelines/000-critical-rules.md) for single-commit PR discipline
