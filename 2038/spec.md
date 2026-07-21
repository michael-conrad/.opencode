---
title: "SPEC-FIX: 28 task cards referenced in Trigger Dispatch Tables are missing from tasks/ directories"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2038
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order.

## Problem

28 task cards are referenced in SKILL.md Trigger Dispatch Tables but do not exist as `.md` files in the corresponding `tasks/` directories. When the orchestrator dispatches these tasks via `task()`, the sub-agent receives a reference to a non-existent file.

## Affected Skills and Missing Task Cards

| Skill | Missing Task Cards |
|-------|-------------------|
| `approval-gate-scope` | `spec-to-plan-cascade`, `approval-cascade`, `check-halt-boundary`, `apply-label`, `revision-revocation`, `bug-discovery-protocol` |
| `brainstorming` | `top-down-analysis`, `cross-scope` |
| `executing-plans` | `execute`, `tdd-cycle-enforcement` |
| `playwright-cli` | `browse`, `test` |
| `programming-principles` | `principles`, `check-limits`, `decompose` |
| `skill-creator` | `init`, `package`, `fragment-management` |
| `multimodal-dispatch` | `route` (files `dispatch.md` and `dispatch-multi.md` exist but no `route.md`) |
| `using-git-worktrees` | `verify-worktree` |
| `plan-creation-pipeline` | `plan-creation`, `completion` |
| `issue-operations-core` | `push-artifacts` |
| `writing-plans` | `create`, `update`, `retroactive`, `holistic-self-check` (no `tasks/` directory exists) |

## Root Cause

Trigger Dispatch Tables were written with task references before the corresponding task card files were created. The TDT defines what the orchestrator dispatches, but the task card (what the sub-agent reads) was never written.

## Fix

For each missing task card, create a `.md` file in the skill's `tasks/` directory with:
- Entry criteria
- Inline-only steps (no dispatch markers)
- Exit criteria

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 28 missing task cards exist as `.md` files | `string` | Verify each file exists |
| SC-2 | Each new task card has entry criteria, inline steps, exit criteria | `string` | Sample audit of 5 new task cards |
| SC-3 | No TDT references a non-existent task card | `string` | Cross-reference all TDTs against filesystem |

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
