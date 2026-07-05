---
name: verification
description: "Use when verifying claims against evidence using appropriate modalities. Also use when producing PASS/FAIL/UNVERIFIED verdicts per claim with evidence artifacts, or enforcing verification honesty. Invoke for: claim verification, evidence artifact production, verdict generation, verification honesty enforcement, multi-modal verification. Produces PASS/FAIL/UNVERIFIED per claim with evidence artifacts. Verification is REQUIRED — distinct from verification-before-completion (completion gate) and verification-enforcement (content generation). Trigger phrases: verify claim, check evidence, produce verdict, enforce honesty, multi-modal verify."
license: MIT
compatibility: opencode
---

# Verification

## Overview

Invokes `multimodal-dispatch` to verify claims against evidence using appropriate modalities. Each claim gets PASS/FAIL/UNVERIFIED with evidence artifacts. Core invariant: FAIL never downgraded to PASS by agent judgment.

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
| "verify" / "verify claim" / "check claim" | `verify` | `sub-task` | {claims, modalities} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Claim Verifier. Focus: verify each claim against evidence, produce PASS/FAIL/UNVERIFIED with artifacts. Never downgrade FAIL.

## Tasks


| `verify` |
| `completion` |

## ClaimResult Schema

`{ claim_id, status: PASS|FAIL|UNVERIFIED, evidence: { source, artifact }, model_used, modality }`. FAIL transitions only to PASS with new contradictory evidence. UNVERIFIED → PASS or FAIL on re-verification.

## Invocation

`skill({name: "verification"})` — call the skill, then call via task():

| Task | Call via task() |

| `verify` | `task(..., prompt: "execute verify task from verification")` |
| `completion` | `task(..., prompt: "execute completion task from verification")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "verification"})` ``

## Sub-Agent Routing

`verify` runs via `task(subagent_type="general")` with `{ claims, modalities, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: verification-001
    title: "FAIL never downgraded to PASS by agent judgment"
    conditions:
      all: ["claim_status == FAIL", "agent_reclassified_to_PASS == true"]
    actions: [REVERT, KEEP_FAIL]
    source: "verification/SKILL.md"
