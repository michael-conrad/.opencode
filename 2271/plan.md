---
plan_schema_version: "1.0"
issue: 2271
title: "Enforce stacked-PR organization (canonical rule + behavioral test + cross-reference fix)"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2271 — Enforce Stacked-PR Organization

**Goal:** Restore the stacked-PR enforcement gate by promoting `critical-rules-PR-ORG` to the canonical critical-rules location, adding the `stacked-pr-organization.sh` behavioral enforcement test, and fixing the dangling cross-reference.

**Architecture:** Three independent-but-sequenced changes. Phase 1 promotes the existing rule text from the skill card into `000-critical-rules.md` (the canonical location). Phase 2 adds the behavioral enforcement test that forces the single-scope/multi-issue scenario and asserts one branch + one PR. Phase 3 fixes the cross-reference in the skill card so it resolves to the now-existing rule. Phase 1 is a prerequisite for both Phase 2 (the test asserts the rule exists) and Phase 3 (the reference must point to a real rule).

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/tests-v2/behaviors/stacked-pr-organization.sh` (new)
- `.opencode/skills/git-workflow-pr/SKILL.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Promote critical-rules-PR-ORG | `test-driven-development` | `red` | `.opencode/guidelines/000-critical-rules.md` | SC-1 | — |
| 2 — Add behavioral enforcement test | `test-driven-development` | `green` | `.opencode/tests-v2/behaviors/stacked-pr-organization.sh` | SC-2 | 1 |
| 3 — Fix cross-reference | `test-driven-development` | `green` | `.opencode/skills/git-workflow-pr/SKILL.md` | SC-3 | 1 |

---

## Phase Details

### Phase 1 — Promote critical-rules-PR-ORG to canonical location

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/000-critical-rules.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
rule_id: critical-rules-PR-ORG
rule_title: "Stacked PR Is the Only Valid Organization"
source_text: ".opencode/skills/git-workflow-pr/SKILL.md line 89 (rule body) and lines 95-99 (bright-line companion)"
target_file: .opencode/guidelines/000-critical-rules.md
sc_ids: [SC-1]
```

**Procedure:**
- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting `critical-rules-PR-ORG` exists in `.opencode/guidelines/000-critical-rules.md` with the "Stacked PR Is the Only Valid Organization" bright-line text. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Promote the rule body (SKILL.md line 89) and bright-line companion (lines 95-99) into `.opencode/guidelines/000-critical-rules.md` at the canonical location. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify the promoted rule text matches the source verbatim and the enforcement test passes. **→ SC-1**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the rule promotion and its enforcement test together as one atomic slice.

### Phase 2 — Add behavioral enforcement test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/tests-v2/behaviors/stacked-pr-organization.sh` |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
test_file: .opencode/tests-v2/behaviors/stacked-pr-organization.sh
fixture_spec: .opencode/tests-v2/behaviors/fixtures/issues/100-stacked-branch-for-pr/spec.md
fixture_sc: SC-4
harness: with-test-home
assertion: exactly one feature branch and one PR (stacked commits, one per issue)
sc_ids: [SC-2]
```

**Procedure:**
- [ ] 5. **RED (**sub-agent**).** Write the failing `stacked-pr-organization.sh` behavioral test that dispatches a real-domain prompt via `opencode run` through `with-test-home`, forcing the single-scope/multi-issue scenario. **→ SC-2**
- [ ] 6. **GREEN (**sub-agent**).** Implement the test to assert exactly one feature branch and one PR (stacked commits, one per issue) using the stderr-based assertion helpers. **→ SC-2**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Run the behavioral test and verify it passes against the real model, confirming the single-branch/single-PR assertion. **→ SC-2**
- [ ] 8. **Checkpoint commit (**inline**).** Commit the behavioral test and its implementation together as one atomic slice.

### Phase 3 — Fix cross-reference

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/git-workflow-pr/SKILL.md` |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
reference_line: ".opencode/skills/git-workflow-pr/SKILL.md line 74"
reference_text: "Read [critical-rules-PR-ORG](guidelines/000-critical-rules.md) for stacked PR strategy"
target_rule: critical-rules-PR-ORG in .opencode/guidelines/000-critical-rules.md
sc_ids: [SC-3]
```

**Procedure:**
- [ ] 9. **RED (**sub-agent**).** Write a failing enforcement test asserting the cross-reference at `.opencode/skills/git-workflow-pr/SKILL.md` line 74 resolves to the actual `critical-rules-PR-ORG` rule location. **→ SC-3**
- [ ] 10. **GREEN (**sub-agent**).** Fix the cross-reference so it points to the now-existing rule in `.opencode/guidelines/000-critical-rules.md`. **→ SC-3**
- [ ] 11. **GREEN doublecheck (**clean-room**).** Verify the reference resolves to the real rule and the enforcement test passes. **→ SC-3**
- [ ] 12. **Checkpoint commit (**inline**).** Commit the cross-reference fix and its enforcement test together as one atomic slice.

---

## Exit Criteria

- [ ] C1. `critical-rules-PR-ORG` exists in `.opencode/guidelines/000-critical-rules.md` with the "Stacked PR Is the Only Valid Organization" bright-line text (SC-1)
- [ ] C2. `stacked-pr-organization.sh` exists under `.opencode/tests-v2/behaviors/` and dispatches a real-domain prompt via `opencode run` (SC-2)
- [ ] C3. The behavioral test asserts exactly one feature branch and one PR (SC-2)
- [ ] C4. `.opencode/skills/git-workflow-pr/SKILL.md` line 74 cross-reference resolves to the actual rule location (SC-3)
- [ ] C5. All three SCs verified with evidence matching their declared evidence types (SC-1 string, SC-2 behavioral, SC-3 string)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-11T18:57:00Z | plan_created | Plan file: `.opencode/.issues/2271/plan.md`, phase count: 3 |
