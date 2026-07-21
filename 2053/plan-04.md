# Phase 4: Add expected-determination rejection to evaluator/arbiter files

**SCs:** SC-7
**Files:** All `*-evaluator.md` files + `cross-validate.md`

## Steps

### 4.1 Add expected-determination rejection to all evaluator files
To each `*-evaluator.md` file, add in the Dispatch Contract section (after PRELOADED_CONTEXT_REJECTED block):

```
**Expected-determination rejection:** If the orchestrator includes an expected PASS/FAIL determination or expected verdict in the dispatch context, return:
```yaml
status: BLOCKED
reason: EXPECTED_DETERMINATION_REJECTED
message: "Expected determination detected. Dispatch without pre-judgment."
```
```

Files:
- verification-audit-evaluator.md
- spec-audit-evaluator.md
- plan-fidelity-evaluator.md
- concern-separation-evaluator.md
- coherence-extraction-evaluator.md
- coherence-maintenance-evaluator.md
- drift-detection-evaluator.md
- guideline-audit-evaluator.md
- test-quality-audit-evaluator.md
- content-audit-evaluator.md

### 4.2 Add expected-determination rejection to cross-validate.md (arbiter)
Same pattern as 4.1.

## Exit Criteria
- [ ] All 10 evaluator files have expected-determination rejection in Dispatch Contract
- [ ] `cross-validate.md` has expected-determination rejection in Dispatch Contract
