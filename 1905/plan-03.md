# Phase 3: Validate — Consistency & Test Suite

**Chain:** `phase_2` (depends on remediation complete)
**Phase dependency:** `phase_2__complete`
**Concern transition:** Remediation concerns complete → Validation concerns begin

## Step 10: Cross-skill format consistency validation

**Chain:** `step_9`
**RED:** Format consistency not verified
**Action:** Verify that all skill task files referencing spec format are internally consistent:

1. **Section order consistency:** All task files that reference spec sections use the same canonical order (Problem → Goals → Non-Goals → Proposed Changes → Scope of Work → Key Decisions → Success Criteria → Risk Callouts)
2. **Step numbering consistency:** All cross-references to spec-creation steps use the new numbering (7.1/7.2/7.3/7.4, not 7r/7a/7b/7c)
3. **Terminology consistency:** No remaining "Cards" heading references — all use "Scope of Work"
4. **Gate enforcement consistency:** All AI Agent Instructions enforcement is gate-level, not inline — verify no skill embeds an inline pre-implementation checklist

**Dispatch:** Sub-agent via `task()` — single validation pass across all modified files.
**Evidence:** `1905/validation/consistency-report.md`
**SC coverage:** SC-1, SC-2, SC-4, SC-5
**Verification:** All 4 consistency dimensions PASS.

## Step 11: Run `validate_skill_cards.py` and format checks

**Chain:** `step_10`
**RED:** `validate_skill_cards.py` has errors or format is inconsistent
**Action:**
1. Run `python .opencode/tools/skill-creator validate` (or equivalent validate command)
2. Run markdown format check: `uvx mdformat --check .opencode/skills/ .opencode/guidelines/`
3. Fix any formatting issues found
4. Re-run until clean

**Dispatch:** Sub-agent via `task()` — validation execution.
**Evidence:** `1905/validation/format-check-results.md`
**SC coverage:** SC-6
**Verification:** `validate_skill_cards.py` exits 0; `mdformat --check` exits 0.

## Step 12: Run behavioral enforcement test suite

**Chain:** `step_11`
**RED:** Behavioral test suite has failures
**Action:**
1. Run `bash .opencode/tests/with-test-home --clean-all` to clean stale test homes
2. Run scope-limited enforcement test: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run affected behavioral tests: `bash .opencode/tests/behaviors/<affected-scenario>.sh` for each behavioral test that was modified in Phase 2
4. Report any failures — diagnose and remediate

**Dispatch:** Sub-agent via `task()` — test execution agent.
**Evidence:** `1905/validation/test-results.md` with per-test PASS/FAIL and remediation notes.
**SC coverage:** SC-6
**Verification:** All behavioral tests PASS. Enforcement test suite PASS. No regressions introduced.

## Phase 3 Completion

After all validation steps pass:
- Update `1905/plan.md` STATUS to `COMPLETE`
- Commit all remaining changes: `git -C .opencode add -A && git -C .opencode commit -m ".opencode#1905: validation complete"`
- Report: all SCs verified PASS, all tests green, audit log and remediation log produced at `1905/` directory

**Lifecycle event:** Append to issue body: `**STATUS:** COMPLETE — Plan executed, audit + remediation + validation passed.`
