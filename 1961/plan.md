# Implementation Plan — [#1961](https://github.com/michael-conrad/.opencode/issues/1961) — Rewrite SKILL.md Descriptions to Agent-Intent-Oriented Pattern

**Goal:** Rewrite all 60 SKILL.md `description` frontmatter fields from the "Dispatch when" pattern to a "Load via skill() when" agent-intent pattern, update all 5 tooling files in coordination, and write behavioral enforcement tests first.

**Architecture:** Content-only change to YAML frontmatter `description` fields across 60 SKILL.md files + 5 tooling files. No runtime code changes. Phased: test-first (Phase 0), tooling updates (Phase 1), description rewrites (Phase 2), verification (Phase 3).

**Files:**
- `.opencode/skills/*/SKILL.md` (60 files) — description rewrites
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` — validator update
- `.opencode/plugins/session-enforcement.ts` — comment update
- `.opencode/skills/skill-creator/scripts/init_skill.py` — template update
- `.opencode/skills/skill-creator/reference/routing-only-template.md` — docs update
- `.opencode/skills/skill-creator/reference/skill-card-spec.md` — docs update
- `.opencode/tests-v2/behaviors/skill-description-pattern.sh` — new behavioral test

**Dispatch:** All sub-agent work dispatched via `task()` from `implementation-pipeline` SKILL.md Trigger Dispatch Table.

## Blast Radius

- All 60 SKILL.md files in `.opencode/skills/*/` and `.opencode/skills/*/platforms/*/`
- 5 tooling/validation files in `.opencode/skills/skill-creator/` and `.opencode/plugins/`
- 1 new behavioral test file in `.opencode/tests-v2/behaviors/`
- No runtime code changes — descriptions are rendered verbatim by `session-enforcement.ts`
- No task card files (299 files) — they use `## Purpose` headings, not YAML frontmatter
- No guideline files (31 files) — they use `trigger_on` frontmatter

## Concern Map Reference

| Concern | Phase(s) |
|---------|----------|
| Test infrastructure readiness | Phase 0 |
| Validation/tooling alignment | Phase 1 |
| Description content transformation | Phase 2 |
| End-to-end verification | Phase 3 |

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time:** Each step in this plan is a discrete unit of work. Execute exactly one step at a time. Do not combine, batch, or parallelize steps. After each step, verify the step's exit criteria before proceeding to the next step.

> **Step status tracking:** Each step MUST be tracked with `todowrite` — status transitions from `pending` → `in_progress` → `completed`. Clear all items before HALT.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 0 | Behavioral Enforcement Test | Test infrastructure readiness | SC-9, SC-13 | None | 1-4 | `test-driven-development` |
| 1 | Tooling Updates | Validation/tooling alignment | SC-4, SC-5, SC-6, SC-7, SC-8 | Phase 0 | 5-9 | `implementation-pipeline` |
| 2 | Description Rewrites | Description content transformation | SC-1, SC-2, SC-3, SC-10, SC-11 | Phase 1 | 10-12 | `implementation-pipeline` |
| 3 | Verification | End-to-end verification | SC-12 | Phase 2 | 13-16 | `verification-before-completion` |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | All 60 SKILL.md descriptions use new agent-intent pattern | 2 | 10, 11 |
| SC-2 | No SKILL.md description starts with "Use when" | 2 | 10, 11, 12 |
| SC-3 | All descriptions include "User phrases:" suffix | 2 | 10, 11, 12 |
| SC-4 | `validate_skill_cards.py` passes on all 60 files with new pattern | 1, 3 | 5, 13 |
| SC-5 | `session-enforcement.ts` accepts new description pattern | 1, 3 | 6, 14 |
| SC-6 | `init_skill.py` template uses new description pattern | 1 | 7 |
| SC-7 | `routing-only-template.md` documents new description pattern | 1 | 8 |
| SC-8 | `skill-card-spec.md` documents new description pattern | 1 | 9 |
| SC-9 | Behavioral enforcement test verifies agent calls `skill()` for matching descriptions | 0, 3 | 1, 2, 3, 15 |
| SC-10 | No description exceeds 1024 characters | 2, 3 | 11, 12, 13 |
| SC-11 | All descriptions include mandatory keyword | 2, 3 | 11, 12, 13 |
| SC-12 | All 13 SC evidence types match declared types | 3 | 16 |
| SC-13 | RED state confirmed before implementation | 0 | 4 |

## Safety/Rollback Considerations

**Phase 0 — Safety/Rollback:**
- Destructive operations: None (new file creation only)
- Rollback plan: `rm .opencode/tests-v2/behaviors/skill-description-pattern.sh`
- Data loss risk: None

**Phase 1 — Safety/Rollback:**
- Destructive operations: Editing 5 existing tooling files
- Rollback plan: `git checkout -- <file>` for each modified file
- Data loss risk: Low (all changes are additive pattern additions, not removals)

**Phase 2 — Safety/Rollback:**
- Destructive operations: Rewriting 60 SKILL.md description fields
- Rollback plan: `git checkout -- .opencode/skills/*/SKILL.md` reverts all 60 files
- Data loss risk: Medium (bulk rewrite; git checkpoint before batch recommended)

**Phase 3 — Safety/Rollback:**
- Destructive operations: None (read-only verification)
- Rollback plan: N/A
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `.opencode/tests-v2/behaviors/` directory | ✅ | `ls .opencode/tests-v2/behaviors/` |
| 5 | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | ✅ | `ls` confirmed |
| 6 | `.opencode/plugins/session-enforcement.ts` | ✅ | `ls` confirmed |
| 7 | `.opencode/skills/skill-creator/scripts/init_skill.py` | ✅ | `ls` confirmed |
| 8 | `.opencode/skills/skill-creator/reference/routing-only-template.md` | ✅ | `ls` confirmed |
| 9 | `.opencode/skills/skill-creator/reference/skill-card-spec.md` | ✅ | `ls` confirmed |
| 10 | `.opencode/skills/*/SKILL.md` (60 files) | ✅ | `glob` confirmed 60 files |
| 13 | `validate_skill_cards.py` | ✅ | Same as step 5 |
| 14 | `session-enforcement.ts` | ✅ | Same as step 6 |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 60 SKILL.md files exist | `glob .opencode/skills/*/SKILL.md` | ✅ |
| 5 tooling files exist | `ls` on each path | ✅ |
| `validate_skill_cards.py` validates description patterns | `grep validate_req1` in source | ✅ |
| `session-enforcement.ts` renders descriptions verbatim | `grep loadSkillDescriptions` in source | ✅ |
| No runtime changes needed | `session-enforcement.ts` only reads name/description/slash | ✅ |

---

## Phase 0 — Behavioral Enforcement Test

**Concern:** Test infrastructure readiness — create the behavioral enforcement test and confirm RED state before any description changes.

**Files:** `.opencode/tests-v2/behaviors/skill-description-pattern.sh`

**SCs:** SC-9, SC-13

**Dependencies:** None

**Entry conditions:** Spec approved, feature branch created

**Exit conditions:** Behavioral test file exists, RED state confirmed (test fails before any description changes)

**Code Path Coverage:** N/A (new test file)

**Cross-Cutting SCs:** None

**Interface Boundaries:** None

**State Transitions:** `no_test → test_created → red_confirmed`

### Step-by-step

- [ ] 1. Create behavioral enforcement test file at `.opencode/tests-v2/behaviors/skill-description-pattern.sh`
  - **Dispatch:** `task(..., prompt: "execute RED phase from test-driven-development")`
  - **SC:** SC-9, SC-13
  - **Expected:** Test file created with assertions for `skill()` call on matching descriptions and no `skill()` call on non-matching descriptions
  - **VbC:** `ls .opencode/tests-v2/behaviors/skill-description-pattern.sh` confirms file exists; `grep 'assert_semantic\|assert_stderr_pattern'` confirms assertions present

- [ ] 2. Run behavioral test to confirm RED state
  - **Dispatch:** `task(..., prompt: "execute RED phase from test-driven-development")`
  - **SC:** SC-13
  - **Expected:** `bash .opencode/tests-v2/behaviors/skill-description-pattern.sh` exits non-zero (test fails because descriptions haven't changed yet)
  - **VbC:** Capture exit code; confirm non-zero

- [ ] 3. Commit test file to feature branch
  - **Dispatch:** `task(..., prompt: "execute commit task from git-workflow")`
  - **SC:** SC-9
  - **Expected:** Test file committed with message "Phase 0: behavioral enforcement test for skill description pattern"
  - **VbC:** `git log --oneline -1` shows commit

- [ ] 4. Verify RED state is documented
  - **Inline:** Confirm test failure output is captured as evidence
  - **SC:** SC-13
  - **Expected:** RED state evidence stored in `tmp/1961/red-evidence.log`
  - **VbC:** `ls tmp/1961/red-evidence.log` confirms file exists

**Phase 0 — Safety/Rollback:**
- Destructive operations: None
- Rollback plan: `rm .opencode/tests-v2/behaviors/skill-description-pattern.sh && git checkout -- .`
- Data loss risk: None

**Phase 0 completion:** All steps complete, RED state confirmed, test file committed.

---

## Phase 1 — Tooling Updates

**Concern:** Update all 5 tooling/validation files to accept the new "Load via skill() when" pattern alongside the old "Dispatch when" pattern during transition.

**Files:**
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
- `.opencode/plugins/session-enforcement.ts`
- `.opencode/skills/skill-creator/scripts/init_skill.py`
- `.opencode/skills/skill-creator/reference/routing-only-template.md`
- `.opencode/skills/skill-creator/reference/skill-card-spec.md`

**SCs:** SC-4, SC-5, SC-6, SC-7, SC-8

**Dependencies:** Phase 0 complete (test file exists, RED confirmed)

**Entry conditions:** Phase 0 exit criteria met

**Exit conditions:** All 5 tooling files updated, validator accepts both old and new patterns

**Code Path Coverage:** N/A (tooling files, not runtime code)

**Cross-Cutting SCs:** SC-4 (validator must pass after Phase 2 rewrites)

**Interface Boundaries:** Validator must accept both patterns during transition

**State Transitions:** `old_pattern_only → dual_pattern_accepted`

### Step-by-step

- [ ] 5. Update `validate_skill_cards.py` to accept "Load via skill() when" pattern
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 1 step 1")`
  - **SC:** SC-4
  - **Expected:** `validate_req1()` accepts both "Dispatch when" and "Load via skill() when" patterns
  - **VbC:** `grep 'Load via skill()' .opencode/skills/skill-creator/scripts/validate_skill_cards.py` matches; run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` exits 0

- [ ] 6. Update `session-enforcement.ts` comment in `loadSkillDescriptions()`
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 1 step 2")`
  - **SC:** SC-5
  - **Expected:** Comment references new "Load via skill() when" pattern
  - **VbC:** `grep 'Load via skill()' .opencode/plugins/session-enforcement.ts` matches

- [ ] 7. Update `init_skill.py` template
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 1 step 3")`
  - **SC:** SC-6
  - **Expected:** Template uses "Load via skill() when" pattern
  - **VbC:** `grep 'Load via skill()' .opencode/skills/skill-creator/scripts/init_skill.py` matches

- [ ] 8. Update `routing-only-template.md` documentation
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 1 step 4")`
  - **SC:** SC-7
  - **Expected:** Documentation references new pattern
  - **VbC:** `grep 'Load via skill()' .opencode/skills/skill-creator/reference/routing-only-template.md` matches

- [ ] 9. Update `skill-card-spec.md` documentation
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 1 step 5")`
  - **SC:** SC-8
  - **Expected:** Documentation references new pattern
  - **VbC:** `grep 'Load via skill()' .opencode/skills/skill-creator/reference/skill-card-spec.md` matches

**Phase 1 — Safety/Rollback:**
- Destructive operations: Editing 5 existing files
- Rollback plan: `git checkout -- <file>` for each modified file
- Data loss risk: Low

**Phase 1 completion:** All 5 tooling files updated, validator accepts both patterns.

---

## Phase 2 — Description Rewrites

**Concern:** Rewrite all 60 SKILL.md descriptions from "Dispatch when" to "Load via skill() when" agent-intent pattern.

**Files:** All `.opencode/skills/*/SKILL.md` and `.opencode/skills/*/platforms/*/SKILL.md` (60 files)

**SCs:** SC-1, SC-2, SC-3, SC-10, SC-11

**Dependencies:** Phase 1 complete (validator accepts new pattern)

**Entry conditions:** Phase 1 exit criteria met

**Exit conditions:** All 60 descriptions rewritten, validator passes, no "Use when" descriptions remain

**Code Path Coverage:** N/A (content-only changes)

**Cross-Cutting SCs:** SC-4 (validator must pass), SC-10 (length limit), SC-11 (mandatory keyword)

**Interface Boundaries:** Each description must follow the pattern: `<Agent-intent statement>. Load via skill() when <conditions>. <Enforcement>. User phrases: <list>.`

**State Transitions:** `old_descriptions → new_descriptions`

### Step-by-step

- [ ] 10. Rewrite descriptions in batches of 10 files, running validation after each batch
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 2 step 1")`
  - **SC:** SC-1, SC-2, SC-3, SC-10, SC-11
  - **Expected:** Each batch of 10 files rewritten; `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` exits 0 after each batch
  - **VbC:** `grep -L 'User phrases:' .opencode/skills/*/SKILL.md` returns empty after all batches; `grep -r 'description: "Use when' .opencode/skills/*/SKILL.md` returns empty

- [ ] 11. Run full validation on all 60 files
  - **Dispatch:** `task(..., prompt: "execute implementation-pipeline for Phase 2 step 2")`
  - **SC:** SC-1, SC-2, SC-3, SC-10, SC-11
  - **Expected:** `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` exits 0
  - **VbC:** Capture exit code; confirm 0

- [ ] 12. Commit all description rewrites
  - **Dispatch:** `task(..., prompt: "execute commit task from git-workflow")`
  - **SC:** SC-1, SC-2, SC-3
  - **Expected:** All 60 files committed with message "Phase 2: rewrite all 60 SKILL.md descriptions to agent-intent pattern"
  - **VbC:** `git log --oneline -1` shows commit

**Phase 2 — Safety/Rollback:**
- Destructive operations: Rewriting 60 description fields
- Rollback plan: `git checkout -- .opencode/skills/*/SKILL.md` reverts all 60 files
- Data loss risk: Medium (git checkpoint before batch recommended)

**Phase 2 completion:** All 60 descriptions rewritten, validator passes, changes committed.

---

## Phase 3 — Verification

**Concern:** End-to-end verification — run all validation, behavioral tests, and opencode integration checks.

**Files:** All modified files across all phases

**SCs:** SC-12

**Dependencies:** Phase 2 complete (all descriptions rewritten and committed)

**Entry conditions:** Phase 2 exit criteria met

**Exit conditions:** All verification gates pass, GREEN state confirmed

**Code Path Coverage:** N/A (verification phase)

**Cross-Cutting SCs:** All SCs verified

**Interface Boundaries:** N/A

**State Transitions:** `implemented → verified`

### Step-by-step

- [ ] 13. Run `validate_skill_cards.py` on all 60 files — must exit 0
  - **Dispatch:** `task(..., prompt: "execute verification-before-completion for Phase 3 step 1")`
  - **SC:** SC-4, SC-10, SC-11
  - **Expected:** `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` exits 0
  - **VbC:** Capture exit code; confirm 0

- [ ] 14. Run `with-test-home opencode run "list skills"` — verify no frontmatter warnings
  - **Dispatch:** `task(..., prompt: "execute verification-before-completion for Phase 3 step 2")`
  - **SC:** SC-5
  - **Expected:** No stderr lines matching `Warning:|error parsing frontmatter` from session-enforcement.ts
  - **VbC:** `grep -E 'Warning:|error parsing frontmatter'` on stderr output returns empty

- [ ] 15. Run behavioral enforcement test — must PASS (GREEN state)
  - **Dispatch:** `task(..., prompt: "execute verification-before-completion for Phase 3 step 3")`
  - **SC:** SC-9
  - **Expected:** `bash .opencode/tests-v2/behaviors/skill-description-pattern.sh` exits 0
  - **VbC:** Capture exit code; confirm 0

- [ ] 16. Verify all 13 SC evidence types match declared types
  - **Inline:** `grep -c 'evidence_type' .opencode/.issues/1961/spec.md` matches expected count
  - **SC:** SC-12
  - **Expected:** All evidence types match spec declarations
  - **VbC:** Audit confirms no evidence type was downgraded

**Phase 3 — Safety/Rollback:**
- Destructive operations: None (read-only verification)
- Rollback plan: N/A
- Data loss risk: None

**Phase 3 completion:** All verification gates pass, GREEN state confirmed.

---

## Exit Criteria

- [ ] C1. Behavioral enforcement test file exists at `.opencode/tests-v2/behaviors/skill-description-pattern.sh`
- [ ] C2. RED state confirmed (test fails before description changes)
- [ ] C3. All 5 tooling files updated to accept new pattern
- [ ] C4. All 60 SKILL.md descriptions use new agent-intent pattern
- [ ] C5. No SKILL.md description starts with "Use when"
- [ ] C6. All descriptions include "User phrases:" suffix
- [ ] C7. `validate_skill_cards.py` passes on all 60 files
- [ ] C8. `session-enforcement.ts` accepts new pattern (no frontmatter warnings)
- [ ] C9. Behavioral enforcement test passes (GREEN state)
- [ ] C10. All 13 SC evidence types match declared types
- [ ] C11. All changes committed to feature branch
- [ ] C12. PR created (authorization_scope: for_pr)

> **Self-remediation protocol:** If any step fails, the agent MUST self-remediate before proceeding. Do not skip, defer, or escalate without attempting remediation first. If a verification step fails, diagnose the root cause, fix it, and re-run verification. Only after 2+ remediation attempts may the agent escalate.

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work.
