# [SPEC-FIX] Cross-validate: context pollution checks + clean contract requirement

## Problem

Cross-validate receives pre-resolved `auditor_artifact_paths` from the orchestrator and computes consensus by reading the YAML verdicts from disk. It has no mechanism to validate that those artifacts:

1. Are from the **same audit run** (same issue number, same audit phase)
2. Contain **consistent criteria** (same SC IDs, same total_criteria count)
3. Are **parseable and self-consistent** (valid YAML, required fields present)
4. Are **not fabricated or stale** (file exists on disk, written within a reasonable time window)

During pipeline #884, the stale cross-validate artifact from the poisoned pipeline (phase-10/11/12) remained on disk alongside the fresh one. A cross-validate run that read the stale file would produce a consensus against the wrong auditor verdicts (5 SCs instead of 6, different auditor families). There was no gate to detect this contamination.

## Root Causes

1. **Cross-validate trusts input paths** — it reads whatever `auditor_artifact_paths` it receives without verifying the artifacts match the current audit context
2. **No self-consistency check** — cross-validate does not verify that both auditor artifacts reference the same issue number, same SC count, same audit phase
3. **No staleness check** — artifacts from prior pipeline runs remain on disk and are indistinguishable from current artifacts by filename alone

## Solution

### Part A: Cross-validate input validation gate

Add input validation steps at the START of cross-validate:

```
- [ ] X.1   Verify each auditor artifact file exists on disk and is parseable YAML
- [ ] X.2   Verify both artifacts reference same issue_number
- [ ] X.3   Verify both artifacts reference same audit_phase (verification/spec/plan/etc.)
- [ ] X.4   Verify both artifacts have same total_criteria count
- [ ] X.5   Verify both artifacts evaluate the same SC IDs (per_criterion[].criterion_id match)
- [ ] X.6   Verify both artifacts contain valid frugal contract fields (status, artifact_path, summary)
- [ ] X.7   If any check fails → return BLOCKED with CONTEXT_POLLUTION error
```

### Part B: Frugal contract requirement for cross-validate

Cross-validate itself must return a clean frugal contract as proof of completion:

```yaml
status: DONE | BLOCKED
artifact_path: "./tmp/artifacts/pipeline-{issue}-cross-validate-{STATUS}-{timestamp}.yaml"
summary: "<1-2 sentence summary>"
```

No narrative output. Cross-validate that returns narrative instead of contract is a FAIL.

### Part C: Staleness guard

Cross-validate MUST reject artifacts whose `generated_at` timestamp is older than the orchestrator's `pipeline_phase` start time or outside a reasonable window. If the artifact predates the current pipeline restart, it is stale and must be rejected.

## Affected Files

- `.opencode/skills/adversarial-audit/tasks/cross-validate.md` — add input validation steps + context pollution checks + staleness guard
- `.opencode/tools/solve` — optionally provide timestamp verification via state file

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Cross-validate receives auditor artifacts from different issue numbers → returns BLOCKED with CONTEXT_POLLUTION | behavioral | opencode-cli run with mismatched issue_number artifacts → stderr shows CONTEXT_POLLUTION |
| SC-2 | Cross-validate receives auditor artifacts with different SC counts (e.g., 5 vs 6) → returns BLOCKED with CONTEXT_POLLUTION | behavioral | opencode-cli run with mismatched total_criteria → stderr shows CONTEXT_POLLUTION |
| SC-3 | Cross-validate receives stale artifact from prior pipeline run → returns BLOCKED with STALE_ARTIFACT | behavioral | opencode-cli run with old artifact → stderr shows STALE_ARTIFACT |
| SC-4 | Cross-validate returns narrative text instead of frugal contract → orchestrator treats as FAIL and re-dispatches | behavioral | Cross-validate sub-agent returns narrative → orchestrator logs FAIL |
| SC-5 | cross-validate.md has context pollution checklist items X.1-X.7 | structural | grep for "CONTEXT_POLLUTION" in cross-validate.md returns >= 1 |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)