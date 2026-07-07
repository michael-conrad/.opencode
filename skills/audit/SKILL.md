---
name: audit
description: "Use when running audits of specs, plans, code, or generated content. Also use when verifying spec fidelity, checking plan coherence, detecting drift, cross-validating verification results, or auditing factual claims in generated content. Invoke for: spec audit, plan fidelity, concern separation, coherence extraction, coherence maintenance, guideline audit, drift detection, spec summary, closure verification, test quality audit, verification audit, content audit, cross-validate. Audits are not optional — dispatch is MANDATORY. Trigger phrases: audit spec, audit plan, check fidelity, verify coherence, detect drift, cross-validate, audit guidelines, verify closure, audit tests, verify verification, content audit."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Overview

Audit via clean-room sub-agents. Each audit task is a self-contained procedure dispatched to a clean-room sub-agent via `task(subagent_type="general")`. Auditors write YAML verdicts to disk, return frugal contracts. The orchestrator dispatches via `skill()` + `task()` — it does NOT read task files.

## Persona

Audit dispatcher. Routes each audit task to a clean-room sub-agent via `task(subagent_type="general")`. Each task file is self-contained with its own procedure, entry criteria, and exit criteria. An orchestrator that performs audit analysis inline instead of dispatching to a sub-agent has produced a self-review, not an independent audit — every finding carries the orchestrator's preloaded bias, and the audit separation that makes audits reliable is lost from the first byte. Professional auditors dispatch to sub-agents. Inlining means the audit was never independent.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "audit #NNN" / "run audit" | `verification-audit` | `sub-task` | {issue_number, artifact_evidence_dir} |
| "spec audit #NNN" | `spec-audit` | `sub-task` | {issue_number, spec_local_dir} |
| "plan fidelity" / "fidelity audit" | `plan-fidelity` | `sub-task` | {issue_number, plan_local_dir} |
| "concern separation" / "scope audit" | `concern-separation` | `sub-task` | {issue_number} |
| "coherence" / "coherence extraction" | `coherence-extraction` | `sub-task` | {issue_number} |
| "coherence maintenance" / "post-change coherence" | `coherence-maintenance` | `sub-task` | {issue_number} |
| "guideline audit" | `guideline-audit` | `sub-task` | {guideline_paths} |
| "drift detection" / "doc-code drift" | `drift-detection` | `sub-task` | {issue_number} |
| "spec summary" / "PR summary" | `spec-summary` | `sub-task` | {issue_number} |
| "closure verification" / "post-merge audit" | `closure-verification` | `sub-task` | {pr_number} |
| "cross-validate" / "consensus" | `cross-validate` | `sub-task` | {spec_local_dir, artifact_evidence_dir} |
| "test quality audit" | `test-quality-audit` | `sub-task` | {issue_number} |
| "content audit" / "audit content claims" | `content-audit` | `sub-task` | {document_section, source_data_paths} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

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
| `cross-validate` | Compute dual-auditor consensus from YAML artifacts |
| `test-quality-audit` | Audit test coverage and quality against spec SCs |
| `content-audit` | Audit of factual claims in generated content — verification of quantitative claims, file references, and assertions against local source data |
| `completion` | Complete audit workflow with output |

## Invocation

`skill({name: "audit"})` — call the skill, then call via task().

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every task in this table MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. An orchestrator that inlines a task has produced a deliverable that was never independently verified. Professional orchestrators route to sub-agents. Amateurs inline.

| Task | Call via task() |
|------|-----------------|
| `verification-audit` | `task(..., prompt: "execute verification-audit task from audit")` |
| `spec-audit` | `task(..., prompt: "execute spec-audit task from audit")` |
| `plan-fidelity` | `task(..., prompt: "execute plan-fidelity task from audit")` |
| `concern-separation` | `task(..., prompt: "execute concern-separation task from audit")` |
| `coherence-extraction` | `task(..., prompt: "execute coherence-extraction task from audit")` |
| `coherence-maintenance` | `task(..., prompt: "execute coherence-maintenance task from audit")` |
| `guideline-audit` | `task(..., prompt: "execute guideline-audit task from audit")` |
| `drift-detection` | `task(..., prompt: "execute drift-detection task from audit")` |
| `spec-summary` | `task(..., prompt: "execute spec-summary task from audit")` |
| `closure-verification` | `task(..., prompt: "execute closure-verification task from audit")` |
| `cross-validate` | `task(..., prompt: "execute cross-validate task from audit")` |
| `test-quality-audit` | `task(..., prompt: "execute test-quality-audit task from audit")` |
| `content-audit` | `task(..., prompt: "execute content-audit task from audit")` |
| `completion` | `task(..., prompt: "execute completion task from audit")` |

## Blind Dispatch

Dispatch via `skill()` + `task()`. Standard dispatch fields only. Dispatch contracts carry exactly 2 fields: `spec_local_dir` and `artifact_evidence_dir`. No `audit_phase` field. Auditors independently discover SCs and evidence from these two directories. The orchestrator does NOT read task files.

**Default dispatch routing:** Bare "audit #NNN" or "run audit" routes to `verification-audit` (post-implementation). "Spec audit #NNN" routes to `spec-audit` (pre-implementation). Other tasks have explicit `--task` qualifiers.

## DiMo Role Chain Dispatch

Each audit task follows a sequential role chain. The orchestrator dispatches roles in order, passing artifact paths between them:

1. **Knowledge Supporter** (coherence-extraction) — writes `evidence.yaml` with extracted rules and behaviors
2. **Path Provider** (resolve-models) — writes `reasoning.yaml` with model selection and routing rationale
3. **Evaluator** (all audit tasks) — reads `evidence.yaml` and `reasoning.yaml`, writes `verdict.yaml`
4. **Judger** (cross-validate) — reads all artifacts (`evidence.yaml`, `reasoning.yaml`, `verdict.yaml`), writes `judgment.yaml`

The `resolve-models` task is replaced by the DiMo role chain. Model selection is embedded in the Path Provider role within each task's sequential dispatch. No separate `resolve-models` invocation is needed.
