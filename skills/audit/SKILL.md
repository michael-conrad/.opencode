---
name: audit
description: "Adversarial auditor that verifies specs, plans, code, and generated content against standards. Load via skill() when the agent needs to audit specs, plans, code, or generated content. Also load when verifying spec fidelity, checking plan coherence, detecting drift, cross-validating verification results, or auditing factual claims. Also load when a deliverable was modified in response to audit findings and needs independent re-verification. Audits are not optional — dispatch is MANDATORY. User phrases: audit spec, audit plan, audit code, verify fidelity, check coherence, detect drift, cross-validate"
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

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

Each row dispatches 4 sequential `task()` calls — one per DiMo role (Investigator → Validator → Evaluator → Arbiter). No row dispatches to a single monolithic task file or a single monolithic `task()` call.

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "audit #NNN" / "run audit" | `verification-audit` | `sub-task` (DiMo chain) | {issue_number, artifact_evidence_dir, role_chain: [investigator, validator, evaluator, arbiter]} |
| "spec audit #NNN" | `spec-audit` | `sub-task` (DiMo chain) | {issue_number, spec_local_dir, role_chain: [investigator, validator, evaluator, arbiter]} |
| "plan fidelity" / "fidelity audit" | `plan-fidelity` | `sub-task` (DiMo chain) | {issue_number, plan_local_dir, role_chain: [investigator, validator, evaluator, arbiter]} |
| "concern separation" / "scope audit" | `concern-separation` | `sub-task` (DiMo chain) | {issue_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "coherence" / "coherence extraction" | `coherence-extraction` | `sub-task` (DiMo chain) | {issue_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "coherence maintenance" / "post-change coherence" | `coherence-maintenance` | `sub-task` (DiMo chain) | {issue_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "guideline audit" | `guideline-audit` | `sub-task` (DiMo chain) | {guideline_paths, role_chain: [investigator, validator, evaluator, arbiter]} |
| "drift detection" / "doc-code drift" | `drift-detection` | `sub-task` (DiMo chain) | {issue_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "spec summary" / "PR summary" | `spec-summary` | `sub-task` (DiMo chain) | {issue_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "closure verification" / "post-merge audit" | `closure-verification` | `sub-task` (DiMo chain) | {pr_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "cross-validate" / "consensus" | `cross-validate` | `sub-task` (DiMo chain) | {spec_local_dir, artifact_evidence_dir, role_chain: [investigator, validator, evaluator, arbiter]} |
| "test quality audit" | `test-quality-audit` | `sub-task` (DiMo chain) | {issue_number, role_chain: [investigator, validator, evaluator, arbiter]} |
| "content audit" / "audit content claims" | `content-audit` | `sub-task` (DiMo chain) | {document_section, source_data_paths, role_chain: [investigator, validator, evaluator, arbiter]} |
| "analytical artifacts present" / "all artifacts ready" | `spec-audit` | `sub-task` (DiMo chain) | {issue_number, spec_local_dir, analytical_artifact_dir, role_chain: [investigator, validator, evaluator, arbiter]} |
| "post-remediation re-audit" / "re-audit after remediation" | `spec-audit` | `sub-task` (DiMo chain) | {issue_number, spec_local_dir, remediation_artifact_dir, role_chain: [investigator, validator, evaluator, arbiter]} |
| "blast-radius artifact missing" | HALT | — | — |
| "concern-map artifact missing" | HALT | — | — |
| "code-path-inventory artifact missing" | HALT | — | — |
| "cross-cutting-matrix artifact missing" | HALT | — | — |
| "interface-compatibility artifact missing" | HALT | — | — |
| "state-analysis artifact missing" | HALT | — | — |
| "testability-assessment artifact missing" | HALT | — | — |
| "stale analytical artifacts" | HALT | — | — |
| completion / workflow end | `completion` | `sub-task` (DiMo chain) | {workflow_state, role_chain: [investigator, validator, evaluator, arbiter]} |

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

## Invocation

`skill({name: "audit"})` — call the skill, then dispatch via `task()`.

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every audit task MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed. Professional orchestrators route to sub-agents. Amateurs inline.

### DiMo Chain Invocation

All audit tasks dispatch through the DiMo 4-role chain (see DiMo Role Chain Dispatch below). The orchestrator dispatches each role as a separate `task()` call in sequence, passing artifact paths between them:

```
# Role 1: Investigator
task(..., prompt: "execute <task-name> DiMo investigator from audit. Read audit/tasks/<task-name>.md first")
# Role 2: Validator — reads evidence.yaml from investigator
task(..., prompt: "execute <task-name> DiMo validator from audit. Read audit/tasks/<task-name>.md first")
# Role 3: Evaluator — reads evidence.yaml + reasoning.yaml
task(..., prompt: "execute <task-name> DiMo evaluator from audit. Read audit/tasks/<task-name>.md first")
# Role 4: Arbiter — reads all artifacts, writes judgment.yaml
task(..., prompt: "execute <task-name> DiMo arbiter from audit. Read audit/tasks/<task-name>.md first")
```

No task dispatches to a single monolithic task file. The orchestrator dispatches 4 sequential `task()` calls per row, one per role. Dispatch contracts carry exactly 2 fields: `spec_local_dir` and `artifact_evidence_dir`. No `audit_phase` field. Auditors independently discover SCs and evidence from these two directories. The orchestrator does NOT read task files.

**Default dispatch routing:** Bare "audit #NNN" or "run audit" routes to `verification-audit` (post-implementation). "Spec audit #NNN" routes to `spec-audit` (pre-implementation). Other tasks have explicit `--task` qualifiers.

## DiMo Role Chain Dispatch

Each audit task follows a sequential role chain dispatched as 4 separate `task(subagent_type="general")` calls. The orchestrator dispatches each role as its own `task()` call in order, passing artifact paths between them:

1. **Investigator** — writes `evidence.yaml` with raw evidence and initial findings
2. **Validator** — reads `evidence.yaml`, writes `reasoning.yaml` with validated evidence
3. **Evaluator** — reads `evidence.yaml` + `reasoning.yaml`, writes `verdict.yaml` with per-criterion PASS/FAIL
4. **Arbiter** — reads all artifacts, writes `judgment.yaml` with final judgment and `next_step`

Artifact directory: `./tmp/{issue-N}/artifacts/{task-name}/`

