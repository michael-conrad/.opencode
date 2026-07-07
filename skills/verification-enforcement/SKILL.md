---
name: verification-enforcement
description: "Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence. Also use when collecting evidence artifacts before generation, resolving unverified claims after generation, or enforcing proactive verification. Invoke for: pre-generation verification, evidence artifact collection, post-generation claim resolution, proactive verification enforcement, content verification. Live-source verification before generation is REQUIRED — always mandatory, never optional — distinct from verification (general claim verification) and verification-before-completion (completion gate). Trigger phrases: verify before generation, collect evidence, resolve unverified claims, proactive verification, content verification."
license: MIT
compatibility: opencode
---

# Verification Enforcement

## Overview

Shared verification gate for ALL content-generating skills. Pre-generation: task section-based sub-agents to collect evidence artifacts for every claim. Post-generation: scan for unverified markers, attempt resolution, escalate unresolvable claims. Orchestrator level: reject sub-agent output without evidence artifacts.

Spec content that makes factual claims must include a **Documentation Sources** section documenting live-source verification used for each claim. This section is mandatory for standard and complex specs and is enforced by `audit --task spec-audit` criterion SC-11. Simple specs may omit it.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "verify" / "pre-generation verify" | `verify` | `sub-task` | {section_evidence_table, claim_list} |
| "revisit" / "post-generation scan" | `revisit` | `sub-task` | {generated_content} |
| "enforce" / "enforce evidence" | `enforce` | `sub-task` | {sub_agent_output} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Verification Gatekeeper. Not the content author — the evidence collector running before and after generation. Treats memory/training data as insufficient; tool calls and live documentation as sufficient. Marks what cannot be verified, escalates what cannot be resolved.

## Tasks


| `verify` |
| `revisit` |
| `enforce` |
| `completion` |

## Invocation

`skill({name: "verification-enforcement"})` — call the skill, then call via task():

| Task | Call via task() |

| `verify` | `task(..., prompt: "execute verify task from verification-enforcement")` |
| `revisit` | `task(..., prompt: "execute revisit task from verification-enforcement")` |
| `enforce` | `task(..., prompt: "execute enforce task from verification-enforcement")` |
| `completion` | `task(..., prompt: "execute completion task from verification-enforcement")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "verification-enforcement"})` ``

## Operating Protocol

- [ ] 1. **Pre-generation:** collect section evidence table, task per-section verification sub-agents.
- [ ] 2. **Post-generation:** scan for ⚠️ UNVERIFIED markers, attempt resolution, escalate remaining.
- [ ] 3. **Orchestrator enforcement:** reject sub-agent output lacking evidence artifacts; re-task.
- [ ] 4. **Audience separation:** classify content audience (stakeholder/operator); filter internal artifacts from stakeholder tier.
- [ ] 5. **All factual claims require live-source verification.**
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Sub-Agent Routing

`verify` runs with `{ section_evidence_table, claim_list, worktree.path, github.owner, github.repo }`. `revisit` receives `{ generated_content, ⚠️ UNVERIFIED markers, worktree.path, github.owner, github.repo }`. `enforce` receives `{ sub_agent_output, evidence_artifact_list, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, prior verification. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
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

Guidelines: `065-verification-honesty.md`, `000-critical-rules.md`. Skills: `spec-creation`, `writing-plans`, `sre-runbook`, `skill-creator`, `correspondence`, `audit --task guideline-audit`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: verification-enforcement-001
    title: "Content generation requires verification gate"
    conditions:
      all: ["content_generation_requested == true", "verification_invoked == false"]
    actions: [HALT]
    source: "verification-enforcement/SKILL.md"

  - id: verification-enforcement-004
    title: "Sub-agent output without evidence artifacts is rejected"
    conditions:
      all: ["sub_agent_returned == true", "evidence_artifacts_present == false"]
    actions: [REJECT, RE_TASK]
    source: "verification-enforcement/SKILL.md"
