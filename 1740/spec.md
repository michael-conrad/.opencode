<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The gap-fill cascade dispatcher (`gap-fill-cascade.md`) lives at `tasks/gap-fill-cascade.md` (top level) but is NOT registered in the approval-gate SKILL.md Trigger Dispatch Table. When an agent receives `for_pr` scope, it loads `approval-gate` skill, finds no dispatch entry for `gap-fill-cascade`, and reads the task file inline in the orchestrator instead of dispatching to a sub-agent via `task()`. This violates the DISPATCH_GATE protocol.

Additionally, the behavioral test evaluation pipeline has a gap: after `behavior_run` produces artifacts, no clean-room evaluation sub-agent is dispatched to read the artifacts and produce a PASS/FAIL verdict. The orchestrator reports "Artifacts generated" as PASS, which is EVIDENCE_TYPE_MISMATCH per `080-code-standards.md` §Rule 6.

## Changes

1. **Move** `gap-fill-cascade.md` from `tasks/gap-fill-cascade.md` to `tasks/verify-authorization/gap-fill-cascade/` as per-scope checklist files (`for-pr.md`, `for-implementation.md`, `for-plan.md`) — the verify-authorization sub-agent dispatches it internally, preventing orchestrator inline read
2. **Remove** top-level `gap-fill-cascade` entry from approval-gate SKILL.md Trigger Dispatch Table
3. **Fix** behavioral test prompt to use fixture issue with pre-existing spec+plan instead of the spec being implemented

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | gap-fill-cascade.md moved under verify-authorization/ | string | File exists check at `tasks/verify-authorization/gap-fill-cascade/` |
| SC-2 | No top-level dispatch entry in approval-gate SKILL.md Trigger Dispatch Table | string | grep for `gap-fill-cascade` in `approval-gate/SKILL.md` — no match |
| SC-3 | Behavioral test uses fixture issue with pre-existing spec+plan | behavioral | `opencode-cli run` with stderr assertion verifying fixture issue reference |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

Co-authored with AI: OpenCode (deepseek-v4-flash)