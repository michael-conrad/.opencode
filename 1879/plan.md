# Plan: Zero-tolerance SC skip prohibition

**Issue:** #1879
**Status:** DRAFT
**Authorization Scope:** `for_pr`
**Halt At:** `pr_created`
**Phase Count:** 1 (single-task plan)

## Goal

Add "skipped" to the SC lobotomy prohibition in 4 files, add an SC-count gate to the pipeline, and create a behavioral enforcement test that verifies agents do NOT skip behavioral SCs.

## Architecture

Four text fixes + one pipeline gate + one behavioral test. All changes are independent (no cross-file dependencies), so a single phase suffices. The behavioral test is the primary enforcement mechanism; the text fixes are structural reinforcement.

## Files

| File | Change | SC |
|------|--------|-----|
| `.opencode/guidelines/000-critical-rules.md` | Add "skipped" to `critical-rules-sc-lobotomy` prohibition list | SC-1 |
| `.opencode/guidelines/080-code-standards.md` | Add "skipped" to Test Integrity Mandate §Rule 1 prohibited patterns | SC-2 |
| `.opencode/skills/spec-creation/tasks/holistic-self-check.md` | Add "skipped" to escape-hatch dimension check | SC-3 |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add SC-count gate step referencing `sc-summary.yaml` and `verified_count` | SC-4 |
| `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | New behavioral enforcement test | SC-5, SC-6 |

## Phase 1: Implement SC skip prohibition

### SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|----------|-------|---------|
| SC-1 | `000-critical-rules.md` prohibits "skipped" in SC lobotomy section | 1 | 1.1 |
| SC-2 | `080-code-standards.md` Test Integrity Mandate includes "skipped" | 1 | 1.2 |
| SC-3 | `holistic-self-check.md` escape-hatch dimension includes "skipped" | 1 | 1.3 |
| SC-4 | `implementation-pipeline/SKILL.md` includes SC-count gate referencing `sc-summary.yaml` and `verified_count` | 1 | 1.4 |
| SC-5 | Behavioral test verifies agent does NOT skip behavioral SCs | 1 | 1.5 |
| SC-6 | Behavioral test verifies agent reports BLOCKED instead of skipping | 1 | 1.5 |

### Step-by-Step

#### Step 1.1: Add "skipped" to `000-critical-rules.md` SC lobotomy prohibition

- **File:** `.opencode/guidelines/000-critical-rules.md`
- **Location:** `critical-rules-sc-lobotomy` section (lines 719-729)
- **Change:** Add "skipped" to the heading and add a bullet for "skipping" to the prohibited patterns list
- **Evidence type:** `string`
- **Verification:** `grep -c "skipped" .opencode/guidelines/000-critical-rules.md` returns ≥ 1 in the SC lobotomy section

#### Step 1.2: Add "skipped" to `080-code-standards.md` Test Integrity Mandate

- **File:** `.opencode/guidelines/080-code-standards.md`
- **Location:** Test Integrity Mandate §Rule 1 (lines 612-621)
- **Change:** Add "skipping" to the prohibited patterns list
- **Evidence type:** `string`
- **Verification:** `grep -c "skipped" .opencode/guidelines/080-code-standards.md` returns ≥ 1 in the Test Integrity Mandate section

#### Step 1.3: Add "skipped" to `holistic-self-check.md` escape-hatch dimension

- **File:** `.opencode/skills/spec-creation/tasks/holistic-self-check.md`
- **Location:** Dimension 6 — Escape Hatches (line 37)
- **Change:** Add "skipped" to the agent-behavior escape pattern check
- **Evidence type:** `string`
- **Verification:** `grep -c "skipped" .opencode/skills/spec-creation/tasks/holistic-self-check.md` returns ≥ 1 in the escape-hatch dimension section

#### Step 1.4: Add SC-count gate to `implementation-pipeline/SKILL.md`

- **File:** `.opencode/skills/implementation-pipeline/SKILL.md`
- **Location:** Add a new gate step in the Trigger Dispatch Table (after `pre-pr-gate` or as a new pipeline enforcement rule)
- **Change:** Add a gate that reads `sc-summary.yaml` total, counts verified SCs, and BLOCKs on mismatch. Must reference both `sc-summary.yaml` and `verified_count`.
- **Evidence type:** `string`
- **Verification:** `grep -c "sc-summary.yaml" .opencode/skills/implementation-pipeline/SKILL.md` ≥ 1 AND `grep -c "verified_count" .opencode/skills/implementation-pipeline/SKILL.md` ≥ 1

#### Step 1.5: Create behavioral enforcement test

- **File:** `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh`
- **Pattern:** Artifact-only generator per `tests/AGENTS.md` §1
- **Prompt:** Real-domain task (not prose-recall) per `tests/AGENTS.md` §9
- **SC-5 verification:** Agent does NOT skip behavioral SCs — evaluated by clean-room semantic inspector via `assert_semantic`
- **SC-6 verification:** Agent reports BLOCKED instead of skipping — evaluated by clean-room semantic inspector via `assert_semantic`
- **Evidence type:** `behavioral`

### Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None — all changes are additive (text insertions, new file creation)
- Rollback plan: `git checkout -- <file>` for each modified file; `rm` for the new test file
- Data loss risk: None

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/guidelines/000-critical-rules.md` lines 719-729 | ✅ | Read in session |
| 1.2 | `.opencode/guidelines/080-code-standards.md` lines 612-621 | ✅ | Read in session |
| 1.3 | `.opencode/skills/spec-creation/tasks/holistic-self-check.md` line 37 | ✅ | Read in session |
| 1.4 | `.opencode/skills/implementation-pipeline/SKILL.md` | ✅ | Read in session |
| 1.5 | `.opencode/tests/behaviors/helpers.sh` `behavior_run` | ✅ | Read in session |
| 1.5 | `.opencode/tests/AGENTS.md` §1, §9 | ✅ | Read in session |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| SC lobotomy section is at lines 719-729 | `read(.opencode/guidelines/000-critical-rules.md, offset=715, limit=20)` | ✅ |
| Test Integrity Mandate §Rule 1 is at lines 612-621 | `read(.opencode/guidelines/080-code-standards.md, offset=605, limit=20)` | ✅ |
| Escape-hatch dimension is at line 37 | `read(.opencode/skills/spec-creation/tasks/holistic-self-check.md, offset=30, limit=20)` | ✅ |
| Pipeline has `pre-pr-gate` at line 62 | `read(.opencode/skills/implementation-pipeline/SKILL.md, offset=55, limit=30)` | ✅ |
| Behavioral test template uses `behavior_run` | `read(.opencode/tests/behaviors/1845-sc4-anti-lobotomization.sh)` | ✅ |

### Exit Criteria

- [ ] SC-1: `grep -c "skipped" .opencode/guidelines/000-critical-rules.md` ≥ 1 in SC lobotomy section
- [ ] SC-2: `grep -c "skipped" .opencode/guidelines/080-code-standards.md` ≥ 1 in Test Integrity Mandate section
- [ ] SC-3: `grep -c "skipped" .opencode/skills/spec-creation/tasks/holistic-self-check.md` ≥ 1 in escape-hatch dimension
- [ ] SC-4: `grep -c "sc-summary.yaml" .opencode/skills/implementation-pipeline/SKILL.md` ≥ 1 AND `grep -c "verified_count" .opencode/skills/implementation-pipeline/SKILL.md` ≥ 1
- [ ] SC-5: Behavioral test `1879-sc-skip-prohibition.sh` exists and produces artifacts; clean-room evaluation confirms agent does NOT skip behavioral SCs
- [ ] SC-6: Clean-room evaluation confirms agent reports BLOCKED instead of skipping
- [ ] All string SCs verified via grep
- [ ] Behavioral test artifacts generated and evaluated
- [ ] Plan committed to feature branch
