# Skill Card Description Standards

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Overview

The `description` field in a SKILL.md YAML frontmatter is a **semantic router** — the agent evaluates its OWN intent against the description, not the user's literal utterance. This document defines the standards for writing descriptions that produce correct semantic matches.

---

## 1. The Description Field as a Semantic Router

### How Semantic Matching Works

When the agent evaluates whether to load a skill, it compares its current task intent against the `description` field of every skill in `<available_skills>`. The match is between:

- **What the agent needs to do next** (its own intent, derived from context, authorization, and pipeline state)
- **What the skill does** (the description field)

The match is NOT between:

- **What the user said** (literal utterance)
- **What the skill does** (description)

This is a critical distinction. The agent does not ask "does the user's message match this description?" It asks "does what I need to do next match what this skill does?"

### Why This Matters

| Wrong Mental Model | Correct Mental Model |
|-------------------|---------------------|
| "User said 'create spec' → match description with 'create spec'" | "Agent needs to produce a spec document → match description with 'produce specification documents'" |
| Description lists trigger phrases the user might say | Description describes what the skill accomplishes |
| Description says "Load via skill() when the user asks for X" | Description says "Create and validate X documents" |

### The Classifier Boundary

The description field is a classifier boundary with two failure modes:

| Failure Mode | Cause | Effect |
|-------------|-------|--------|
| **False activation** | Description too vague — matches too many agent intents | Skill loads when it shouldn't, wasting context |
| **Missed activation** | Description too specific — describes exact user utterances | Skill doesn't load when it should, agent works without guidance |

The goal is a description that is specific enough to avoid false activations but general enough to cover all valid agent intents for that skill.

---

## 2. Progressive Disclosure Architecture

The skill system uses a three-level progressive disclosure architecture:

| Level | What | Content | Approx. Tokens | When Loaded |
|-------|------|---------|----------------|-------------|
| **Level 1** | Metadata | `name` + `description` only | ~100 | Always — in `<available_skills>` list |
| **Level 2** | Instructions | Full SKILL.md body (Overview, Workflows, Cross-References) | ~5,000 | On `skill({name: "..."})` call |
| **Level 3** | Resources | Task cards, scripts, reference docs | ~10,000+ | On `task()` dispatch — subagent reads task card |

The `description` field is the **Level 1 classifier**. It is the only information the agent has when deciding whether to load Level 2. A poor description means the agent makes the Level 1 decision with insufficient signal.

### Implications

- The description must be self-contained — the agent cannot read the SKILL.md body before deciding to load it
- The description must describe the skill's purpose, not its trigger conditions
- Meta-instructions ("Load via skill() when...") waste the ~100 token budget on information the agent already knows (it knows it can call `skill()`)

---

## 3. Description Format

### Canonical Format

```
<Agent task description>. <Context/qualification>.
```

| Element | Example | Required? |
|---------|---------|-----------|
| **Agent task description** | "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements." | Yes |
| **Context/qualification** | "Spec creation is REQUIRED before implementation." | Optional |

### Structural Elements

The agent task description should include:

1. **Action verbs** — what the skill does (create, validate, manage, audit, generate, route)
2. **Domain context** — what domain the skill operates in (specifications, git branches, authorization, code review)
3. **Specificity** — enough detail to distinguish from other skills (not just "manage documents" but "create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts")

### What to Exclude

| Element | Why Excluded |
|---------|-------------|
| "Load via skill() when..." | Meta-instruction — dilutes the semantic vector. The agent decides when to load. |
| "User phrases: ..." | Describes user utterance, not agent intent. Semantic matching is agent-intent-based. |
| "Dispatch when..." | Same as above — describes trigger conditions, not agent task. |
| "Also dispatch when..." | Same as above. |
| "Trigger phrases:" | Same as above. |
| "Triggers on:" | Same as above. |
| First person ("I", "we") | Creates identity ambiguity. The description describes what the skill does, not who the agent is. |
| Role assignment ("you are an X") | Role belongs in system prompt, not skill cards. |

### Examples

**Agent-intent format (correct):**

```yaml
description: "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements."
```

```yaml
description: "Verify authorization scope, apply approval labels, handle spec revision revocation, and execute bug discovery protocol. Authorization verification is REQUIRED before any implementation."
```

```yaml
description: "Create and manage git branches, commit changes, push to remote, create pull requests, handle rebase and merge conflicts, and clean up after PR merges."
```

**Deprecated format (do not use):**

```yaml
description: "Authorization gatekeeper that verifies scope, cascade, and halt boundaries. Dispatch when checking or enforcing authorization scope... User phrases: check authorization, verify scope..."
```

```yaml
description: "Noun phrase that verb phrase. Dispatch when trigger. User phrases: trigger."
```

---

## 4. Persona Framing Standards

Persona framing is a tradeoff (arXiv:2605.29420): role prompting increases expertise depth but reduces clarity. Skill cards and task cards are technical instructions where clarity is paramount.

### Framing Rules

| Context | Framing | Example |
|---------|---------|---------|
| **Skill card description** | Third person declarative | "Create and validate specification documents..." |
| **Workflows "When" clause** | Third person declarative | "When the agent needs to produce a specification document..." |
| **Workflows step name** | Imperative noun phrase | "Inspect codebase", "Decompose problem", "Write spec" |
| **Task card procedure steps** | Second person imperative | "Read the spec file. Extract requirements from the problem statement." |
| **Task card entry/exit criteria** | Third person declarative | "The issue number must be provided." |

### Prohibited Framing

| Framing | Why Prohibited |
|---------|---------------|
| **First person ("I", "we")** | Creates identity ambiguity — who is "I"? The agent? The developer? The skill card is instructions loaded into the agent's context, not the agent speaking. |
| **Role assignment ("you are an X")** | Role assignment belongs in the system prompt (AGENTS.md), not in skill/task cards. Skill/task cards are loaded into an already-established identity. Adding role assignment in a skill card creates identity conflicts. |
| **Second person in descriptions** | "You create specs" — the description describes what the skill does, not what the agent does. Third person declarative is correct. |

### Why First Person Is Harmful

First person in skill/task cards creates identity ambiguity:

- The skill card is loaded into the agent's context as instructions
- If the card says "I inspect the codebase", the agent must resolve whether "I" refers to the agent, the skill, or the developer
- This ambiguity degrades the agent's ability to follow instructions correctly
- All skill/task card content must be framed as instructions, not as the agent speaking

---

## 5. The `skill()` and `task()` Tool Pipeline

Understanding the two-tool pipeline is essential for writing correct descriptions and dispatch contracts.

### `skill({name: "..."})` — Auto-Loads SKILL.md

- Reads the SKILL.md file from disk
- Injects the full content into the **calling agent's context** as XML-wrapped tool output
- The orchestrator receives the skill card automatically — no file read needed
- **Orchestrator-only** — sub-agents dispatched via `task()` cannot call `skill()`

### `task(..., prompt: "...")` — Creates Child Session

- Creates a child session with fresh context
- The `prompt` parameter is the **ONLY context** the subagent receives
- The subagent MUST use its own file read tools to load `tasks/<name>.md`
- The task tool does NOT auto-load task card files
- The discovery directive in the prompt ("Read `<skill>/tasks/<task>.md` first") is REQUIRED because `task()` does not auto-load

### The Complete Pipeline

```
orchestrator
  → skill({name: "..."})
    → SKILL.md auto-loaded into orchestrator context
  → orchestrator reads Workflows section
  → task(..., prompt: "Read `<skill>/tasks/<task>.md` and follow its instructions. Issue: {issue_number}.")
    → child session created
    → subagent reads tasks/<name>.md via file tools
    → subagent executes procedure
    → subagent returns result contract
  → orchestrator receives result contract
  → orchestrator dispatches next step
```

### Key Asymmetry

| Aspect | `skill()` | `task()` |
|--------|-----------|----------|
| Auto-loads content | Yes — SKILL.md | No — subagent must read task card |
| Content type | Skill card (routing metadata) | Task card (execution procedure) |
| Consumer | Orchestrator | Sub-agent |
| Can be called by sub-agent? | No | Yes |

### Why Dispatching SKILL.md to a Sub-Agent Is a Category Error

The skill card contains orchestrator-level routing instructions (Workflows section with dispatch contracts, Cross-References). A sub-agent cannot:

- Call `task()` to dispatch sub-agents (sub-agents have `task: deny` hardcoded)
- Follow Workflows dispatch contracts (those are orchestrator instructions)
- Satisfy Orchestrator Entry Criteria (those apply to the orchestrator)

The skill card tells the orchestrator WHAT to dispatch. The task card tells the sub-agent HOW to execute. Dispatching the skill card to a sub-agent means the sub-agent receives instructions about dispatching — which it cannot do.

---

## 6. Sub-Skill Clarification

### Sub-Skills Are Not an Opencode Concept

The opencode skill system has exactly one abstraction: **SKILL.md with YAML frontmatter**. There is no "sub-skill" type in the opencode binary. What appears to be sub-skills are:

- Independent skills that happen to be co-located in a directory tree
- They appear as independent entries in `<available_skills>`
- They are loaded independently via `skill({name: "..."})`
- They have their own SKILL.md, their own task files, and their own routing

### When to Use a Single Skill vs Multiple Skills

| Pattern | When | Example |
|---------|------|---------|
| **Single skill, multiple task cards** | The tasks are steps in a single workflow that the orchestrator sequences | `spec-creation` with tasks: inspect, decompose, write, check, file |
| **Multiple independent skills** | Each skill handles a different concern, loaded independently by the orchestrator | `git-workflow-branch`, `git-workflow-commit`, `git-workflow-pr` — each is a separate concern |

The current codebase has 20+ co-located skill directories that appear as independent entries in `<available_skills>`. This is not a bug — it is how the opencode skill system works. Each directory with a SKILL.md is an independent skill.

---

## 7. Workflows Section with Sub-Bullet Dispatch Contracts

### Structure

Skill cards use a **Workflows** section where each workflow is a numbered list of clean-room `task()` dispatch steps. Each step has sub-bullets for the dispatch parameters:

```markdown
## Workflows

### Create a spec
When the agent needs to produce a specification document from a problem statement.

1. **Inspect codebase** — search for affected files and existing patterns
   - Prompt: `"Read \`spec-creation/tasks/inspect.md\` and follow its instructions. Issue: {issue_number}."`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Decompose problem** — extract requirements, decompose into SCs
   - Prompt: `"Read \`spec-creation/tasks/decompose.md\` and follow its instructions. Issue: {issue_number}. Findings: {inspect_artifact_path}."`
   - Context: `{issue_number, project_root, inspect_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason, sc_table}`
```

### Sub-Bullet Semantics

| Sub-bullet | Purpose |
|------------|---------|
| **Prompt** | The `prompt` parameter for `task()`. MUST include the discovery directive telling the subagent which task card to read. |
| **Context** | What context to embed in the prompt body. Everything else is automatically excluded — `task()` creates a child session with zero parent context. |
| **Returns** | What the subagent returns in its result contract. |

### Rules

- The `description` parameter for `task()` is derived from the step name (3-5 words)
- The `subagent_type` defaults to `general`. Annotate in the step name when non-default: `1. **Inspect codebase (explore)**`
- No Context Exclude sub-bullet — `task()` excludes everything by default
- The orchestrator waits for each result contract before dispatching the next step
- If any step returns BLOCKED, the workflow halts and reports the blocker
- Task cards that appear in multiple workflows get their own sub-bullets each time — context may differ per workflow
- The `task()` tool accepts exactly 6 parameters: `description`, `prompt`, `subagent_type`, `task_id`, `command`, `background` — there is NO skill or task card parameter

### Base Prompt Format

The base prompt MUST use natural language and MUST include the discovery directive:

```
"Read `<skill>/tasks/<task>.md` and follow its instructions. Issue: {issue_number}."
```

- **Natural language** — not coded dispatch strings like "execute X from Y"
- **Discovery directive** — tells the subagent which file to read (required because `task()` does not auto-load task cards)
- **Issue number** — provides context for the subagent's work

### What the Workflows Section Replaces

The Workflows section replaces the old three-section structure:

| Old Structure | New Structure |
|---------------|---------------|
| Trigger Dispatch Table | Workflows (numbered steps with dispatch contracts) |
| Invocation section | Workflows (sub-bullet dispatch contracts) |
| DISPATCH_GATE section | Workflows (orchestrator sequencing logic) |

Everything the orchestrator needs to dispatch a task is in one place per workflow step.

---

## 8. Cross-References

- `reference/task-card-structure-standards.md` — Task card structure standards
- `reference/skill-card-schema.md` — SKILL.md frontmatter schema (binary constraints)
- `skills/skill-creator/reference/skill-card-spec.md` — Skill card structure reference
- `skills/skill-creator/reference/routing-only-template.md` — Canonical routing-only SKILL.md template
- `skills/skill-creator/SKILL.md` — Skill lifecycle manager
- `000-critical-rules.md` §critical-rules-XXX (dispatching SKILL.md to sub-agent), §critical-rules-034 (orchestrator inline work)
