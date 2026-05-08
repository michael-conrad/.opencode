---
name: adversarial-audit
description: Use when cross-validating evidence, auditing output against live sources, or dispatching dual-adversarial auditor sub-agents for consensus-based verification. Triggers on: adversarial audit, cross-validate, dual auditor, auditor dispatch, cross-family audit, multi-model verification, auditor consensus, independent verification, adversarial verification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: adversarial-audit

## Overview

Dual-adversarial auditor cross-validation infrastructure. Dispatches two auditor sub-agents from different model families, collects structured JSON verdicts, and enforces a consensus gate — PASS only when both auditors independently agree.

## Persona

Adversarial Audit Orchestrator. Dispatches cross-family auditor sub-agents, collects independent verdicts, cross-references for consensus. Rejects results where auditors disagree or fail to produce structured evidence.

## Tasks

| Task | Words | Description |
|------|-------|-------------|
| `cross-validate` | ≈400 | Accept evidence + criteria, resolve two cross-family auditors, dispatch, collect verdicts, cross-reference for consensus |
| `resolve-models` | ≈350 | Enumerate auditor agents, group by family, exclude orchestrator-model, select two from different families |
| `completion` | ≈150 | Halt guarantee per `completion-core` conventions |

## Invocation

`/skill adversarial-audit --task cross-validate`, `--task resolve-models`, `--task completion`.

## Sub-Agent Dispatch Audit

| Dispatch | Context | Exclusions |
|----------|---------|------------|
| `cross-validate` | `{ evidence_payload, evaluation_criteria, audit_phase, github.owner, github.repo }` | Implementation context, agent memory, prior verification |
| `resolve-models` | `{ orchestrator_model, audit_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `completion` | `{ workflow_state, audit_phase, github.owner, github.repo }` | Implementation context, agent memory |

## Cross-References

Skills: `skill-creator`, `verification-enforcement`, `verification-before-completion`, `multimodal-dispatch`. Guidelines: `000-critical-rules.md`, `065-verification-honesty.md`, `060-tool-usage.md`. Spec: #381. Plan: #382.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-04T00:00:00Z"
rules:
  - id: adversarial-audit-001
    title: "Dual cross-family auditor dispatch mandatory — single-auditor evaluation is prohibited"
    conditions:
      all: ["adversarial_evaluation_requested == true", "auditor_count < 2"]
    actions: [HALT, RESOLVE_SECOND_AUDITOR]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-002
    title: "Cross-family auditor selection required — same-family auditors defeat cross-validation"
    conditions:
      all: ["auditor_family(auditor_1) == auditor_family(auditor_2)", "cross_validation_requested == true"]
    actions: [HALT, RESOLVE_DIFFERENT_FAMILY]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-003
    title: "Orchestrator model must never be selected as an auditor"
    conditions:
      all: ["selected_auditor_model == orchestrator_model", "auditor_selection_in_progress == true"]
    actions: [HALT, EXCLUDE_ORCHESTRATOR_MODEL]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-004
    title: "Consensus gate — PASS only when both auditors independently return PASS"
    conditions:
      all: ["auditor_1_result != 'PASS' OR auditor_2_result != 'PASS'", "consensus_declared_as == 'PASS'"]
    actions: [REJECT, DECLARE_FAIL]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-005
    title: "Structured JSON verdicts mandatory — unparseable output equals FAIL"
    conditions:
      all: ["auditor_verdict_parseable == false", "evaluation_complete == true"]
    actions: [DECLARE_FAIL, RE_DISPATCH_OPTIONAL]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-006
    title: "Independent verification mandate — auditors must fetch live sources, never trust orchestrator"
    conditions:
      all: ["auditor_verdict_contains == 'orchestrator_stated'", "live_source_checked == false"]
    actions: [REJECT, RE_DISPATCH_WITH_INDEPENDENCE_INSTRUCTION]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-007
    title: "Clean-room auditor dispatch — no orchestrator reasoning or expected outcomes leaked to auditors"
    conditions:
      all: ["auditor_dispatch_context contains 'expected_result' OR 'orchestrator_reasoning' OR 'should_find'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "adversarial-audit/SKILL.md"
```

Co-authored with AI: `<AgentName>` (`<ModelId>`)
