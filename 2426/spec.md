---
title: "[SPEC] Reconcile commit co-author trailer and squash-to-one-commit rules"
remote_issue: 2426
remote_url: https://github.com/michael-conrad/.opencode/issues/2426
promoted_at: 2026-08-31T22:50:00Z
labels:
  - needs-approval
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2426/

## Problem

The skill deck contains contradictory rules about (1) when co-author trailers are required vs forbidden on commits, and (2) how many commits a PR/branch should have (ONE clean commit vs one-per-item vs one-per-issue). These contradictions cause agents to enter deliberation loops during PR creation and to skip the squash-to-one-commit-per-issue step.

## Scope

- Reconcile co-author trailer requirements (required vs forbidden) across the skill deck
- Reconcile commit-count rules (ONE clean commit vs one-per-item vs one-per-issue)
- Establish the canonical rule: exactly 1 squashed commit per issue ticket, with proper dual co-author trailers (AI + human) on the squashed commit
- **Out of scope:** Implementation of the reconciliation — this issue is a placeholder to bind the issue number so the spec-creation analyze step can run.

## Approach

This issue is a placeholder to bind the issue number. The full spec will be written via the spec-creation pipeline after this issue exists. The spec-creation analyze step will inventory the contradictory rules, classify them, and produce a reconciliation spec.

## Impact

- **Risk:** Contradictory rules persist during analysis — mitigated by the placeholder binding the issue number now.
- **Dependency:** spec-creation pipeline (analyze step) runs after this issue exists.
- **Call to action:** Approve this placeholder so the spec-creation analyze step can proceed.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
