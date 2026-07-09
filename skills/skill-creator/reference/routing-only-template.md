# Routing-Only SKILL.md Template

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)

## Purpose

This template defines the canonical structure for a routing-only SKILL.md file. A routing-only SKILL.md contains **no procedure text** — no step definitions, no entry/exit criteria, no code snippets, no "Operating Protocol" sections. The orchestrator receives only routing metadata (dispatch table, canonical strings, cross-references). Procedure content lives exclusively in `tasks/*.md` files that only sub-agents read.

## Template

```markdown
---
name: skill-name
description: "Use when <primary use case>. Also use when <secondary use cases>. Invoke for: <comma-separated task list>. <Mandatory enforcement statement>. Trigger phrases: <comma-separated trigger phrase list>."

**Description format (farmage pattern):**
- `Use when` — primary use case (1 sentence)
- `Also use when` — secondary/edge case uses (1 sentence, omit if none)
- `Invoke for:` — comma-separated list of task names the skill handles
- Enforcement statement — e.g., "Spec creation is REQUIRED before implementation."
- `Trigger phrases:` — comma-separated list of natural language phrases an agent might say to invoke this skill
- Max 1024 characters (opencode limit)
- Exclusion clauses (`— distinct from <exclusion>`) for skills that could false-match
license: MIT
provenance: AI-generated
---

# Skill: skill-name

## Overview

[1-2 sentences explaining what this skill enables. No procedure text.]

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work
     that should be delegated to a sub-agent produces defective
     deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless
     explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`,
     `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

- [ ] **"trigger phrase"** → `task-name` (dispatch-type)
  - Context: `{field1, field2}`
  - Task file: `skill-name/tasks/task-name.md`
- [ ] **"another trigger"** → `other-task` (dispatch-type)
  - Context: `{field3}`
  - Task file: `skill-name/tasks/other-task.md`
  - [ ] Sub-step that must be performed (e.g., verify pre-condition)
  - [ ] Another required sub-step (e.g., validate output)

**Sub-item semantics:**
- **Sub-bullets** (`-`): Parameter metadata — context fields, task file paths, dispatch type. Informational, not actionable.
- **Sub-checkboxes** (`- [ ]`): Discrete sub-steps that must be performed (as task or inline op). Actionable.

## Invocation

`skill({name: "skill-name"})` — call the skill, then call via task():

- [ ] **`task-name`** → `task(..., prompt: "execute task-name task from skill-name")`
- [ ] **`other-task`** → `task(..., prompt: "execute other-task task from skill-name")`

**CLI equivalent (for human TUI use):** `` `skill({name: "skill-name"})` ``

## Sub-Agent Routing

[Routing rules: what context fields to pass, what to exclude, any special dispatch instructions.]

- Standard context: `{worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase}`
- Exclusions: orchestrator reasoning, expected outcomes, inline file paths, agent memory, cached verification results
- Auditor tasks use subagent_type from `resolve-models` result contract — NOT `general`
- `pre-analysis` receives only `{issue_number, task_description, github.owner, github.repo}`

## DISPATCH_GATE — Orchestrator task() Prompt Protocol

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
| Missing task file discovery directive | "execute verify-authorization from approval-gate" without task file path | "execute verify-authorization from approval-gate. Read `approval-gate/tasks/verify-authorization.md` first" |

#### Required: Sub-agent Task File Discovery Directive

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

## Cross-References

Skills: [related skills]. Guidelines: [related guidelines].

```yaml+symbolic
schema_version: "2.0"
last_updated: "YYYY-MM-DDTHH:MM:SSZ"
rules:
  - id: skill-name-001
    title: "Rule title"
    conditions:
      all: ["condition"]
    actions: [ACTION]
    source: "skill-name/SKILL.md"
```
```

## Placement Rules

| Section | Placement | Required? |
|---------|-----------|-----------|
| YAML frontmatter | Top of file | Yes |
| Overview | After frontmatter | Yes |
| Mandatory Task Discipline | After Overview | Yes |
| Trigger Dispatch Table | After Mandatory Task Discipline | Yes |
| Invocation | After Trigger Dispatch Table | Yes |
| Sub-Agent Routing | After Invocation | Yes |
| DISPATCH_GATE | After Sub-Agent Routing | Yes |
| Cross-References | After DISPATCH_GATE | Yes |
| Symbolic rules (yaml+symbolic) | End of file | Optional |

## Prohibited Content

The following content MUST NOT appear in a routing-only SKILL.md:

- Numbered step lists (`- [ ] N.` or `N. **Step**`)
- "Entry Criteria:" / "Exit Criteria:" sections
- "Procedure:" sections
- "Operating Protocol:" sections
- Code blocks with bash/python/YAML (except in the template example itself)
- "Structuring This Skill" section
- "Measurement Standard" section
- "Context Window Hygiene" section
- "Correctness-First Economics" section
- "Resources" section with scripts/references/assets descriptions
- Any content that tells a sub-agent HOW to do something (as opposed to WHAT task to dispatch)

## See Also

- `skill-card-spec.md` — Task card structure (for `tasks/*.md` files)
- `skill-creator` skill — Validation rules for skill structure
- `000-critical-rules.md` §critical-rules-034 (orchestrator inline work), §critical-rules-048 (pre-read + inline execution), §critical-rules-dispatch-gate-canonical (canonical dispatch string)
