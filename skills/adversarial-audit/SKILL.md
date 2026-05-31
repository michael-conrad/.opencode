---
name: adversarial-audit
description: "Use when running adversarial audits of specs, plans, or code. Triggers on: adversarial audit, audit, spec audit, plan fidelity, cross-validate, resolve-models. Una audited work carries undiscovered defects. Audits are not optional — they are how trustworthy work is verified."
license: MIT
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Overview

Dual cross-family audit via clean-room sub-agents. Auditors write YAML verdicts to disk, return frugal contracts. The orchestrator dispatches via `skill()` + `task()` — it does NOT read task files.

## Tasks

| Task | Purpose |
|------|---------|
| `resolve-models` | Select two cross-family auditors via capability probe |
| `spec-audit` | Audit spec content against success criteria |
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
