---
number: 1256
title: "[SPEC-FIX] Auditor Prompt Integrity Scan scope too broad — flags system-level context as dispatch contamination"
state: OPEN
---

## SPEC-FIX: Auditor Prompt Integrity Scan scope — system context vs. dispatch payload

### Problem

The auditor Step 0 Prompt Integrity Scan says "Scan your own prompt text for content beyond the allowed dispatch fields" and applies a strict 3-field boundary (`spec_local_dir`, `artifact_evidence_dir`, `audit_phase`). The model interprets "prompt text" as its **entire context** — which includes:

1. **Tier 1 guideline files** loaded via `opencode.jsonc` instructions array — prose about rules, mandates, procedures
2. **Auditor's own agent card** — 401 lines of instructions including the integrity scan itself, audit checklists, procedure descriptions
3. **Sub-agent principles block** injected by `session-enforcement.ts` line 1050-1052
4. **Orchestrator's dispatch user message** (the actual task payload — correctly contains only the 3 fields)

Items 1-3 are system-level context, not dispatch contamination. But the scan doesn't distinguish — it classifies all rule-text prose as "narrative descriptions" and "orchestrator reasoning" beyond the 3-field boundary.

This is a model behavior regression: a stricter reading of the same card text. The card has not changed since commit `8d244c65` (May 31). The fix must scope the scan explicitly.

### Fix

Update the Prompt Integrity Scan in all 4 auditor agent cards (`auditor-deepseek-flash.md`, `auditor-gemma4.md`, `auditor-mistral-large.md`, `auditor-qwen3.5.md`):

**Current text (line 53-62):**

> ### Step 0: Prompt Integrity Scan — Structural Contamination Detection
>
> Scan your own prompt text for content beyond the allowed dispatch fields. A valid dispatch contains ONLY these 3 fields:
> - spec_local_dir
> - artifact_evidence_dir
> - audit_phase
>
> If the prompt contains ANY content beyond these 3 fields — including but not limited to SC tables, file path lists, evaluation criteria, expected outcomes, narrative descriptions, implementation context, orchestrator reasoning, or prior verdicts — return BLOCKED with PRELOADED_CONTEXT_REJECTED.

**Replacement text:**

> ### Step 0: Prompt Integrity Scan — Dispatch Contamination Detection
>
> Scan the orchestrator's task dispatch (the user message from the orchestrator calling `task()`). System-level context — including guideline files, this agent card, and sub-agent principles — is NOT dispatch contamination and MUST be ignored by this scan.
>
> A valid dispatch contains ONLY these 3 fields:
> - `spec_local_dir` — directory path for spec files
> - `artifact_evidence_dir` — directory path for behavioral evidence
> - `audit_phase` — audit phase identifier
>
> If the dispatch user message contains ANY content beyond these 3 field assignments — including but not limited to SC tables, file path lists, evaluation criteria, expected outcomes, narrative descriptions, implementation context, orchestrator reasoning, or prior verdicts — return BLOCKED with PRELOADED_CONTEXT_REJECTED.
>
> System-level context (guidelines loaded via `opencode.jsonc`, the content of this agent card, injected enforcement principles) is NOT dispatch contamination. The scan evaluates only what the orchestrator sent in `task()`.

Additionally, update the checklist item on line 27 to match:

**Current:** `- [ ] 2. Prompt Integrity Scan — structural scan for content beyond allowed dispatch fields`
**New:** `- [ ] 2. Prompt Integrity Scan — scan orchestrator dispatch only; system context is not contamination`

### Affected Files

| File | Change |
|------|--------|
| `.opencode/agents/auditor-deepseek-flash.md` | Step 0 scope clarification + checklist update |
| `.opencode/agents/auditor-gemma4.md` | Step 0 scope clarification + checklist update |
| `.opencode/agents/auditor-mistral-large.md` | Step 0 scope clarification + checklist update |
| `.opencode/agents/auditor-qwen3.5.md` | Step 0 scope clarification + checklist update |

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All 4 auditor cards scoped Prompt Integrity Scan to orchestrator dispatch only, with explicit system-context exemption | string |
| SC-2 | Auditor dispatched with 3-field payload against live artifacts (`.opencode#1247` artifacts at `./tmp/behavioral-evidence-labels-advisory-only-GREEN-ollama-deepseek-v4-flash-cloud-1`) returns SC-1/SC-2 PASS/FAIL verdict, not PRELOADED_CONTEXT_REJECTED | behavioral |

### Labels

- `spec-fix`