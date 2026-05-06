---
name: spec-auditor
description: Use when auditing a spec for quality, structure, or completeness. Triggers on: audit spec, review spec, spec quality, validate spec, check spec, audit issue, revisit spec, audit plan, audit runbook, audit SOP, audit checklist, audit document, content-aware audit.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: spec-auditor

## Overview

Content-aware audit orchestrator. Auto-detects document type, selects subtasks, classifies findings (auto-fix/conditional/flag-for-review), applies safe fixes directly, flags ambiguous findings.

## Persona

Content-Aware Audit Orchestrator. Focus: detect document type, select subtasks, auto-fix, flag, present executive summary.

**Audit Phase:** `spec` — This skill operates in the `spec` audit phase. When dispatched, receive `audit_phase: spec` in dispatch context.

## Tasks

| Task | Words |
|------|-------|
| `fresh-start` | ≈400 |
| `structure` | ≈400 |
| `content-quality` | ≈500 |
| `traceability` | ≈300 |
| `operational` | ≈300 |
| `fidelity` | ≈600 |
| `concerns` | ≈400 |
| `operational-flow` | ≈400 |
| `determinism` | ≈300 |
| `error-recovery` | ≈350 |
| `principles` | ≈350 |
| `ground-truth` | ≈500 |
| `sub-issue-fidelity` | ≈350 |
| `concern-coverage` | ≈350 |
| `prose-structure` | ≈250 |
| `decomposition` | ≈350 |
| `cross-spec-overlap` | ≈350 |
| `sc-precision` | ≈350 |
| `completion` | ≈200 |

## Invocation

`/skill spec-auditor --issue N` (full audit), `--file path`, `--url URL`, `--task <subtask>`, `--type <type>`. Input source mandatory (except overview). Types: spec, plan, process-flow, runbook, checklist, reference-doc.

## Operating Protocol

1. **Autodetection:** Content signals → type. Low confidence → confirm. None → error.
2. **Subtask selection:** Baseline + conditional per document type (task files contain per-type tables).
3. **Auto-fix:** Safe findings applied directly. Conditional after safety check. Flag-for-review reported only.
4. **Body-preservation:** Verify `len(new_body) >= 0.8 * len(original_body)` before any `github_issue_write(method=update)`.
5. **Executive summary** to chat after every audit.

## Sub-Agent Dispatch Audit

All subtasks dispatch via `task(subagent_type="general")` with `{ issue_number, github.owner, github.repo }`, excluding implementation context and agent memory. `fidelity` also receives plan issue number. `sub-issue-fidelity` and `concern-coverage` also receive sub-issue list. `pre-analysis` receives only `{ issue_number, task_description }` with zero file paths/line numbers. `completion` receives workflow state. No inline work—all tasks MUST dispatch sub-agents.

## Cross-References

Skills: `brainstorming`, `spec-creation`, `writing-plans`, `issue-review`, `programming-principles`, `verification-enforcement`, `multimodal-dispatch`, `verification`. Delegated from: `plan-fidelity-auditor`, `concern-separation-auditor`. Guidelines: `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: spec-auditor-001
    title: "AI agents creating/auditing specs MUST invoke spec-auditor"
    conditions:
      all:
        - "spec_created_or_audited == true"
        - "spec_auditor_invoked == false"
    actions:
      - HALT
    triggers: [spec-creation, issue-operations]
    source: "spec-auditor/SKILL.md §Mandatory Invocation"
