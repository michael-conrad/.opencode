---
name: verification-before-completion
description: "Completion verification gate that checks success criteria, produces evidence artifacts, and enforces live-source verification before any completion claim. Load via skill() when claiming a task is complete, marking a step done, or closing an issue. Also load when running verification checks against success criteria, producing evidence artifacts, or enforcing live-source verification. Verification is REQUIRED and not optional — MUST use before any completion claim. — distinct from verification (general claim verification) and verification-enforcement (content generation). User phrases: verify completion, check success criteria, produce evidence, close issue"
license: MIT
compatibility: opencode
---

# Skill: verification-before-completion

## Overview

Verification IS completion — there is no valid state called "implemented but unverified." Every claim of completion requires verified PASS for all success criteria. Completion without verification is not completion — it is a placeholder for undiscovered defects.

Remediation of failed verification IS agent-owned — the producing agent owns every defect in its output, and autonomous remediation is the default action before any escalation.

Ensures ALL success criteria are verified with actual evidence before ANY task or phase is marked complete. Structural completeness checked before per-SC verification.

VbC now cross-references analytical artifacts against implementation evidence before allowing completion claims. Blast radius coverage, code path coverage, cross-cutting SC verification, interface compatibility verification, state transition coverage, and testability assessment verification are mandatory gates.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 5. **Analytical artifact cross-reference required before completion claim.** Each analytical artifact must be verified against actual implementation evidence. Contradictions between analytical artifacts and implementation evidence produce HALT. Unverified artifacts produce HALT with the specific artifact name.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "verify" / "verify SCs" / "check completion" | `verify` | `sub-task` | {spec_sc_list, file_paths} |
| "collect" / "collect evidence" | `collect` | `sub-task` | {spec_sc_list, file_paths} |
| "structural-verify" / "structural check" | `structural-verify` | `sub-task` | {spec_structure} |
| "behavioral-test-evaluation" / "evaluate behavioral tests" | `behavioral-test-evaluation` | `sub-task` | {artifact_dir, sc_list} |
| "verify analytical artifacts" | `verify` | `sub-task` | {spec_sc_list, file_paths, analytical_artifact_dir} |
| "blast-radius not verified" | HALT | — | — |
| "code-path-inventory not cross-referenced" | HALT | — | — |
| "interface-compatibility not verified" | HALT | — | — |
| "state-analysis not verified" | HALT | — | — |
| "testability-assessment not verified" | HALT | — | — |
| "analytical artifact contradicts implementation" | HALT | — | — |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Verification Gatekeeper. Focus: no completion claim without verified evidence. Enforce live-source verification only.

## Tasks


| `verify` |
| `collect` |
| `structural-verify` |
| `behavioral-test-evaluation` |
| `completion` |

## Invocation

`skill({name: "verification-before-completion"})` — call the skill, then call via task():

| Task | Call via task() |

| `verify` | `task(..., prompt: "execute verify task from verification-before-completion")` |
| `structural-verify` | `task(..., prompt: "execute structural-verify task from verification-before-completion")` |
| `collect` | `task(..., prompt: "execute collect task from verification-before-completion")` |
| `behavioral-test-evaluation` | `task(..., prompt: "execute behavioral-test-evaluation task from verification-before-completion")` |
| `completion` | `task(..., prompt: "execute completion task from verification-before-completion")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "verification-before-completion"})` ``

## Operating Protocol

Read [the full operating protocol and authorization context](verification-before-completion/tasks/operating-protocol.md)

**Behavioral test evaluation gate:** The verify task (`verify.md`) enforces the behavioral-test-evaluation dispatch procedurally in Step 2 (evidence type classification) and Step 2b (Behavioral Test Evaluation Gate). The verify.md workflow is the canonical enforcement point — the operating protocol §7 cross-references it. The orchestrator MUST NOT claim PASS for behavioral SCs without clean-room evaluation from `behavioral-test-evaluation`.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_sc_list, file_paths, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. Read [audit SKILL.md §DISPATCH_GATE](skills/audit/SKILL.md). Exclusions: implementation context, agent memory, prior verification results. `structural-verify` receives spec structure. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }`. No inline work.

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
| Missing task file discovery directive | "execute verify task from verification-before-completion" without task file path | "execute verify task from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
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

## Operating Protocol

- [ ] 1. **No completion without evidence:** Every completion claim requires verified PASS for ALL success criteria
- [ ] 2. **Exact comparison mode:** External verifications MUST use exact comparison mode — no semantic comparison
- [ ] 3. **Structural completeness first:** Structural completeness MUST be checked before per-SC verification

## Cross-References

Skills: `finishing-a-development-branch`, `audit --task drift-detection`. Guidelines: `065-verification-honesty.md`, `000-critical-rules.md`.


