# Skill Card Structure Reference

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Mandatory Task Discipline Admonishment

### SKILL.md Version (5 items)

Insert after Overview, before Trigger Dispatch Table:

```markdown
## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work
         that should be delegated to a sub-agent produces defective
         deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless
         explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`,
         `artifact_path`, `blocker_reason`. Full evidence goes to disk.
```

### Task Card Version — Non-Inline (4 items)

Insert after Purpose, before Operating Protocol:

```markdown
## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.
```

### Task Card Version — Inline (3 items)

Insert after Purpose, before Operating Protocol:

```markdown
## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. If blocked, return BLOCKED with reason — do not work around it
- [ ] 3. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.
```

## Placement Rules

| Card Type | Placement |
|-----------|-----------|
| SKILL.md | After Overview, before Trigger Dispatch Table |
| Task card (non-inline) | After Purpose, before Operating Protocol |
| Task card (inline) | After Purpose, before Operating Protocol |

## Variant Selection

| Dispatch Type | Variant | Items |
|---------------|---------|-------|
| `sub-task` (sub-agent dispatched) | Non-inline | 4 items (includes "do not dispatch sub-agents") |
| `inline` / `orchestrator` | Inline | 3 items (omits "do not dispatch sub-agents") |
| SKILL.md (orchestrator-facing) | SKILL.md | 5 items (includes dispatch discipline) |

## Routing-Only SKILL.md Template

For the canonical SKILL.md structure (routing-only, no procedure text), see:

- **`routing-only-template.md`** — The canonical routing-only SKILL.md template

All new skills MUST use the routing-only template. The SKILL.md variant of the Mandatory Task Discipline block (5 items) is included in the template. Task cards (`tasks/*.md`) continue to use the task card variants defined above.

### Description Format

The `description` field in YAML frontmatter uses the **agent-intent pattern**:

```
<Noun phrase describing what the skill is>. Dispatch when <agent-facing trigger conditions>. Also dispatch when <additional trigger conditions>. <Enforcement statement>. User phrases: <preserved user-facing trigger phrases>.
```

See `routing-only-template.md` for the canonical template and validation rules.

### Required Sections

The routing-only SKILL.md template defines the following required sections in order:

| Section | Purpose |
|---------|---------|
| YAML frontmatter | Skill metadata (name, description, license, provenance) |
| Overview | 1-2 sentence skill description |
| Mandatory Task Discipline | Dispatch discipline checklist (5 items) |
| Trigger Dispatch Table | Trigger-to-task routing with context and task file references |
| Invocation | Canonical `skill()` and `task()` call strings |
| Sub-Agent Routing | Context fields to pass and exclude per dispatch |
| **DISPATCH_GATE** | Orchestrator `task()` prompt protocol — forbidden patterns, discovery directive, dispatch context contract, sub-agent entry criteria, orchestrator entry criteria |
| Cross-References | Related skills and guidelines |


### DISPATCH_GATE Section Structure

The DISPATCH_GATE section is **required** in every routing-only SKILL.md. It contains 6 subsections:

1. **Context cost frame** — blockquote noting these are operational bookkeeping, not complexity measures
2. **Forbidden in task() Prompts** — table of violation patterns (preloaded file paths, step sequences, expected outcomes, orchestrator reasoning, missing discovery directive)
3. **Required: Sub-agent Task File Discovery Directive** — the `execute <task> from <skill>. Read \`<skill>/tasks/<task>.md\` first` format
4. **Dispatch Context Contract** — list of fields to include and exclude in every `task()` call
5. **Sub-Agent Entry Criteria** — `PRELOADED_CONTEXT_REJECTED` protocol for sub-agents
6. **Orchestrator Entry Criteria** — mandate to use exact canonical dispatch strings

All 6 subsections MUST be present. The DISPATCH_GATE section is placed after Sub-Agent Routing and before Cross-References.
