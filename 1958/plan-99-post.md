# Phase 4 — Post-Implementation

**Goal:** Run verification-before-completion, finishing checklist, review-prep, and behavioral verification.

**Concern:** Verification and readiness
**SCs:** All SCs
**Dependencies:** Phase 3 complete
**Dispatch:** `verification-before-completion`, `finishing-a-development-branch`, `git-workflow --task review-prep`

## Items

### Item 4.1 — Verification-before-completion

**Dispatch:** `verification-before-completion`

- [ ] Verify all SCs against live evidence:
  - [ ] SC-1: Inventory YAML exists at `.opencode/.issues/1958/data/cross-reference-inventory.yaml`
  - [ ] SC-2: `000-critical-rules.md` contains `Load [Text](path)`
  - [ ] SC-3: No `See [` or `Read [` in any SKILL.md
  - [ ] SC-4: No `See [` or `Read [` in any guideline
  - [ ] SC-5: No `§` in any SKILL.md
  - [ ] SC-6: No resolution table patterns in any SKILL.md
  - [ ] SC-7: No non-linked text references in any SKILL.md
  - [ ] SC-8: #1953 closed with `state_reason: not_planned`
  - [ ] SC-9: Comments exist on #1925 and #1926
- [ ] Run all behavioral enforcement tests — confirm all PASS
- [ ] Produce evidence artifacts at `.opencode/.issues/1958/data/verification/`

### Item 4.2 — Finishing checklist

**Dispatch:** `finishing-a-development-branch --task checklist`

- [ ] Verify all changes committed
- [ ] Verify no uncommitted changes
- [ ] Verify branch is up to date with trunk
- [ ] Verify all tests pass

### Item 4.3 — Review-prep

**Dispatch:** `git-workflow --task review-prep`

- [ ] Generate PR body with Summary/Outcome/Fixes structure
- [ ] Verify compare URL uses correct base branch
- [ ] Verify all SCs referenced in PR body

### Item 4.4 — Behavioral verification

- [ ] Run behavioral enforcement tests for all items in Phase 2
- [ ] Confirm all PASS
- [ ] If any FAIL: remediate and re-run per [critical-rules-hard-fail]

## Exit Criteria

- [ ] VbC PASS for all SCs
- [ ] Finishing checklist PASS
- [ ] Review-prep complete
- [ ] All behavioral tests PASS
- [ ] PR ready for creation
