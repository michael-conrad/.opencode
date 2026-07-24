---
remote_issue: 2026
remote_url: "https://github.com/michael-conrad/.opencode/issues/2026"
last_sync: "2026-07-20T14:44:35Z"
source: github
---

> **Full spec and artifacts: [`.issues/2025/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2025)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2025/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

The `spec-creation` pipeline (defined in `spec-creation/SKILL.md`) references two sub-task steps — `research-card-consultation` (step 4) and `interdependency-check` (step 20) — that have no corresponding task card files in `spec-creation-validation/tasks/`. The pipeline dispatches these steps via `task()` but the sub-agents have no task file to read, producing empty or default behavior.

## Root Cause

The task card files were never created during the initial spec-creation-validation skill authoring. The 9 existing task files do not include these two.

## Objectives

Create the two missing task card files so the pipeline dispatches resolve to real task files.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `research-card-consultation.md` exists with Entry Criteria, Procedure, Exit Criteria, Result Contract | string |
| SC-2 | `interdependency-check.md` exists with same structure | string |
| SC-3 | Both match SKILL.md Step-by-Step Contract Table | string |
| SC-4 | Neither contains `task()` or `skill()` calls | string |
| SC-5 | Behavioral enforcement test exists verifying correct pipeline dispatch | behavioral |
| SC-6 | No SC may be weakened, deferred, or reclassified | behavioral |

After this spec is approved, invoke `writing-plans` to create `.issues/2025/plan.md` before implementation begins.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)