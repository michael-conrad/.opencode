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

---

## Exit Criteria

- [ ] C1. `critical-rules-PR-ORG` exists in `.opencode/guidelines/000-critical-rules.md` with the "Stacked PR Is the Only Valid Organization" bright-line text (SC-1)
- [ ] C2. `stacked-pr-organization.sh` exists under `.opencode/tests-v2/behaviors/` and dispatches a real-domain prompt via `opencode run` (SC-2)
- [ ] C3. The behavioral test asserts exactly one feature branch and one PR (SC-2)
- [ ] C4. `.opencode/skills/git-workflow-pr/SKILL.md` line 74 cross-reference resolves to the actual rule location (SC-3)
- [ ] C5. All three SCs verified with evidence matching their declared evidence types (SC-1 string, SC-2 behavioral, SC-3 string)
