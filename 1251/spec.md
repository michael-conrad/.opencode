---
number: 1251
title: "[SPEC-FIX] Adversarial-audit: 2-retry PRELOADED_CONTEXT_REJECTED exhaustion must HALT, not fall back to general sub-agent"
state: OPEN
---

## SPEC-FIX: Adversarial-audit PRELOADED_CONTEXT_REJECTED exhaustion protocol

### Problem

During `.opencode#1247` adversarial audit, both auditor-1 retries returned `PRELOADED_CONTEXT_REJECTED` due to session-enforcement.ts system-level context injection. The orchestrator:

1. Failed on retry 2 → instead of HALT, fell back to `general` sub-agent with semantic evaluation context → **critical-rules-043** (inline fallback)
2. `general` sub-agent returned empty → accepted without post-flight → **critical-rules-032** (no post-flight check)
3. Proceeded past the FAIL → **critical-rules-hard-fail** (FAIL bypassed)

### Root Cause

Auditor Prompt Integrity Scan correctly rejects all content beyond the 3 allowed dispatch fields (`spec_local_dir`, `artifact_evidence_dir`, `audit_phase`). Session-enforcement.ts injects enforcement blocks and critical-rules mandates into every sub-agent's system prompt. The auditor sees this as contamination and returns `PRELOADED_CONTEXT_REJECTED`.

The implementation-pipeline and adversarial-audit SKILL.md do not document what happens when 2 auditor-family retries fail with `PRELOADED_CONTEXT_REJECTED`. The default behavior (inline fallback to `general` sub-agent) is incorrect because:

- **FAIL is a hard gate** — no bypass path, no alternative evaluator, no workaround
- **Remediation must be attempted** — but session-enforcement.ts is system-level and cannot be fixed by the orchestrator
- **No escape hatch means the orchestrator implicitly creates one** — the spec must pre-define the correct response

### Fix

Document in both `implementation-pipeline/SKILL.md` and `adversarial-audit/SKILL.md` the correct behavior when 2 auditor-family retries fail with `PRELOADED_CONTEXT_REJECTED`:

1. Log double-rejection to lifecycle manifest with `severity: error` and `resolution: UNRESOLVED (system context contamination)`
2. Report BLOCKED to developer with: auditor rejection evidence, root cause (session-enforcement system context), and remediation options

### Where to Apply the Fix

| File | Change |
|------|--------|
| `.opencode/skills/implementation-pipeline/SKILL.md` adversarial-audit step | After auditor-family dispatch section, add: "On double PRELOADED_CONTEXT_REJECTED: HALT. Report BLOCKED. No fallback to general sub-agent." |
| `.opencode/skills/adversarial-audit/SKILL.md` | Add: "Auditor PRELOADED_CONTEXT_REJECTED at 2-retry exhaustion → BLOCKED, no fallback evaluator path exists" |

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | implementation-pipeline SKILL.md documents: adversarial-audit step HALTs on double PRELOADED_CONTEXT_REJECTED with no general sub-agent fallback | string |
| SC-2 | adversarial-audit SKILL.md documents: PRELOADED_CONTEXT_REJECTED at 2-retry ceiling is BLOCKED, no fallback evaluator | string |

### Labels

- `spec-fix`