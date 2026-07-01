---
name: correspondence
description: "Use when drafting stakeholder emails, status updates, or external communications. Also use when analyzing audience context, maintaining audience separation, or generating structured correspondence. Invoke for: stakeholder email drafting, status update creation, external communication drafting, audience analysis, audience separation enforcement. Audience separation MUST be maintained — always required. Trigger phrases: draft email, write stakeholder update, external communication, audience analysis, status report."
license: MIT
compatibility: opencode
---

# Skill: correspondence

## Overview

Enforces multipart/alternative format (text/plain + text/html) for email, stakeholder content rules, audience-aware content levels, and verification-enforcement integration. Prevents markdown in email bodies, internal artifact leakage, and format guessing.

## Persona

Correspondence drafter. Routes audience analysis and content generation to sub-agents that independently assess stakeholder context. An orchestrator that drafts correspondence inline instead of dispatching to an audience-analysis sub-agent has produced a self-addressed message, not a stakeholder communication — every tone and content decision carries the orchestrator's own context rather than an independent audience assessment. Professional correspondents dispatch to audience-aware sub-agents. Inlining means the message was never independently reviewed for audience fit.


## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "draft email" / "draft correspondence" / "stakeholder update" | `draft` | `sub-task` | {context, audience_tier} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `draft` |
| `completion` |

## Invocation

`skill({name: "correspondence"})` — call the skill, then call via task():

| Task | Call via task() |

| `draft` | `task(..., prompt: "execute draft task from correspondence")` |
| `completion` | `task(..., prompt: "execute completion task from correspondence")` |

**CLI equivalent (for human TUI use):** `/skill correspondence --task <task>`

## Operating Protocol

- [ ] 1. **Verification gate before drafting** (`verification-enforcement --task verify`).
- [ ] 2. **Multipart/alternative mandatory** for email output.
- [ ] 3. **Audience separation:** stakeholder tier MUST NOT include internal artifacts (runbook paths, step numbers, internal IPs, file paths, CLI commands).
- [ ] 4. **Audience classification before drafting.** Default to stakeholder tier when unclear.
- [ ] 5. **Revisit after self-review** (`verification-enforcement --task revisit`).
- [ ] 6. **AI byline mandatory** in all correspondence.
- [ ] 7. **Content-type propagation:** match source email format (inspect Content-Type header).
- [ ] 8. **Attribution verification:** no role-proximity inference — only evidence-backed attribution.
- [ ] 9. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Sub-Agent Routing

`draft` runs with `{ context, audience_tier, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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

## Cross-References

Skills: `verification-enforcement`. Guidelines: `000-critical-rules.md` (audience separation).

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: correspondence-002
    title: "Multipart/alternative format mandatory for email"
    conditions:
      all: ["output_format == email", "multipart_alternative_parts_present == false"]
    actions: [REJECT(draft)]
    source: "correspondence/SKILL.md"

  - id: correspondence-003
    title: "Audience separation — no internal artifacts in stakeholder tier"
    conditions:
      all: ["audience_tier == stakeholder", "content_contains_internal_artifacts == true"]
    actions: [REJECT, FILTER(internal)]
    source: "correspondence/SKILL.md"

  - id: correspondence-006
    title: "AI byline mandatory in all correspondence"
    conditions:
      all: ["ai_byline_present == false"]
    actions: [APPEND(byline)]
    source: "correspondence/SKILL.md"
