---
name: completion-core
description: "Use when completing skill task workflows with push, URL generation, comment posting, and executive summary reporting. Triggers on: completion, finish, halt, done, branch ready, push changes. A halt without output leaves the developer waiting. Clear completion signals are professional courtesy."
license: MIT
compatibility: opencode
---

# Completion Core — Shared Completion Operations

Reference this file from per-skill `tasks/completion.md` files for common completion operations.

## Entry Gate

**Entry gate: verification-before-completion PASS required before any completion operation.**

Verification IS completion — the concept is fused. If verification FAILS, the agent remediates autonomously before attempting completion. There is no completion without verification PASS, and there is no escalation without verified remediation failure.

## Common Completion Operations

### 1. Push Branch (Idempotent)

Check whether the branch has unpushed commits before pushing:

```bash
UNPUSHED=$(git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null)
if [ -n "$UNPUSHED" ]; then
    git push -u origin $(git branch --show-current)
else
    echo "Branch already up to date with remote. No push needed."
fi
```

If no remote tracking branch exists yet, `git push -u origin <branch>` creates it.

### 2. Generate URL

Two URL patterns depending on workflow type:

**Compare URL** (for git push workflows — implementation, git-workflow, finishing):

Construct from session-init values with character-match verification:

1. Read `<github.owner>`, `<github.repo>`, `<gitbucket.html_url>` from session init
2. Construct: `${GITBUCKET_HTML_URL:-https://github.com/}${GIT_OWNER}/${GIT_REPO}/compare/dev...$(git branch --show-current)`
3. **Character-match verification:** Confirm `GIT_OWNER` and `GIT_REPO` in the constructed URL match session-init values exactly (character-for-character, no typos, no cached values)
4. If any mismatch: HALT and report

```bash
COMPARE_URL="${GITBUCKET_HTML_URL:-https://github.com/}${GIT_OWNER}/${GIT_REPO}/compare/dev...$(git branch --show-current)"
```

**Action URL** (for creation workflows — issue creation, approval gate):

- **Issue URL:** Extract from `github_issue_write` API response `html_url` field — NEVER construct from template <!-- Routes through issue-operations per SPEC #683 -->
- **PR URL:** Extract from `github_create_pull_request` API response `html_url` field — NEVER construct from template

### 3. Post Status Comment (Substantive Only)

Before posting, evaluate whether the comment is substantive per the `issue-operations` `comment` task Substantive Comment Gate:

```python
# ONLY post if the comment conveys stakeholder-meaningful information
if is_substantive:
    issue-operations -> comment (github_add_issue_comment(owner=<github.owner>, repo=<github.repo>, issue_number=N, body="...") <!-- Routes through issue-operations per SPEC #683 -->
else:
    # Skip posting — progress goes to chat only
    pass
```

### 4. Report Executive Summary in Chat (Always Runs)

Chat output is idempotent by nature. Always produce:

```
**Summary:**

<1-2 sentences describing the impact and stakeholder value.>

**Outcome:** <What changed for stakeholders>

<URL if applicable, ALWAYS LAST>
```

**URL is ALWAYS last** per `000-critical-rules.md`.

## Idempotency Summary

| Operation | Idempotency Mechanism | Applies To |
| -- | -- | -- |
| Push branch | Check `git log origin/..HEAD` before pushing | Git workflows only |
| Generate URL | Check if URL already generated; compare URL for pushes, action URL for creation workflows | All workflows |
| Post status comment | Substantiveness gate (per `issue-operations` skill `comment` task) | Workflows with issue context |
| Report executive summary + URL | Always run; idempotent by nature | All workflows |

## Sub-Agent Routing

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.