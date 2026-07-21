---
name: audit
description: "Adversarial auditor that verifies specs, plans, code, and generated content against standards. Load via skill() when the agent needs to audit specs, plans, code, or generated content. Also load when verifying spec fidelity, checking plan coherence, detecting drift, cross-validating verification results, or auditing factual claims. Also load when a deliverable was modified in response to audit findings and needs independent re-verification. Audits are not optional — dispatch is MANDATORY. User phrases: audit spec, audit plan, audit code, verify fidelity, check coherence, detect drift, cross-validate"
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Pre-Flight Gate

Before any dispatch, verify `task()` is available:

```yaml
pre_flight:
  check: task() available
  on_failure:
    status: BLOCKED
    reason: TASK_UNAVAILABLE
    message: "task() is not available in this context. Cannot dispatch sub-agents for audit."
    action: HALT all operations
```

## Overview

Audit via clean-room sub-agents. Each audit task is a self-contained procedure dispatched to a clean-room sub-agent via `task(subagent_type="general")`. Auditors write YAML verdicts to disk, return frugal contracts. The orchestrator dispatches via `skill()` + `task()` — it does NOT read task files.

Spec-audit now validates analytical artifacts in addition to structural spec content. The 7 analytical artifacts are: blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, and testability assessment. Missing analytical artifacts produce a BLOCK/HALT; stale artifacts (older than the spec revision) produce a HALT.

## Persona

Audit dispatcher. Routes each audit task to a clean-room sub-agent via `task(subagent_type="general")`. Each task file is self-contained with its own procedure, entry criteria, and exit criteria. An orchestrator that performs audit analysis inline instead of dispatching to a sub-agent has produced a self-review, not an independent audit — every finding carries the orchestrator's preloaded bias, and the audit separation that makes audits reliable is lost from the first byte. Professional auditors dispatch to sub-agents. Inlining means the audit was never independent.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 5. **Analytical artifact validation required before audit tasks.** Spec-audit requires all 7 analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment). Concern-separation requires concern-map. Plan-fidelity requires interface-compatibility. Verification-audit requires code-path-inventory. Cross-validate requires cross-cutting-matrix. Coherence-maintenance requires state-analysis. Test-quality-audit requires testability-assessment. Missing artifacts produce BLOCK/HALT; stale artifacts produce HALT.

## Mandatory Remediation Procedure for Audit FAIL

When any audit produces a FAIL verdict, the following remediation procedure MUST be followed before the deliverable advances to the next pipeline stage:

1. **Diagnose** — Identify which SCs failed and why. Record the root cause in the audit verdict.
2. **Remediate** — Fix the deliverable to address the failing SCs (add missing content, generate missing artifacts, correct wording).
3. **Re-audit** — Re-run the audit with the revised deliverable. All previously failing SCs must now PASS.
4. **Escalate** — If the FAIL cannot be remediated (e.g., the deliverable's core design is structurally unsound, or required analytical artifacts cannot be generated without developer input), escalate to the developer with: the specific SC(s) that failed, the root cause, what the developer must do to resolve, and the recommended action.
5. **Never proceed past FAIL** — A deliverable with any unremediated FAIL must NOT advance to the next pipeline stage. The audit verdict is the gate, not a suggestion.

## Trigger Dispatch Table

Each row dispatches to the DiMo 4-role chain (Investigator → Validator → Evaluator → Arbiter). No row dispatches to a single monolithic task file.

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "audit #NNN" / "run audit" | `verification-audit` | `orchestrator: 4 sequential task() calls` | {issue_number, artifact_evidence_dir} |
| "spec audit #NNN" | `spec-audit` | `orchestrator: 4 sequential task() calls` | {issue_number, spec_local_dir} |
| "plan fidelity" / "fidelity audit" | `plan-fidelity` | `orchestrator: 4 sequential task() calls` | {issue_number, plan_local_dir} |
| "concern separation" / "scope audit" | `concern-separation` | `orchestrator: 4 sequential task() calls` | {issue_number} |
| "coherence" / "coherence extraction" | `coherence-extraction` | `orchestrator: 4 sequential task() calls` | {issue_number} |
| "coherence maintenance" / "post-change coherence" | `coherence-maintenance` | `orchestrator: 4 sequential task() calls` | {issue_number} |
| "guideline audit" | `guideline-audit` | `orchestrator: 4 sequential task() calls` | {guideline_paths} |
| "drift detection" / "doc-code drift" | `drift-detection` | `orchestrator: 4 sequential task() calls` | {issue_number} |
| "spec summary" / "PR summary" | `spec-summary` | `orchestrator: 4 sequential task() calls` | {issue_number} |
| "closure verification" / "post-merge audit" | `closure-verification` | `orchestrator: 4 sequential task() calls` | {pr_number} |
| "cross-validate" / "consensus" | `cross-validate` | `orchestrator: 4 sequential task() calls` | {spec_local_dir, artifact_evidence_dir} |
| "test quality audit" | `test-quality-audit` | `orchestrator: 4 sequential task() calls` | {issue_number} |
| "content audit" / "audit content claims" | `content-audit` | `orchestrator: 4 sequential task() calls` | {document_section, source_data_paths} |
| "analytical artifacts present" / "all artifacts ready" | `spec-audit` | `orchestrator: 4 sequential task() calls` | {issue_number, spec_local_dir, analytical_artifact_dir} |
| "post-remediation re-audit" / "re-audit after remediation" | `spec-audit` | `orchestrator: 4 sequential task() calls` | {issue_number, spec_local_dir, remediation_artifact_dir} |
| completion / workflow end | `completion` | `orchestrator: 4 sequential task() calls` | {workflow_state} |

## Tasks

| Task | Purpose |

| `verification-audit` | Audit implemented code against spec SCs using behavioral evidence. Default audit task. Requires artifact_evidence_dir. |
| `spec-audit` | Pre-implementation spec quality audit. Verifies spec structure, determinism, and live documentation sources. Evidence dir optional. |
| `plan-fidelity` | Verify plan faithfully implements spec |
| `concern-separation` | Audit concern boundaries and scope isolation |
| `coherence-extraction` | Extract coherence baseline from codebase |
| `coherence-maintenance` | Verify codebase coherence after changes |
| `guideline-audit` | Audit guideline content and enforcement |
| `drift-detection` | Detect documentation-code drift |
| `spec-summary` | Summarize spec for PR body |
| `closure-verification` | Verify issue closure criteria |
| `cross-validate` | Arbiter — reads upstream artifacts, produces final judgment |
| `test-quality-audit` | Audit test coverage and quality against spec SCs |
| `content-audit` | Audit of factual claims in generated content — verification of quantitative claims, file references, and assertions against local source data |
| `completion` | Complete audit workflow with output |

## Workflow

### 1. Pre-Flight Gate

- **Dispatch type:** `orchestrator: inline`
- **Dispatch string:** N/A — orchestrator verifies `task()` availability inline
- **Input:** None
- **Output:** BLOCKED with `TASK_UNAVAILABLE` or proceed

### 2. Trigger Dispatch

- **Dispatch type:** `orchestrator: read TDT, dispatch`
- **Dispatch string:** `"audit --task <task-name>"`
- **Input:** User utterance matched against Trigger Dispatch Table
- **Output:** Sub-agent dispatched with task-specific context

### 3. DiMo Chain Execution

- **Dispatch type:** `orchestrator: 4 sequential task() calls`
- **Dispatch string:** `"execute <task-name> DiMo chain: investigator → validator → evaluator → arbiter"` (repeat per role)
- **Input:** Artifact paths from previous role; initial context from Trigger Dispatch Table
- **Output:** `judgment.yaml` with final verdict and `next_step`

Each role is a separate `task(subagent_type="general")` call. The orchestrator dispatches roles in order, passing artifact paths between them:

1. **Investigator** — writes `evidence.yaml` with raw evidence and initial findings
2. **Validator** — reads `evidence.yaml`, writes `reasoning.yaml` with validated evidence
3. **Evaluator** — reads `evidence.yaml` + `reasoning.yaml`, writes `verdict.yaml` with per-criterion PASS/FAIL
4. **Arbiter** — reads all artifacts, writes `judgment.yaml` with final judgment and `next_step`

Artifact directory: `./tmp/{issue-N}/artifacts/{task-name}/`

### 4. Completion

- **Dispatch type:** `orchestrator: halt`
- **Dispatch string:** N/A
- **Input:** N/A
- **Output:** Structured halt message with summary, outcome, blockers, URL, byline

