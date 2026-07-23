# Routing-Only SKILL.md Template

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)

## Purpose

This template defines the canonical structure for a routing-only SKILL.md file. A routing-only SKILL.md contains **no procedure text** — no step definitions, no entry/exit criteria, no code snippets, no "Operating Protocol" sections. The orchestrator receives only routing metadata (workflows with dispatch contracts, cross-references). Procedure content lives exclusively in `tasks/*.md` files that only sub-agents read.

## Template

```markdown
---
name: skill-name
description: "<Agent task description. Describes what the agent needs to DO, not what the user SAYS. Max 1024 characters. No meta-instructions like 'Load via skill() when' or 'User phrases:' — these dilute the semantic vector.>"
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

## Workflows

### Workflow name
When the agent needs to [describe the decision context — what state the agent is in when it should pick this workflow].

1. **Step name** — description of what this step accomplishes
   - Prompt: `"Read \`skill-name/tasks/task-name.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, project_root, ...}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Next step name** — description
   - Prompt: `"Read \`skill-name/tasks/next-task.md\` and follow its instructions. Issue: {issue_number}. Prior: {step1_artifact_path}."`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Another workflow
When the agent needs to [different decision context].

1. **Step name** — description
   - Prompt: `"Read \`skill-name/tasks/task-name.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

## Cross-References

Related skills and reference documents.
```

## Sub-Bullet Semantics

Each numbered step in a workflow is a clean-room `task()` dispatch. The sub-bullets define the dispatch contract:

| Sub-bullet | Purpose |
|------------|---------|
| **Prompt** | The `prompt` parameter for `task()`. MUST include the discovery directive telling the subagent which task card to read. Format: `"Read \`<skill>/tasks/<task>.md\` and follow its instructions. Issue: {issue_number}."` |
| **Context** | What context to embed in the prompt body. Everything else is automatically excluded — `task()` creates a child session with zero parent context. |
| **Returns** | What the subagent returns in its result contract. |

### Rules

- The `description` parameter for `task()` is derived from the step name (3-5 words)
- The `subagent_type` defaults to `general`. Annotate in the step name when non-default: `1. **Inspect codebase (explore)**`
- No Context Exclude sub-bullet — `task()` excludes everything by default
- The orchestrator waits for each result contract before dispatching the next step
- If any step returns BLOCKED, the workflow halts and reports the blocker
- Task cards that appear in multiple workflows get their own sub-bullets each time — context may differ per workflow

## Placement Rules

| Section | Placement | Required? |
|---------|-----------|-----------|
| YAML frontmatter | Top of file | Yes |
| Overview | After frontmatter | Yes |
| Mandatory Task Discipline | After Overview | Yes |
| Workflows | After Mandatory Task Discipline | Yes |
| Cross-References | After Workflows | Yes |


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
