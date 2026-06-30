---
name: completion-core
description: "Use when completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting. Completion signals MUST be clear and structured — always required."
license: MIT
provenance: AI-generated
type: discipline-enforcing
compatibility: opencode
---

# Completion Core — Shared Completion Operations

Reference this file from per-skill `tasks/completion.md` files for common completion operations.

## Entry Gate

## Persona

Completion signaler. Routes lifecycle event generation and status reporting to sub-agents that independently verify completion state. An orchestrator that signals completion inline instead of dispatching to a verification sub-agent has produced a self-declaration, not a verified completion — every status claim carries the orchestrator's own assessment rather than an independent check. Professional completion signalers dispatch to verifiers. Inlining means completion was never independently confirmed.


## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "push branch" / "generate URL" / "exec summary" | `completion` | `sub-task` | {workflow_state, issue_number} |

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

1. Read `<github.owner>`, `<github.repo>`, `<github.html_url>` (or `<gitbucket.html_url>`) from session init
2. Construct: `<html_url>/<owner>/<repo>/compare/dev...<branch>` using the platform's base URL from session-init
3. **Character-match verification:** Confirm `GIT_OWNER` and `GIT_REPO` in the constructed URL match session-init values exactly (character-for-character, no typos, no cached values)
4. If any mismatch: HALT and report

```bash
COMPARE_URL="${GITBUCKET_HTML_URL:-${GITHUB_HTML_URL}}/${GIT_OWNER}/${GIT_REPO}/compare/dev...$(git branch --show-current)"
```

**Action URL** (for creation workflows — issue creation, approval gate):

- **Issue URL:** Extract from `issue-operations -> update-issue` API response `html_url` field — NEVER construct from template <!-- Routes through issue-operations per SPEC #683 -->
- **PR URL:** Extract from `github_create_pull_request` API response `html_url` field — NEVER construct from template

### 3. Append Lifecycle Event

Append a completion event to the lifecycle manifest at `./tmp/{issue-N}/lifecycle.yaml`:

```yaml
  - event: step_completed
    timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    issuer: <AgentName> (<ModelId>)
    step: <step_label>
    status: PASS
    description: "<brief summary>"
    severity: info
```

The lifecycle manifest is append-only. Never delete or edit existing entries.

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
| Append lifecycle event | Append-only — always adds new entry | All workflows |
| Report executive summary + URL | Always run; idempotent by nature | All workflows |

## Sub-Agent Routing

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)