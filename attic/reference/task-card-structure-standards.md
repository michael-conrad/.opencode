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

Numbered-checkbox steps the sub-agent executes. Second person imperative — direct commands. The Procedure is a **numbered-checkbox list** (`- [ ] N.`), not a plain numbered list.

```markdown
## Procedure

- [ ] 1. Read the spec body from the artifact path.
- [ ] 2. Extract all success criteria from the spec body.
- [ ] 3. For each SC, identify the evidence type and verification method.
- [ ] 4. Write the SC table to the spec body.
- [ ] 5. Return the result contract.
```

Rules:
- Each step is a single action — if a step has sub-steps, use a nested numbered-checkbox list
- Steps are sequential — the sub-agent executes them in order
- If a step fails, the sub-agent returns BLOCKED with the failure reason
- Do not include orchestrator-level instructions (no `task()` calls, no `skill()` calls)

#### Clean-Room Unit Mandate

Task cards are the execution unit for **non-task-capable sub-agents**. A sub-agent dispatched via `task()` cannot call `task()` or `skill()` itself — it executes the single task card it was dispatched to read. Therefore:

- **A task-card Procedure MUST NOT require internal sub-agent dispatch.** A procedure that would require the sub-agent to dispatch further sub-agents (`task()` calls, `skill()` calls, or any orchestrator-level routing) MUST be split into multiple task cards, each dispatched as a separate workflow step by the orchestrator.
- The sub-agent executes one clean-room unit — one task card — and returns its result contract. It does not orchestrate downstream work.

#### Dispatch-Contract Completeness Requirement

A task card declares the parameters it requires in its Dispatch Contract and Entry Criteria. For the sub-agent to execute, the orchestrator MUST supply **every** required parameter.

- The workflow's **Context** sub-bullet MUST supply every parameter named in the task card's **Dispatch Contract** and **Entry Criteria**.
- A workflow that omits a required parameter from its Context is a dispatch-contract completeness defect — the sub-agent would fabricate or guess the missing value.
- When a task card is dispatched, the orchestrator MUST verify its Context sub-bullet is complete against the task card's Dispatch Contract and Entry Criteria before issuing the `task()` call.

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

## 2a. Plan Pre-Flight Guard — `ORCHESTRATOR_ONLY_PLAN`

The card-side pre-flight guard (`ORCHESTRATOR_ONLY_SKILL_CARD`, defined in `skill-card-description-standards.md`) protects skill cards from sub-agent consumption. Plans are the other whole-artifact forwarding target and carry the analogous guard:

**Every leaf sub-agent MUST carry a plan pre-flight guard that detects a whole plan body in its dispatch prompt and rejects it:**

> If your `task()` dispatch prompt contains a whole plan document body (a plan's phases, step-by-step sections, or phase-completion criteria — i.e., a plan document forwarded verbatim rather than a step-scoped prompt or a task-card path), you MUST NOT consume or execute it. Return `status: BLOCKED` with `blocker_reason: ORCHESTRATOR_ONLY_PLAN` and halt.

**Trip condition (precisely specified):** the guard fires when the dispatch prompt contains the plan DOCUMENT BODY — phase structures, step lists, or completion criteria copied from a plan file. The guard does NOT fire on:

- Step-scoped prompts that reference a plan by path (e.g., "execute the step at plan section X" with the orchestrator's own context)
- Task-card dispatch strings (`tasks/*.md` paths) — the sanctioned carriers
- Result-contract data or context fields that happen to name a plan file

**Why:** plans are orchestrator-consumed artifacts (the orchestrator reads the plan and executes steps in its own context per the executing-plans workflow). A sub-agent receiving a whole plan body would execute orchestrator-level pipeline work without authorization scope, dispatch capability, or verification gates — silent malfunction instead of a `BLOCKED` contract.

**Canonical guard text (for sub-agent entry patterns in task-card directive text):**

```
If you are a sub-agent (dispatched via task()) and your dispatch prompt contains a whole plan body (phases, step-by-step sections, or phase-completion criteria forwarded from a plan document), you MUST NOT consume or execute it. Return status: BLOCKED with blocker_reason: ORCHESTRATOR_ONLY_PLAN and halt. Step-scoped prompts and task-card paths are unaffected — they are the sanctioned carriers.
```

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
Dispatch a sub-agent with the prompt "Follow the instructions in [<skill>/tasks/<task>.md](.opencode/skills/<skill>/tasks/<task>.md). {context data}"
```

This is required because `task()` does NOT auto-load task card files. The sub-agent must use its own file read tools to load the task card.

The discovery directive is routing metadata (which file to read), not preloading. It tells the sub-agent where to find its instructions — it does not tell the sub-agent what those instructions say.

### Sub-Agent Entry Pattern

The canonical sub-agent entry pattern opens every dispatch prompt: `You are a sub-agent.` followed by the discovery directive and context. The entry pattern MUST carry the plan pre-flight guard so a leaf sub-agent receiving a whole plan body rejects it before consuming any content:

```
You are a sub-agent. Follow the instructions in [<skill>/tasks/<task>.md](.opencode/skills/<skill>/tasks/<task>.md). {context data}
```

If the dispatch prompt contains a whole plan body (phases, step-by-step sections, or phase-completion criteria forwarded from a plan document), the sub-agent MUST NOT consume or execute it — return `status: BLOCKED` with `blocker_reason: ORCHESTRATOR_ONLY_PLAN` and halt. Step-scoped prompts and task-card paths are unaffected — they are the sanctioned carriers. Guard semantics: [§2a Plan Pre-Flight Guard](#2a-plan-pre-flight-guard--orchestrator_only_plan).

### Purpose Statement as Dispatch-Anchor Source

The **purpose statement** — the first content section after the YAML frontmatter/provenance of a task card — is the **dispatch-anchor source**. The dispatch anchor is the condensed routing signal the orchestrator uses to select and dispatch a task card. The purpose statement is the normative source from which that anchor is condensed, and it MUST satisfy three properties:

1. **Condensable** — the purpose statement is short enough to condense into a concise dispatch anchor without loss of routing meaning. A purpose statement that cannot be condensed into a dispatch anchor is a routing defect.
2. **Outcome-as-subject** — the purpose statement names the outcome as its subject, not the mechanism or role. It describes what the task accomplishes (the result), not how it is performed or who performs it.
3. **Distinctive** — the purpose statement is distinguishable from sibling tasks within the same skill. A purpose statement that could be confused with another task card in the same skill cannot anchor dispatch unambiguously.

This establishes the condensation SOURCE contract: the dispatch anchor is derived from the purpose statement, so the purpose statement's condensability, outcome-as-subject framing, and distinctiveness determine whether the anchor can route dispatch correctly.

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

## 7. Dynamic Loading

Any task that validates against reference-dependent criteria MUST load those criteria dynamically via `Read [Text](path)` from the canonical reference document. Hardcoded inline lists that duplicate reference content are prohibited.

This rule ensures that validation criteria stay synchronized with their authoritative source documents. When a reference document is updated, all tasks that validate against it automatically pick up the changes through the `Read [Text](path)` pattern — no manual synchronization needed.

### Examples

| Prohibited (hardcoded) | Required (dynamic) |
|------------------------|-------------------|
| `Required sections: Objective, Background, SCs, Requirements, Phases, Traceability` | `Read [spec-structure-standards.md](.opencode/reference/spec-structure-standards.md) and load the required section inventory` |
| `Evidence types: behavioral, semantic, string, structural` | `Read [Evidence Type Taxonomy](.opencode/skills/test-driven-development/SKILL.md) and load the evidence type definitions` |

### Enforcement

- Spec-audit checks for hardcoded inline lists that duplicate reference content
- Task reviews flag any validation step that hardcodes criteria instead of loading them dynamically
- Violations are process-integrity defects (Tier 2 — HALT)

---

## 8. Cross-References

- Read [the canonical dispatch-vocabulary table](.opencode/reference/skill-card-description-standards.md) — the single source of truth for skill card, task card, orchestrator, whole-card/whole-plan forwarding prohibitions, and the plan-step dispatch modes; this file's guard and mode definitions reference that table instead of restating vocabulary.
- `reference/skill-card-schema.md` — SKILL.md frontmatter schema (binary constraints)
- `skills/skill-creator/reference/skill-card-spec.md` — Skill card structure reference
- `skills/skill-creator/reference/routing-only-template.md` — Canonical routing-only SKILL.md template
- `skills/skill-creator/SKILL.md` — Skill lifecycle manager
