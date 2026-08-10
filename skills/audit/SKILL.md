---
name: audit
description: "Adversarial auditor that verifies specs, plans, code, and generated content against standards, including spec fidelity, plan coherence, drift detection, cross-validation of verification results, and independent re-verification of deliverables modified in response to audit findings. Audits are not optional — dispatch is MANDATORY."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Overview

Audit via clean-room sub-agents. Each audit task is a self-contained procedure dispatched to a clean-room sub-agent via `task(subagent_type="general")`. Auditors write YAML verdicts to disk, return frugal contracts. The orchestrator dispatches via `skill()` + `task()` — it does NOT read task files.

Spec-audit now validates analytical artifacts in addition to structural spec content. The 7 analytical artifacts are: blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, and testability assessment. Missing or stale analytical artifacts produce a BLOCK; the orchestrator routes to `writing-plans --task backfill` with `mode: retroactive` for auto-generation.

## Persona

Audit dispatcher. Routes each audit task to a clean-room sub-agent via `task(subagent_type="general")`. Each task file is self-contained with its own procedure, entry criteria, and exit criteria. An orchestrator that performs audit analysis inline instead of dispatching to a sub-agent has produced a self-review, not an independent audit — every finding carries the orchestrator's preloaded bias, and the audit separation that makes audits reliable is lost from the first byte. Professional auditors dispatch to sub-agents. Inlining means the audit was never independent.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 5. **Analytical artifact validation required before audit tasks.** Spec-audit requires all 7 analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment). Concern-separation requires concern-map. Plan-fidelity requires interface-compatibility. Verification-audit requires code-path-inventory. Cross-validate requires cross-cutting-matrix. Coherence-maintenance requires state-analysis. Test-quality-audit requires testability-assessment. Three artifact-missing scenarios are distinguished by where the detection occurs:

   - **(a) Missing at orchestration level** — orchestrator detects missing artifacts during pre-audit readiness check. Route to retroactive generation: dispatch `writing-plans --task backfill` with `mode: retroactive` context. The backfill task generates missing artifacts from the spec body.
   - **(b) Missing discovered by sub-agent** — sub-agent detects missing artifacts during audit execution. Return `REMEDIATION_REQUIRED` with `remediation_action` specifying backfill dispatch and `remediation_context` containing `{issue_number, project_root, mode: retroactive}`. The orchestrator inspects `remediation_action`, dispatches backfill, then re-dispatches the sub-agent.
   - **(c) Stale artifacts** — artifacts exist but their content is outdated relative to the current spec. Delete stale artifact files from `{project_root}/{path}/.issues/{N}/artifacts/`. Then route to retroactive generation: dispatch `writing-plans --task backfill` with `mode: retroactive` context. The backfill task generates fresh artifacts from the current spec body.

## Sub-Agent Result Contract Schema

All sub-agents dispatched from this skill MUST return a result contract with the following structure:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` / `REMEDIATION_REQUIRED` | Execution outcome |
| `finding_summary` | Yes | string | 1-3 sentence routing-significant summary |
| `artifact_path` | Yes | string | Path to full evidence on disk |
| `blocker_reason` | If BLOCKED | string | Why blocked |
| `remediation_action` | If REMEDIATION_REQUIRED | string | The action the orchestrator must take to resolve the issue |
| `remediation_context` | If REMEDIATION_REQUIRED | dict | Context data needed to execute the remediation action (paths, parameters, etc.) |

**`REMEDIATION_REQUIRED`** means the sub-agent found a problem that is not a simple blocker — it is a solvable issue with a defined remediation path. The orchestrator MUST inspect `remediation_action` and `remediation_context`, execute the remediation, then re-dispatch the sub-agent. Unlike BLOCKED (which halts the pipeline), REMEDIATION_REQUIRED carries a forward path to resolution.

## Mandatory Remediation Procedure for Audit FAIL

When any audit produces a FAIL verdict, the following remediation procedure MUST be followed before the deliverable advances to the next pipeline stage:

1. **Diagnose** — Identify which SCs failed and why. Record the root cause in the audit verdict.
2. **Remediate** — Fix the deliverable to address the failing SCs (add missing content, generate missing artifacts, correct wording).
3. **Re-audit** — Re-run the audit with the revised deliverable. All previously failing SCs must now PASS.
4. **Escalate** — If the FAIL cannot be remediated (e.g., the deliverable's core design is structurally unsound, or required analytical artifacts cannot be generated without developer input), escalate to the developer with: the specific SC(s) that failed, the root cause, what the developer must do to resolve, and the recommended action.
5. **Never proceed past FAIL** — A deliverable with any unremediated FAIL must NOT advance to the next pipeline stage. The audit verdict is the gate, not a suggestion.

## Workflows

The orchestrator follows the steps below step-by-step, in order. Each step is a clean-room `task()` dispatch (or an inline orchestrator action where marked). The `Execution mode` sub-bullet on every step makes the inline-vs-dispatch decision explicit: `sub-agent dispatch` means the orchestrator dispatches a clean-room sub-agent via `task()`; `inline` means the orchestrator performs the action in its own context. The orchestrator waits for each result contract before dispatching the next step.

The orchestrator dispatches each audit as a 4-step DiMo chain — one `task()` call per role, in sequence (Investigator → Validator → Evaluator → Arbiter). Each role is a clean-room sub-agent dispatched via `task(subagent_type="general")`. The orchestrator reads the task cards it dispatches via the `Read [Text](path)` pattern; it does NOT execute audit analysis inline.

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every audit role MUST be dispatched to a clean-room sub-agent via `task()`. Reading a role task file and executing its steps inline in the orchestrator context means every quality gate in that role was silently bypassed.

**Default dispatch routing:** Bare "audit #NNN" or "run audit" routes to `verification-audit` (post-implementation). "Spec audit #NNN" routes to `spec-audit` (pre-implementation). Other audits have explicit workflow variants below.

### Run an audit

- [ ] 1. **Investigator** — Dispatch `task(..., prompt: "Follow the instructions in [audit/tasks/<task>-investigator.md](.opencode/skills/audit/tasks/<task>-investigator.md)")`
  - **Context passed:** `{spec_local_dir, plan_local_dir, artifact_evidence_dir, spec_issue_number, github.owner, github.repo, guideline_paths, document_section, source_data_paths, target_files, file_paths_changed, vbc_artifact_path, failure_description, pr_number, blast_radius_path, concern_map_path, code_path_inventory_path, cross_cutting_matrix_path, interface_compatibility_path, state_analysis_path, testability_assessment_path}`
  - **Returns:** `{status, artifact_path, finding_summary}` — writes `evidence.yaml` with raw evidence and initial findings
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **Validator** — Dispatch `task(..., prompt: "Follow the instructions in [audit/tasks/<task>-validator.md](.opencode/skills/audit/tasks/<task>-validator.md)")`
  - **Context passed:** `{spec_local_dir, plan_local_dir, artifact_evidence_dir, spec_issue_number, github.owner, github.repo, guideline_paths, document_section, source_data_paths, target_files, file_paths_changed, vbc_artifact_path, failure_description, pr_number, blast_radius_path, concern_map_path, code_path_inventory_path, cross_cutting_matrix_path, interface_compatibility_path, state_analysis_path, testability_assessment_path}`
  - **Returns:** `{status, artifact_path, finding_summary}` — reads `evidence.yaml`, writes `reasoning.yaml` with validated evidence
  - **Execution mode:** sub-agent dispatch

- [ ] 3. **Evaluator** — Dispatch `task(..., prompt: "Follow the instructions in [audit/tasks/<task>-evaluator.md](.opencode/skills/audit/tasks/<task>-evaluator.md)")`
  - **Context passed:** `{spec_local_dir, plan_local_dir, artifact_evidence_dir, spec_issue_number, github.owner, github.repo, guideline_paths, document_section, source_data_paths, target_files, file_paths_changed, vbc_artifact_path, failure_description, pr_number, blast_radius_path, concern_map_path, code_path_inventory_path, cross_cutting_matrix_path, interface_compatibility_path, state_analysis_path, testability_assessment_path}`
  - **Returns:** `{status, artifact_path, finding_summary}` — reads `evidence.yaml` + `reasoning.yaml`, writes `verdict.yaml` with per-criterion PASS/FAIL
  - **Execution mode:** sub-agent dispatch

- [ ] 4. **Arbiter** — Dispatch `task(..., prompt: "Follow the instructions in [audit/tasks/<task>-arbiter.md](.opencode/skills/audit/tasks/<task>-arbiter.md)")`
  - **Context passed:** `{spec_local_dir, plan_local_dir, artifact_evidence_dir, spec_issue_number, github.owner, github.repo, guideline_paths, document_section, source_data_paths, target_files, file_paths_changed, vbc_artifact_path, failure_description, pr_number, blast_radius_path, concern_map_path, code_path_inventory_path, cross_cutting_matrix_path, interface_compatibility_path, state_analysis_path, testability_assessment_path}`
  - **Returns:** `{status, artifact_path, finding_summary}` — reads all artifacts, writes `judgment.yaml` with final judgment and `next_step`
  - **Execution mode:** sub-agent dispatch

Artifact directory: `./tmp/{issue-N}/artifacts/{task-name}/`

No audit dispatches to a single monolithic task file. The orchestrator dispatches 4 sequential `task()` calls, one per DiMo role. Dispatch contracts carry `spec_local_dir` and `artifact_evidence_dir`. Auditors independently discover SCs and evidence from these directories; the orchestrator does NOT read task files for execution.


### Audit Auto-Fix Exemption

Non-substantive GitHub Issue body formatting fixes found during deliberately-invoked audits are exempt from authorization per `approval-gate-008`. Conditional fixes still require separate authorization per `approval-gate-009`.

### [critical-rules-XXX] Posting Spec-Audit Findings as Issue Comments

**⚠️ Posting spec-audit findings as GitHub comments is FORBIDDEN.**

Audit findings from spec-auditor are internal agent guidance — equivalent to linter output. They must be posted to chat only.

- 🚫 FORBIDDEN: Posting audit findings (spec audits, plan fidelity checks, cross-validate results) as GitHub Issue comments
- 🚫 FORBIDDEN: Treating audit output as stakeholder-facing content
- ✅ REQUIRED: Audit findings go to chat only. Spec revisions (not audit results) go to issue comments when substantive.


### [critical-rules-016] Auditor Skills Enforcement
Professional engineers subject every deliverable to independent audit — amateurs ship unverified work. Read [audit skill](skills/audit/SKILL.md). Binary PASS/FAIL classification (auto-fix as remediation action only).


### [critical-rules-046] Mechanical-Only Audit Without Semantic and Conflict Exploration
Running an audit that only checks mechanical patterns means you are looking for typos when the building is on fire. Professional auditors probe semantic completeness and inter-rule conflicts. Amateurs count violations without understanding them.


### [critical-rules-accountability-ownership] Accountability/Remediation Ownership Model

ALL failures are agent-owned. Remediation is the default action. Escalation is only permitted after verified remediation failure. The following 8 principles govern agent accountability:

1. **Audit fail is a fail** — no exceptions, no reclassification, no soft-passing
2. **Bad prompt is on the agent** — the agent owns prompt quality; a poorly specified prompt is the agent's defect to remediate
3. **Defective spec/plan is on the agent** — the agent produces correct artifacts or remediates them; defective upstream artifacts are not an excuse for downstream failures
4. **Bad/incomplete implementation is on the agent** — the agent owns implementation quality; incomplete or incorrect output must be remediated, not flagged for someone else
5. **Missing text artifacts is a fail** — the agent produces complete deliverables; absent preamble, missing documentation, or incomplete issue bodies are agent-owned defects
6. **Skipped functional/behavioral testing is a fail** — no exceptions, no excuses; the agent runs and passes behavioral tests before claiming completion
7. **Remediate autonomously, never escalate** — escalation is only for dire circumstances (infrastructure failure, model crash, credentials missing); skipping remediation is not a valid choice
8. **No "pre-existing failure" rationalization** — test infrastructure is part of the ship condition. An agent MUST NOT use "pre-existing failure", "already broken before my change", "baseline failure", or any equivalent rationalization to justify proceeding past a test failure, verification mismatch, or pipeline gate FAIL. The agent owns the pipeline state at entry; any failure present at entry must be remediated before proceeding.

All failures are agent-owned. Remediation is the default action. Escalation is only permitted after verified remediation failure — never as a first response, never as a shortcut.


