# Task Card Structure Standards

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Overview

Task cards (`tasks/<name>.md`) contain the execution procedure that a sub-agent follows when dispatched via `task()`. Unlike SKILL.md (which contains routing metadata for the orchestrator), task cards contain step-by-step instructions for the sub-agent to execute.

---

## 1. Canonical Sections

A task card has the following sections in order:

| Section | Required? | Purpose |
|---------|-----------|---------|
| YAML frontmatter | No | Task metadata (not parsed by opencode binary — for human/agent reference) |
| Purpose | Yes | 1-2 sentences describing what this task accomplishes |
| Task Discipline | Yes | Discipline checklist (3 or 4 items depending on dispatch type) |
| Entry Criteria | Yes | Conditions that must be met before the sub-agent starts |
| Procedure | Yes | Numbered steps the sub-agent executes |
| Exit Criteria | Yes | Conditions that must be met before the sub-agent returns |
| Result Contract | Yes | What the sub-agent returns to the orchestrator |

### Purpose

1-2 sentences describing what this task accomplishes. Third person declarative.

```
Creates a specification document from decomposition artifacts and writes it to .issues/{N}/spec.md.
```

### Task Discipline

A checklist of discipline rules. Two variants:

**Non-inline variant (4 items)** — for tasks dispatched to sub-agents:

```markdown
## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.
```

**Inline variant (3 items)** — for tasks executed by the orchestrator inline:

```markdown
## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. If blocked, return BLOCKED with reason — do not work around it
- [ ] 3. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.
```

The inline variant omits "Do not dispatch sub-agents" because inline tasks are executed by the orchestrator, which CAN dispatch sub-agents.

### Entry Criteria

Conditions that must be met before the sub-agent starts executing. Third person declarative.

```markdown
## Entry Criteria

- The issue number must be provided
- The spec body must be available at the artifact path
- The project root must be set
```

If any entry criterion is not met, the sub-agent returns BLOCKED with the unmet criterion as the reason.

### Procedure

Numbered steps the sub-agent executes. Second person imperative — direct commands.

```markdown
## Procedure

1. Read the spec body from the artifact path.
2. Extract all success criteria from the spec body.
3. For each SC, identify the evidence type and verification method.
4. Write the SC table to the spec body.
5. Return the result contract.
```

Rules:
- Each step is a single action — if a step has sub-steps, use a nested numbered list
- Steps are sequential — the sub-agent executes them in order
- If a step fails, the sub-agent returns BLOCKED with the failure reason
- Do not include orchestrator-level instructions (no `task()` calls, no `skill()` calls)

### Exit Criteria

Conditions that must be met before the sub-agent returns. Third person declarative.

```markdown
## Exit Criteria

- The spec body has been written to .issues/{N}/spec.md
- The SC table includes evidence types for all SCs
- The artifact path has been set in the result contract
```

If any exit criterion is not met, the sub-agent returns BLOCKED with the unmet criterion as the reason.

### Result Contract

What the sub-agent returns to the orchestrator. Specifies the fields and their types.

```markdown
## Result Contract

```yaml
status: DONE | BLOCKED | OVERFLOW
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to full evidence on disk>"
blocker_reason: "<reason if BLOCKED>"
```
```

The result contract is the sub-agent's only output. Full evidence artifacts go to disk at the `artifact_path`.

---

## 2. What Task Cards MUST NOT Contain

| Content | Why Prohibited |
|---------|---------------|
| `task()` calls | Sub-agents cannot dispatch sub-agents (sub-agents have `task: deny` hardcoded). Only the orchestrator calls `task()`. |
| `skill()` calls | Sub-agents cannot call `skill()` (sub-agents have no access to the skill tool). Only the orchestrator calls `skill()`. |
| Orchestrator-level routing instructions | Workflows, dispatch contracts, Trigger Dispatch Tables — these are orchestrator instructions. The sub-agent executes, not routes. |
| DISPATCH_GATE protocol | The DISPATCH_GATE protocol governs how the orchestrator constructs `task()` calls. Sub-agents do not construct `task()` calls. |
| Cross-references to other skills | Cross-references are orchestrator routing metadata. Sub-agents follow their task card, not navigate the skill deck. |
| Persona/role assignment | "You are a spec creator" — role assignment belongs in the system prompt (AGENTS.md), not in task cards. Task cards are instructions loaded into an already-established identity. |
| First person ("I", "we") | Creates identity ambiguity. The task card is instructions, not the agent speaking. |

---

## 3. Result Contract Format

The result contract is a structured YAML object with exactly these fields:

| Field | Required | Values | Purpose |
|-------|----------|--------|---------|
| `status` | Yes | `DONE`, `BLOCKED`, `OVERFLOW` | Whether the task completed successfully |
| `finding_summary` | Yes | 1-3 sentences | Routing-significant output for the orchestrator |
| `artifact_path` | Yes | Path to file on disk | Where full evidence artifacts are stored |
| `blocker_reason` | If BLOCKED | String | Why the task could not complete |

### Status Values

| Status | Meaning | Orchestrator Action |
|--------|---------|---------------------|
| `DONE` | Task completed successfully | Proceed to next step |
| `BLOCKED` | Task could not complete | Halt workflow, report blocker |
| `OVERFLOW` | Task exceeded context budget | Re-task with same context (max 2 retries) |

### Evidence Artifacts

Full evidence goes to disk at the `artifact_path`. The result contract carries only routing-significant data. The orchestrator does not read evidence artifacts — they are consumed by auditors and verification gates.

---

## 4. Task File Discovery Directive

When the orchestrator dispatches a sub-agent via `task()`, the prompt MUST include a discovery directive telling the sub-agent which task card to read:

```
"Read `<skill>/tasks/<task>.md` and follow its instructions. Issue: {issue_number}."
```

This is required because `task()` does NOT auto-load task card files. The sub-agent must use its own file read tools to load the task card.

The discovery directive is routing metadata (which file to read), not preloading. It tells the sub-agent where to find its instructions — it does not tell the sub-agent what those instructions say.

---

## 5. Task Card vs SKILL.md — Division of Responsibility

| Aspect | SKILL.md | Task Card |
|--------|----------|-----------|
| Consumer | Orchestrator | Sub-agent |
| Content | Routing metadata (workflows, dispatch contracts) | Execution procedure (steps, criteria) |
| Loaded by | `skill({name: "..."})` — auto-loaded | `task()` — sub-agent reads via file tools |
| Contains task() calls? | Yes — in Workflows section | No — sub-agents cannot call task() |
| Contains procedure steps? | No — only dispatch contracts | Yes — numbered execution steps |
| Contains entry/exit criteria? | No — only orchestrator entry criteria | Yes — sub-agent entry/exit criteria |
| Contains result contract? | No — only dispatch contract (Prompt, Context, Returns) | Yes — what the sub-agent returns |

---

## 6. Cross-References

- `reference/skill-card-description-standards.md` — Description field standards and persona framing
- `reference/skill-card-schema.md` — SKILL.md frontmatter schema (binary constraints)
- `skills/skill-creator/reference/skill-card-spec.md` — Skill card structure reference
- `skills/skill-creator/reference/routing-only-template.md` — Canonical routing-only SKILL.md template
- `skills/skill-creator/SKILL.md` — Skill lifecycle manager
