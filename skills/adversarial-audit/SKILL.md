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
| `spec-audit` | ≈180 | Audit spec for quality, structure, completeness |
| `plan-fidelity` | ≈150 | Audit plan fidelity via clean-room comparison |
| `concern-separation` | ≈150 | Audit phase structure for concern boundaries |
| `coherence-extraction` | ≈140 | Generate baseline coherence state |
| `coherence-maintenance` | ≈140 | Detect drift against baseline |
| `guideline-audit` | ≈130 | Audit guideline files for ambiguity/conflicts |
| `drift-detection` | ≈120 | Detect spec/code reality drift |
| `spec-summary` | ≈100 | Verify PR/spec consistency before merge |
| `closure-verification` | ≈110 | Verify merge evidence after PR merge |
| `cross-validate` | ≈400 | Dual cross-family auditor dispatch and consensus |
| `resolve-models` | ≈350 | Cross-family auditor model selection |
| `completion` | ≈150 | Halt guarantee per `completion-core` |

## Invocation

`/skill adversarial-audit --task <type>` where `<type>` is one of the individual tasks below. Multi-type dispatch uses sequential direct calls.

Valid types: `spec-audit`, `plan-fidelity`, `concern-separation`, `coherence-extraction`, `coherence-maintenance`, `guideline-audit`, `drift-detection`, `spec-summary`, `closure-verification`.

For cross-validation: `/skill adversarial-audit --task cross-validate` (orchestrator passes pre-resolved `auditor_1` and `auditor_2` in dispatch context).

For auditor model resolution: `/skill adversarial-audit --task resolve-models` (called by orchestrator before cross-validate, NOT by cross-validate itself).

## Cleanroom Dispatch Protocol

All auditor dispatch MUST follow cleanroom discipline:

1. **Scan Phase**: Auditor receives ONLY evidence payload and evaluation criteria — NO orchestrator reasoning, expected outcomes, or prior verification results.

2. **Evidence Collection**: Auditors MUST fetch live sources via tool calls — memory-cached claims are REJECTED per `065-verification-honesty.md`.

3. **Dual Dispatch**: Each auditor type (scan verifier, evidence verifier, etc.) dispatches TWO cross-family sub-agents independently.

4. **Consensus Gate**: PASS only when BOTH auditors independently return PASS for a criterion. FAIL/DISAGREE triggers bidirectional finding presentation.

5. **Bidirectional Findings**: When consensus is FAIL or DISAGREE, present revision options to developer for decision — NO auto-fix.

## Audit Phases

| Audit Type | Phase | Pipeline Touchpoint |
|-----------|-------|---------------------|
| `spec-audit` | `spec_creation` | Post-spec-creation |
| `plan-fidelity` | `plan_creation` | Post-plan-creation |
| `concern-separation` | `sub_issue_creation` | Post-sub-issue-creation |
| `coherence-maintenance` | `coherence_gate` | Pre-RED coherence gate |
| `guideline-audit` | `guideline_update` | Guideline update |
| `drift-detection` | `implementation_verification` | Post-GREEN verification |
| `spec-summary` | `pr_creation` | Pre-PR-creation |
| `closure-verification` | `post_merge` | Post-merge |

## Sub-Agent Dispatch Audit

| Dispatch | Context | Exclusions |
|----------|---------|------------|
| `spec-audit` | `{ spec_issue, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory, plan details |
| `plan-fidelity` | `{ spec_issue, plan_issue, clean_room_plan, auditor_1, auditor_2, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory, existing plan |
| `concern-separation` | `{ spec_issue, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `coherence-extraction` | `{ write_access, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `coherence-maintenance` | `{ baseline_path, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `guideline-audit` | `{ target_files, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `drift-detection` | `{ spec_issue, target_files, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `spec-summary` | `{ pr_number, spec_issue, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `closure-verification` | `{ pr_number, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `cross-validate` | `{ evidence_payload, evaluation_criteria, auditor_1, auditor_2, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory, prior verification |
| `resolve-models` | `{ orchestrator_model, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `completion` | `{ workflow_state, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |

`pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. All dispatch contexts also include `worktree.path`.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Dispatch Rules
- Missing `authorization_scope` in dispatch context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Cross-References

Skills: `skill-creator`, `verification-enforcement`, `verification-before-completion`, `multimodal-dispatch`. Guidelines: `000-critical-rules.md`, `065-verification-honesty.md`, `060-tool-usage.md`. Spec: #381. Plan: #382.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
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

  - id: adversarial-audit-008
    title: "All audits must be adversarial — single-auditor or orchestrator-evaluation is prohibited"
    conditions:
      all: ["audit_requested == true", "adversarial_mode == false"]
    actions: [HALT, REQUIRE_ADVERSARIAL_DISPATCH]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-009
    title: "Consensus required at pipeline gates — PASS gate requires auditor consensus"
    conditions:
      all: ["pipeline_gate == true", "consensus != 'PASS'", "gate_declared_pass == true"]
    actions: [BLOCK_PIPELINE, REQUIRE_CONSENSUS]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-010
    title: "Bidirectional findings presented before revision — FAIL/DISAGREE must show options"
    conditions:
      all: ["consensus == 'FAIL' OR consensus == 'DISAGREE'", "revision_options == null"]
    actions: [APPEND_DEFAULT_OPTIONS]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-011
    title: "Cleanroom dispatch for scan phase — scan sub-agent has NO verifier context"
    conditions:
      all: ["audit_phase == 'scan'", "verifier_context_leaked == true"]
    actions: [HALT, STRIP_VERIFIER_CONTEXT]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-012
    title: "Live-source verification mandatory — memory-cached evidence is rejected"
    conditions:
      all: ["evidence_source == 'memory' OR evidence_source == 'training_data'", "live_source_verified == false"]
    actions: [REJECT_EVIDENCE, REQUIRE_LIVE_VERIFICATION]
    source: "adversarial-audit/SKILL.md"
```

Co-authored with AI: `<AgentName>` (`<ModelId>`)
