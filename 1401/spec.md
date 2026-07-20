## Summary

The `verification-audit` task file's Step 0 Pre-Flight Validation Gate unconditionally requires `artifact_evidence_dir` to contain at least 2 YAML files. This blocks verification audits for specs that have only `structural`, `string`, and `semantic` SCs — which do not require behavioral evidence artifacts.

## Root Cause

`skills/adversarial-audit/tasks/verification-audit.md` Step 0, Check 2:

> Verify `artifact_evidence_dir` is present and contains at least 2 YAML files — if fewer than 2, return BLOCKED

This check fires unconditionally, regardless of the spec's SC evidence type declarations. For a spec like `.opencode#1390` whose SCs are `structural`, `structural`, `semantic`, `semantic`, `string`, `semantic` (zero behavioral SCs), the gate still blocks because no YAML evidence files exist.

## Impact

- Post-merge implementation audits of structural/string/semantic-only specs cannot proceed through the verification-audit pipeline
- Both cross-family auditors return BLOCKED with `INSUFFICIENT_ARTIFACTS` or `MISSING_EVIDENCE`
- The orchestrator must bypass the audit pipeline and verify SCs inline, which is a process-integrity violation per `000-critical-rules.md` §critical-rules-034

## Reproduction

1. Dispatch `verification-audit` for `.opencode#1390` (SCs: 2 structural, 3 semantic, 1 string — zero behavioral)
2. Both auditors return BLOCKED because `./tmp/audit-1390/` is empty
3. No valid path through the audit pipeline exists for this spec

## Fix Required

The pre-flight validation gate must be SC-type-aware:

- If the spec has **any behavioral SCs**: require `artifact_evidence_dir` with ≥2 YAML files (current behavior)
- If the spec has **zero behavioral SCs**: allow `artifact_evidence_dir` to be absent/empty, proceed with structural/string/semantic verification using codebase inspection only

## Evidence

- Spec #1390 SCs: SC-1 (structural), SC-2 (structural), SC-3 (semantic), SC-4 (semantic), SC-5 (string), SC-6 (semantic)
- Auditor 1 (deepseek-flash) returned: `status: BLOCKED, error: INSUFFICIENT_ARTIFACTS`
- Auditor 2 (qwen3.5) returned: `status: BLOCKED, error: MISSING_EVIDENCE`
- Manual verification confirmed all 6 SCs PASS via codebase inspection (grep + read + semantic judgment)

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)