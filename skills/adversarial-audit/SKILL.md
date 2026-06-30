---
name: adversarial-audit
description: "Use when running adversarial audits of specs, plans, or code. Also use when verifying spec fidelity, checking plan coherence, detecting drift, or cross-validating verification results. Invoke for: spec audit, plan fidelity, concern separation, coherence extraction, coherence maintenance, guideline audit, drift detection, spec summary, closure verification, test quality audit, verification audit, resolve models, cross-validate. Audits are not optional — dispatch is MANDATORY. Trigger phrases: audit spec, audit plan, check fidelity, verify coherence, detect drift, cross-validate, audit guidelines, verify closure, audit tests, verify verification, resolve auditor models."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Overview

Dual cross-family audit via clean-room sub-agents. Auditors write YAML verdicts to disk, return frugal contracts. The orchestrator dispatches via `skill()` + `task()` — it does NOT read task files.

## Persona

Dual cross-family audit dispatcher. Routes each audit phase to a clean-room sub-agent from a different model family. An orchestrator that performs audit analysis inline instead of dispatching to an auditor sub-agent has produced a self-review, not a cross-validation — every finding carries the orchestrator's preloaded bias, and the adversarial separation that makes audits reliable is lost from the first byte. Professional auditors dispatch to independent sub-agents. Inlining means the audit was never independent.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "audit #NNN" / "adversarial audit #NNN" | `verification-audit` | `sub-task` | {issue_number, artifact_evidence_dir} |
| "spec audit #NNN" | `spec-audit` | `sub-task` | {issue_number, spec_local_dir} |
| "plan fidelity" / "fidelity audit" | `plan-fidelity` | `sub-task` | {issue_number, plan_local_dir} |
| "concern separation" / "scope audit" | `concern-separation` | `sub-task` | {issue_number} |
| "coherence" / "coherence extraction" | `coherence-extraction` | `sub-task` | {issue_number} |
| "coherence maintenance" / "post-change coherence" | `coherence-maintenance` | `sub-task` | {issue_number} |
| "guideline audit" | `guideline-audit` | `sub-task` | {guideline_paths} |
| "drift detection" / "doc-code drift" | `drift-detection` | `sub-task` | {issue_number} |
| "spec summary" / "PR summary" | `spec-summary` | `sub-task` | {issue_number} |
| "closure verification" / "post-merge audit" | `closure-verification` | `sub-task` | {pr_number} |
| "cross-validate" / "consensus" | `cross-validate` | `sub-task` | {auditor_1_verdict, auditor_2_verdict} |
| "test quality audit" | `test-quality-audit` | `sub-task` | {issue_number} |
| "resolve models" / "select auditors" | `resolve-models` | `sub-task` | {audit_phase} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks

| Task | Purpose |

| `resolve-models` | Select two cross-family auditors via capability probe |
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
| `completion` | Complete audit workflow with output |

## Invocation

`skill({name: "adversarial-audit"})` — call the skill, then call via task().

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every task in this table MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. An orchestrator that inlines a task has produced a deliverable that was never independently verified. Professional orchestrators route to sub-agents. Amateurs inline.

| Task | Call via task() |
|------|-----------------|
| `resolve-models` | `task(..., prompt: "execute resolve-models task from adversarial-audit")` |
| `verification-audit` | `task(..., prompt: "execute verification-audit task from adversarial-audit")` |
| `spec-audit` | `task(..., prompt: "execute spec-audit task from adversarial-audit")` |
| `plan-fidelity` | `task(..., prompt: "execute plan-fidelity task from adversarial-audit")` |
| `concern-separation` | `task(..., prompt: "execute concern-separation task from adversarial-audit")` |
| `coherence-extraction` | `task(..., prompt: "execute coherence-extraction task from adversarial-audit")` |
| `coherence-maintenance` | `task(..., prompt: "execute coherence-maintenance task from adversarial-audit")` |
| `guideline-audit` | `task(..., prompt: "execute guideline-audit task from adversarial-audit")` |
| `drift-detection` | `task(..., prompt: "execute drift-detection task from adversarial-audit")` |
| `spec-summary` | `task(..., prompt: "execute spec-summary task from adversarial-audit")` |
| `closure-verification` | `task(..., prompt: "execute closure-verification task from adversarial-audit")` |
| `cross-validate` | `task(..., prompt: "execute cross-validate task from adversarial-audit")` |
| `test-quality-audit` | `task(..., prompt: "execute test-quality-audit task from adversarial-audit")` |
| `completion` | `task(..., prompt: "execute completion task from adversarial-audit")` |

## Blind Dispatch

Dispatch via `skill()` + `task()`. Standard dispatch fields only. Auditors independently discover SCs and evidence from `spec_local_dir` and `artifact_evidence_dir`. The orchestrator does NOT read task files.

**Default dispatch routing:** Bare "audit #NNN" or "adversarial audit #NNN" routes to `verification-audit` (post-implementation). "Spec audit #NNN" routes to `spec-audit` (pre-implementation). Other tasks have explicit `--task` qualifiers.
