# Plan Structure Standards

Canonical reference document defining the required structure for implementation plans. Both producers (`writing-plans/tasks/create.md`) and auditors (`plan-fidelity` tasks) read this document via `Read [Text](path)`.

## Three-Tier Plan Structure

| Tier | Scope | Content |
|------|-------|---------|
| Tier 1 (Global) | Pre-phase + post-phase | Coherence gate, baseline check, pre-regression, structural checks, verification, audit, regression check, review-prep, PR creation, completion. Appear once per plan. |
| Tier 2 (Per-Phase) | Phase sections | Metadata, daisy-chained per-item tuples, phase file sections |
| Tier 3 (Per-Item) | Individual items | RED → GREEN → verify → commit. Items are daisy-chained — item N's commit is precondition for item N+1's RED. |

## Plan Frontmatter

```yaml
---
plan_schema_version: 1
issue: <N>
title: "<plan title>"
dispatch: [<skill-names>]
---
```

## Plan Index Sections

1. Title with issue URL
2. Goal / Architecture / Files / Dispatch
3. Blast Radius — affected files and impact zones from blast radius artifact
4. Admonishment — compliance requirement blockquote (top only)
5. One-step-at-a-time protocol admonishment — verbatim blockquote
6. Step Status instruction — verbatim blockquote with progress reporting format
7. Enforcement Gate — all-or-nothing SC completion statement
8. Phase table — phase number, name, concern, SCs, dependencies, step range, dispatch
9. Self-remediation protocol admonishment — verbatim blockquote
10. Exit Criteria — numbered checklist C1 through C{N}

## Phase File Sections

1. Title — `# Phase {NN} — {name}`
2. Phase metadata — Concern, Files, SCs, Dependencies, Entry/Exit conditions
3. Code Path Coverage — per-phase code paths from code path inventory artifact
4. Cross-Cutting SCs — cross-cutting SCs from cross-cutting matrix artifact
5. Interface Boundaries — interface boundaries from interface compatibility artifact
6. State Transitions — state transitions from state analysis artifact
7. Step-by-step — checkbox steps with dispatch indicators, daisy-chained per-item tuples
8. Phase completion block — VbC verification assertions
9. Concern transition — to next phase

## Dispatch Indicators

| Indicator | Meaning |
|-----------|---------|
| `(**inline**)` | Orchestrator executes directly |
| `(**sub-agent**)` | Dispatch via `task()` with phase context |
| `(**clean-room**)` | Dispatch via `task()` with routing metadata only |

## Step Format

- Numbered checkbox `- [ ] N.` with at least one sub-bullet containing metadata, SC reference, or command
- No step describes more than one atomic action
- RED/GREEN conditions contain no line numbers, exact code, or file paths
- RED describes "what fails". GREEN describes "what must be true"

## Admonishments

### Compliance (top only)

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

### One-Step-at-a-Time

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

### Step Status

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

### Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

### Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Prohibited Patterns

- No dispatch tables in plan files
- No TBD/TODO — all file paths, function names, commands must be exact
- No shared cross-references — each phase is self-contained
- No zero-indexed numbering — phases start at 1, steps start at 1
- No line number references — use stable anchors
- No multi-dispatch steps — each step dispatches exactly one sub-agent or executes inline
- No non-standard dispatch indicators — only inline, sub-agent, clean-room
- No omitted mandatory gates — all gates from implementation-workflow reference card are mandatory

## Cost Frame

Per-phase cost-frame language following the dark-prose-007 pattern (see `reference/cost-model-standards.md`). Each phase's cost frame justifies verification costs relative to defect-discovery cost.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
