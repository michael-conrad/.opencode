# Phase 5: Add PRELOADED_CONTEXT_REJECTED to all task files

**SCs:** SC-8
**Files:** All `.opencode/skills/audit/tasks/*.md` files

## Steps

### 5.1 Add to verification-audit role files
Ensure `verification-audit-investigator.md`, `validator.md`, `evaluator.md`, `arbiter.md` have PRELOADED_CONTEXT_REJECTED in Dispatch Contract (added in Phase 2, verify presence).

### 5.2 Add to spec-audit files
All `spec-audit-*.md` files — ensure PRELOADED_CONTEXT_REJECTED block exists in Dispatch Contract.

### 5.3 Add to plan-audit files
All `plan-fidelity-*.md` files — ensure PRELOADED_CONTEXT_REJECTED block exists.

### 5.4 Add to code-audit files
All `coherence-*.md`, `drift-detection-*.md`, `guideline-audit-*.md`, `test-quality-audit-*.md`, `content-audit-*.md` files — ensure PRELOADED_CONTEXT_REJECTED block exists.

### 5.5 Add to cross-validate.md
Ensure `cross-validate.md` has PRELOADED_CONTEXT_REJECTED block.

### 5.6 Verify all task files
Run: `grep -r 'PRELOADED_CONTEXT_REJECTED' .opencode/skills/audit/tasks/*.md | wc -l`
Count should equal total task file count. Any file missing → fix.

## Exit Criteria
- [ ] All task files have PRELOADED_CONTEXT_REJECTED in Dispatch Contract
- [ ] grep confirms 100% coverage
