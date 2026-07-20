## Problem

The `cross-validate` task produces a `mandatory_remediation` field in every output artifact and result contract, even when `overall_verdict: PASS` and `all_criteria_pass: true`. This creates a contradictory signal: "Remit for mandatory remediation" appears alongside a clean PASS verdict, confusing downstream consumers (both human reviewers and orchestrators parsing the contract).

## Root Cause

Two hardcoded YAML template fragments in `.opencode/skills/audit/tasks/cross-validate.md` always include the `mandatory_remediation` field unconditionally:

**Location 1 — Line 355 (Findings YAML artifact template in Step 6.5):**
```yaml
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

**Location 2 — Line 378 (Result contract template in Step 7):**
```yaml
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

The `next_step` field already conveys routing: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL. The `mandatory_remediation` field is redundant with `next_step` and produces a contradiction when present on a clean PASS.

## Affected Scope

| File | Lines | Field | Occurrences |
|------|-------|-------|-------------|
| `.opencode/skills/audit/tasks/cross-validate.md` | 355, 378 | `mandatory_remediation` | 2 |

No other files in `.opencode/` reference `mandatory_remediation`. This is isolated to the cross-validate task.

## Fix Approach

Make the `mandatory_remediation` field conditional on `overall_verdict`:

1. **YAML artifact template (Step 6.5, ~line 355):** Only include `mandatory_remediation` when `overall_verdict == FAIL`. Omit the field entirely when PASS.
2. **Result contract template (Step 7, ~line 378):** Only include `mandatory_remediation` when `overall_verdict == FAIL`. Omit the field entirely when PASS.

Both locations should document the field as conditional: the field is present ONLY when there IS something to remediate. Clean PASS output contains no remediation signal.

## Affected Task File

`.opencode/skills/audit/tasks/cross-validate.md` — the `mandatory_remediation` field is a hardcoded unconditional string in the YAML output templates.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash-free)