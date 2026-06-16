---
name: adversarial-audit
description: "Use when running adversarial audits of specs, plans, or code. Audits are not optional — they are how trustworthy work is verified."
license: MIT
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

## Overview

Dual cross-family audit via clean-room sub-agents. Auditors write YAML verdicts to disk, return frugal contracts. The orchestrator dispatches via `skill()` + `task()` — it does NOT read task files.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
| -- | -- | -- | -- |
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

## Blind Dispatch

Dispatch via `skill()` + `task()`. Standard dispatch fields only. Auditors independently discover SCs and evidence from `spec_local_dir` and `artifact_evidence_dir`. The orchestrator does NOT read task files.

**Default dispatch routing:** Bare "audit #NNN" or "adversarial audit #NNN" routes to `verification-audit` (post-implementation). "Spec audit #NNN" routes to `spec-audit` (pre-implementation). Other tasks have explicit `--task` qualifiers.
