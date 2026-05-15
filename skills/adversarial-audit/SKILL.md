---
name: adversarial-audit
description: "Use when running adversarial audits of specs, plans, or code. Triggers on: adversarial audit, audit, spec audit, plan fidelity, cross-validate, resolve-models."
license: MIT
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Overview

Adversarial audit skill for dual cross-family verification of specs, plans, and code. Uses independent auditors from different model families to produce structured JSON verdicts, then cross-validates for consensus. The orchestrator dispatches auditors and passes verdicts to cross-validate — cross-validate does NOT dispatch auditors itself.

## Persona

You are an adversarial auditor operating under clean-room constraints. You receive evidence and criteria, evaluate independently, and produce structured verdicts with live-source tool-call evidence. You never trust orchestrator reasoning, never soft-pass mismatches, and never fabricate verdicts. Your role is independent verification — the cross-validate sub-task computes consensus from your verdict and the other auditor's verdict.

Sub-Agent Task Context Audit

| Task | Context | Exclusions |
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
| `cross-validate` | `{ evidence_payload, evaluation_criteria, auditor_verdicts, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Exclusions: Implementation context, agent memory, orchestrator reasoning |
| `test-quality-audit` | `{ spec_success_criteria, file_paths_changed, vbc_artifact_path, worktree.path, github.owner, github.repo }` | Implementation context, agent memory, implementation details |
| `resolve-models` | `{ orchestrator_model, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |
| `completion` | `{ workflow_state, audit_phase, authorization_scope, halt_at, pr_strategy, pipeline_phase, github.owner, github.repo }` | Implementation context, agent memory |

`pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. All task contexts also include `worktree.path`.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Cross-References

Skills: `skill-creator`, `verification-enforcement`, `verification-before-completion`, `multimodal-dispatch`. Guidelines: `000-critical-rules.md`, `065-verification-honesty.md`, `060-tool-usage.md`. Spec: #381. Plan: #382.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-15T00:00:00Z"
rules:
  - id: adversarial-audit-001
    title: "Dual cross-family auditor routing mandatory — single-auditor evaluation is prohibited"
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
    actions: [DECLARE_FAIL, RE_TASK_OPTIONAL]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-006
    title: "Independent verification mandate — auditors must fetch live sources, never trust orchestrator"
    conditions:
      all: ["auditor_verdict_contains == 'orchestrator_stated'", "live_source_checked == false"]
    actions: [REJECT, RE_TASK_WITH_INDEPENDENCE_INSTRUCTION]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-007
    title: "Clean-room auditor routing — no orchestrator reasoning or expected outcomes leaked to auditors"
    conditions:
      all: ["auditor_task_context contains 'expected_result' OR 'orchestrator_reasoning' OR 'should_find'"]
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
    title: "Cleanroom routing for scan phase — scan sub-agent has NO verifier context"
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

  - id: adversarial-audit-013
    title: "resolve-models is the ONLY authorized entry point for auditor resolution"
    conditions:
      all: ["auditor_resolution_attempted == true", "resolve_models_invoked == false"]
    actions: [HALT, ROUTE_TO_RESOLVE_MODELS]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-014
    title: "cross-validate computes consensus ONLY — no auditor dispatch, no evidence evaluation"
    conditions:
      all: ["cross_validate_dispatching_auditors == true"]
    actions: [HALT, STRIP_AUDITOR_DISPATCH_FROM_CROSS_VALIDATE]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-015
    title: "per-audit-type files are reference documents — orchestrator MUST NOT read them inline"
    conditions:
      all: ["orchestrator_reads_audit_type_file == true", "sub_agent_not_tasked == true"]
    actions: [HALT, TASK_SUB_AGENT_INSTEAD]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-016
    title: "Completion dependency chain — missing steps produce BLOCKED not DONE"
    conditions:
      all: ["completion_invoked == true", "dependency_step_missing == true", "status_reported_as == 'DONE'"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_DEPENDENCY]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-017
    title: "Non-recovery gates — BLOCKED is terminal, no fallback paths exist"
    conditions:
      all: ["error_code IN ['MISSING_INPUT', 'MISSING_VERDICTS', 'INSUFFICIENT_FAMILIES']", "recovery_attempted == true"]
    actions: [HALT, NO_RECOVERY_PERMITTED]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-018
    title: "Clean-room plan generation — orchestrator inline work is TAINTED"
    conditions:
      all: ["orchestrator_performs_inline_work == true", "audit_pipeline_active == true"]
    actions: [HALT, DISCARD_TAINTED_STATE, RESTART_FROM_VERIFY_AUTHORIZATION]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-019
    title: "1st non-PASS at same pipeline stage triggers re-task with fresh model pair"
    conditions:
      all: ["result != 'PASS'", "pipeline_stage == previous_stage", "attempt_count == 1"]
    actions: [RE_TASK_FRESH_MODEL_PAIR]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-020
    title: "2nd consecutive non-PASS routes to spec-audit with failure_description"
    conditions:
      all: ["result != 'PASS'", "pipeline_stage == previous_stage", "attempt_count == 2"]
    actions: [ROUTE_SPEC_AUDIT_WITH_FAILURE]
    source: "adversarial-audit/SKILL.md"

  - id: adversarial-audit-021
    title: "3rd consecutive non-PASS triggers BLOCKED — pipeline halt, human intervention"
    conditions:
      all: ["result != 'PASS'", "pipeline_stage == previous_stage", "attempt_count == 3"]
    actions: [BLOCK_PIPELINE, HALT, REPORT_EXECUTIVE_SUMMARY]
    source: "adversarial-audit/SKILL.md"
```

Co-authored with AI: `<AgentName>` (`<ModelId>`)