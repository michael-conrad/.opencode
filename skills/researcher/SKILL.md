---
name: researcher
description: "Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. Also use when investigating root causes, performing exhaustive research, or producing remediation scope analysis. Invoke for: information discovery, source attribution, gap reporting, root cause investigation, exhaustive research, remediation scope analysis. All findings MUST be verified against live sources. Trigger phrases: research, investigate, discover information, find root cause, exhaustive search, source attribution."
type: problem-solving
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Researcher

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->


## Overview

Dedicated research skill for exhaustive investigation with verifiable source evidence. Used by the implementation-pipeline on FAIL for remediation scope determination, but generally available for all research tasks.

Research without tool calls produces memory guesses. Every unverified finding is a liability, not evidence.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "investigate" / "exhaustive research" / "deep dive" | `investigate` | `sub-task` | {query, modalities} |
| "findings" / "format findings" / "research report" | `findings` | `sub-task` | {research_results} |

## Persona

Exhaustive Investigator. Focus: verifiable source evidence, exhaustive research before conclusions, explicit gap reporting for unverified claims.

## Tasks

| Task | Purpose |

| `investigate` | Execute an exhaustive investigation with verifiable source evidence |
| `findings` | Format research findings with YAML frontmatter + markdown body |

## Invocation

`skill({name: "researcher"})` — call the skill, then call via task().

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every task in this table MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. An orchestrator that inlines a task has produced a deliverable that was never independently verified. Professional orchestrators route to sub-agents. Amateurs inline.

| Task | Call via task() |

| `investigate` | `task(..., prompt: "execute investigate task from researcher")` |
| `findings` | `task(..., prompt: "execute findings task from researcher")` |

**CLI equivalent:** `/skill researcher --task investigate`

## Operating Protocol

- [ ] 1. **Always saves artifacts** with YAML frontmatter + markdown body
- [ ] 2. **Sources MUST be verifiable** — URLs fetched and confirmed, file paths confirmed via `read`/`srclight_*`
- [ ] 3. **Exhaustive research mandate** — better to spend time than repeat work
- [ ] 4. **No arbitrary attempt cap** — each remediation is a fresh investigation
- [ ] 5. **Escalation only for unresolvable blockers** — developer escalation is last resort
- [ ] 6. **Can use `solve model` and `solve prove`** for Z3 constraint investigation during remediation — uses the `solve` skill card at `skills/solve/`.

## Artifact Format

Pipeline context: `pipeline-researcher-{topic}-{STATUS}-{timestamp}.md` (under `./tmp/{issue-N}/artifacts/`)
General context: `research-{topic}-{STATUS}-{timestamp}.md`

### YAML Frontmatter

```yaml
---
step: <pipeline_step_label or "adhoc">
triggered_by_step: <step_label or null>
failure_artifact: <path to FAIL artifact or null>
prior_artifacts_consulted:
  - <path>
remediation_scope: <full | partial | none>
remediation_steps:
  - target_step: <step_label>
    action: <description>
escalation_required: <true | false>
---
```

### Markdown Body

```
## Research Summary

<1-3 sentence summary>

## Findings

- **Finding 1:** <description>
  - **Evidence:** <tool-call output or URL content>
  - **Source:** <verified source>
  - **Verification Method:** <how the source was confirmed>
- **Finding 2:** ...

## Remediation Rationale

<why this remediation approach was chosen>

## Sources Consulted

| Source | Type | Verification Method | Status |
|--------|------|-------------------|--------|
| ... | ... | ... | verified/unavailable |
```

## Cross-References

Skills: `implementation-pipeline`, `research`. Tools: `.opencode/tools/solve`. Skills: `solve` at `skills/solve/`. Guidelines: `065-verification-honesty.md`.
