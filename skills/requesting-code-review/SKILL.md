---
name: requesting-code-review
description: Use when preparing a PR for code review, or when reviewer context and documentation are needed. Triggers on: request review, code review, review request, ready for review, review preparation.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: requesting-code-review

## Overview

Workflow for preparing and requesting code reviews. Ensures PR descriptions have proper context, reviewers can understand changes quickly, and review requests are targeted and informative. Adapted from the <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow.

**Source Attribution:** This skill is adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `prepare` | Prepare PR for review | ≈400 |
| `request` | Submit review request | ≈250 |

## Invocation

- `/skill requesting-code-review` — Overview only
- `/skill requesting-code-review --task prepare` — Prepare PR for review
- `/skill requesting-code-review --task request` — Submit review request

## Operating Protocol

1. **Contextual invocation:** This skill is invoked when user says "request review" or "ready for review", or PR is created and ready for review. NOT automatic — requires user instruction.
2. **Review preparation:** PR must have clear description, all checks passing, well-documented changes, and identified reviewers before requesting review.
3. **Exit conditions:** Review request is COMPLETE when PR description is comprehensive, review request submitted, and agent HALTs to wait for review.
4. **Scoping:** Address ONLY what reviewers request. No "while I'm here" changes during review response.

## Anti-Patterns

### 🚫 Poor Review Request

"Please review this PR" — no context on what changed, why, or how to test.

### ✅ Good Review Request

Includes type, scope, complexity, key changes, testing commands, and specific questions for reviewers.

## Integration with Existing Workflow

### Dispatch Order

```
finishing-a-development-branch → PR created by user → requesting-code-review (prepare) → (reviewer reviews)
```

### PR Creation Timing

- This skill is invoked AFTER PR creation
- PR creation requires explicit "create a PR" instruction
- This skill does NOT create PRs — only prepares them for review

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `issue-operations` (implied by review request PR comments) | File exists at `.opencode/skills/issue-operations/SKILL.md` | MISSING-TRACEABILITY if missing |
| `receiving-code-review` in Cross-References section | File exists at `.opencode/skills/receiving-code-review/SKILL.md` | MISSING-TRACEABILITY if missing |
| `git-workflow` in Cross-References section | File exists at `.opencode/skills/git-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `pr-creation-workflow` in Cross-References section | File exists at `.opencode/skills/pr-creation-workflow/SKILL.md` | MISSING-TRACEABILITY if missing |
| `finishing-a-development-branch` in Dispatch Order | File exists at `.opencode/skills/finishing-a-development-branch/SKILL.md` | MISSING-TRACEABILITY if missing |
| Task table entry `prepare` | File exists at `.opencode/skills/requesting-code-review/tasks/prepare.md` | MISSING-TRACEABILITY if missing |
| Task table entry `request` | File exists at `.opencode/skills/requesting-code-review/tasks/request.md` | MISSING-TRACEABILITY if missing |
| `receiving-code-review` behavior | Matches actual SKILL.md: `address` and `respond` tasks for review feedback | CONFLICTING if mismatched |
| `git-workflow` PR creation behavior | Matches actual SKILL.md: `pr-creation` task | CONFLICTING if mismatched |

**Verification Procedure:**

Before invoking any cross-referenced skill:
1. `ls .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: file exists or MISSING-TRACEABILITY
2. `grep -c "<task-name>" .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: task referenced or MISSING-TRACEABILITY
3. Compare described behavior with actual content → EVIDENCE: match or CONFLICTING

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Referenced skill file missing | MISSING-TRACEABILITY | flag-for-review | Cannot verify cross-reference |
| Referenced task file missing | MISSING-TRACEABILITY | flag-for-review | Task may have been renamed |
| Described behavior mismatches | CONFLICTING | flag-for-review | Cross-reference may be stale |
| Invocation mismatch | CONFLICTING | flag-for-review | Skill may have been updated |

## Cross-References

- Related skills: `receiving-code-review` (responding to review), `git-workflow` (PR creation), `pr-creation-workflow` (PR timing), `issue-operations` (PR comment format via `comment` task)
- Related guidelines: `080-code-standards.md` (AI attribution), `060-tool-usage.md` (commands)

## Platform Compatibility

- **GitHub:** Not applicable (this repository uses GitBucket)
- **GitBucket:** Use Python client from gitbucket-api skill
- **Platform Detection:** Uses `github.platform` environment variable

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-26T00:00:00Z"
rules: []
tasks:
  - id: prepare
    skill: requesting-code-review
    preconditions: ["pr_created == true"]
    postconditions: ["pr_ready_for_review == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Code Review Preparation"
    source: "requesting-code-review/SKILL.md"
  - id: request
    skill: requesting-code-review
    preconditions: ["pr_ready_for_review == true"]
    postconditions: ["review_request_submitted == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Review Request"
    source: "requesting-code-review/SKILL.md"
  - id: completion
    skill: requesting-code-review
    preconditions: ["any_state"]
    postconditions: ["completion_tasks_executed == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Completion Guarantee on Workflow Halt"
    source: "requesting-code-review/SKILL.md"
decomposition:
  - type: sub-agent-dispatch
    isolation: clean-room
    must_receive: [diff, PR metadata]
    must_not_receive: [implementation intent, agent memory from prior phases, cached verification results]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Clean-Room Dispatch for Sub-Agents"
gates:
  - id: pr-must-exist
    condition: "pr_created == true"
    on_fail: "HALT"
    critical_violation: true
evidence_artifacts:
  - name: pr_description
    type: tool_call
    verification: "PR description has Summary/Outcome/Fixes format"
  - name: review_request
    type: api_call
    verification: "Review request submitted via GitHub API"
```