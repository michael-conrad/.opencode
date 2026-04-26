---
name: programming-principles
description: Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; or evaluating tradeoffs between competing approaches. Triggers on: design, implement, refactor, architecture, tradeoff, principle, KISS, DRY, SRP, coupling, cohesion, YAGNI.
type: pattern
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: programming-principles

## Overview

20 engineering principles as the **single authoritative source** for design judgment and enforcement rules. Each principle includes both the hard rule (where applicable) and the judgment context (when to apply strongly, when to relax). Other files reference HERE — never the other direction.

**Core ethic: Intelligent judgment, not dogmatism.** Principles are tools, not commandments. Apply them where they improve outcomes; relax them where the cost exceeds the benefit — but always document the tradeoff.

## Relationship to Code Standards

| This Skill | `080-code-standards.md` |
| -- | -- |
| Master source for all 20 principles (rules + judgment) | Project-specific conventions (pathlib, f-strings, no re-exports, numbering, etc.) |
| Both enforcement AND design judgment | Principles REMOVED from here; cross-reference note points to this skill |
| Applies to any codebase | Applies to this repo only |

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `principles` | Complete reference for all 20 principles with enforcement levels, apply/relax context, and tradeoff notes | ≈2,200 |
| `application-guide` | How to apply principles during design, implementation, and review; context prioritization table and red flags | ≈400 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `principles` | When full reference for all 20 principles is needed | Design decision context, file paths | Implementation context, agent memory | NO |
| `application-guide` | When application guidance is needed during review or implementation | Review context, code paths, principle scope | Implementation context, agent memory | NO |

## Invocation

This skill is **reference-driven**, not dispatch-triggered. Load via `/skill programming-principles` when the agent needs design judgment.

- `/skill programming-principles` - Load this dispatch document for overview and task index
- `/skill programming-principles --task principles` - Full reference for all 20 principles
- `/skill programming-principles --task application-guide` - Application guide with context table and red flags

| When to Invoke | Example Trigger |
| -- | -- |
| During design decisions | "Which approach has better cohesion?" |
| Before implementation | "Am I violating any principles here?" |
| During code review | "This violates CQS — is the tradeoff documented?" |
| When evaluating alternatives | "Option A has lower coupling but Option B is simpler" |

## Operating Protocol

1. **Reference-first:** Load `--task principles` when you need the full definition of a specific principle
2. **Apply judgment, not dogma:** Principles have apply-strongly and relax-when contexts — use them
3. **Document tradeoffs:** When deliberately relaxing a principle, use the tradeoff note format from `application-guide`
4. **Context-prioritize:** Not all 20 principles matter equally — use the context table in `application-guide`
5. **Enforcement levels differ:** Some principles are enforced (KISS, DRY, SRP, Fail Fast, Defensive Programming), others are design guidance only
6. **Cross-references matter:** Check `080-code-standards.md` for project-specific conventions that reference these principles
7. **Red flags trigger principle checks:** Use the red flags table in `application-guide` when something feels off but you're not sure which principle applies

## Cross-References

| Reference | Relationship |
| -- | -- |
| `080-code-standards.md` | Project-specific conventions (this skill owns principles, that guideline owns conventions) |
| `engineering-approach` skill | Workflow discipline — when to design, verify, communicate (this skill owns *what* principles to apply, that skill owns *when* in the process) |
| `code-size-enforcement` skill | Size limits — SRP and "No Monoliths" have hard limits there; that skill references here for decomposition guidance |
| `concern-separation-auditor` skill | Structural concern separation — this skill provides the design judgment perspective for SoC and Blast Radius; that skill references here for principle definitions |
| `spec-auditor` skill | Principles checked during audit — `principles` subtask checks document compliance against this skill's definitions |
| `plan-fidelity-auditor` skill | Design principle alignment for clean-room comparison context; that skill references here for principle judgment |
| `issue-review` skill | Principle context for audit path delegation; that skill references here for principle-aware triage |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: prog-principles-001
    title: "Enforced principles (KISS, DRY, SRP, Fail Fast, Defensive Programming) MUST be checked during design and review"
    conditions:
      all:
        - "design_or_review_active == true"
    actions:
      - EVALUATE(enforced_principles)
    conflicts_with: []
    requires: []
    triggers: [code-size-enforcement, spec-auditor, concern-separation-auditor]
    source: "programming-principles/SKILL.md §Operating Protocol"

  - id: prog-principles-002
    title: "Deliberately relaxing a principle MUST be documented with tradeoff note"
    conditions:
      all:
        - "principle_relaxed == true"
        - "tradeoff_documented == false"
    actions:
      - HALT
      - DOCUMENT_TRADEOFF
    conflicts_with: []
    requires: []
    triggers: []
    source: "programming-principles/SKILL.md §Operating Protocol"

  - id: prog-principles-003
    title: "YAGNI violations MUST be flagged"
    conditions:
      all:
        - "feature_not_in_spec == true"
        - "implementation_attempted == true"
    actions:
      - FLAG("YAGNI violation — feature not in spec")
    conflicts_with: []
    requires: []
    triggers: [approval-gate]
    source: "programming-principles/SKILL.md §Core ethic"

tasks:
  - id: principles
    skill: programming-principles
    preconditions: []
    postconditions:
      - "all_20_principles_loaded == true"
      - "enforcement_levels_identified == true"
    mandatory: false
    bypass_violation: "principles not loaded for design judgment"
    source: "programming-principles/SKILL.md §Tasks"

  - id: application-guide
    skill: programming-principles
    preconditions:
      - "design_or_review_active == true"
    postconditions:
      - "context_prioritization_applied == true"
      - "red_flags_checked == true"
    mandatory: false
    bypass_violation: "application guide not consulted"
    source: "programming-principles/SKILL.md §Tasks"

decomposition: []
gates:
  - id: tradeoff-documentation-gate
    type: postcondition
    check: "relaxed principles have documented tradeoff notes"
    on_fail: HALT
    source: "programming-principles/SKILL.md §Operating Protocol"
evidence_artifacts:
  - "Tradeoff note in code comments or design doc"
  - "Principle evaluation results in review"
```
