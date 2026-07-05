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

- Standard context: `{worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase}`
- Exclusions: orchestrator reasoning, expected outcomes, inline file paths, agent memory, cached verification results
- Auditor tasks use subagent_type from `resolve-models` result contract — NOT `general`
- `pre-analysis` receives only `{issue_number, task_description, github.owner, github.repo}`

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
| Cross-References | After Sub-Agent Routing | Yes |
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
