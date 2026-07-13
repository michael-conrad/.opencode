# Plan: Pre-Response Gate Restructure

**Issue:** #1900
**Status:** Draft
**Provenance:** AI-generated

## Goal

Restructure the Pre-Response Gate in `prompts/default.txt` to separate five concerns into independent sections, fix the spec-audit.md Step 0a gate from WARNING to BLOCK/HALT, write behavioral enforcement tests in RED state, and clarify AGENTS.md Step 1 wording from utterance-matching to intent-matching.

## Architecture

The Pre-Response Gate is a single positional enforcement point in `prompts/default.txt` that fires before every agent output. Currently it mixes five concerns under one header. The restructured version separates them into:

1. **Pre-Response Gate** (points 1-3 + Forbidden Rationalizations + Cost Model) — inline, positional
2. **Sub-Agent Routing Boundary** (point 4) — own section, same positional enforcement
3. **Evidence Hierarchy** — removed from default.txt, cross-referenced to `065-verification-honesty.md`

AGENTS.md Step 1 wording is a separate concern in a separate file.

## Affected Files

| File | Change Type | Phase |
|------|-------------|-------|
| `.opencode/prompts/default.txt` | Restructure | 1 |
| `.opencode/skills/audit/tasks/spec-audit.md` | Bug fix (WARNING → BLOCK/HALT) | 1 |
| `.opencode/tests/behaviors/` | New behavioral tests (RED state) | 1 |
| `.opencode/AGENTS.md` | Wording change | 2 |

## Phase Table

| Phase | Description | SCs | Dependencies |
|-------|-------------|-----|-------------|
| 1 | Restructure `prompts/default.txt` — keep points 1-3 + Forbidden Rationalizations + Cost Model inline, remove Evidence Hierarchy, separate point 4 into own section. Fix spec-audit.md Step 0a (WARNING → BLOCK/HALT). Write behavioral enforcement tests in RED state. | SC-1, SC-2, SC-3, SC-4, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | None |
| 2 | Clarify AGENTS.md Step 1 wording from "Evaluate the user message" to "Evaluate your current context and task intent" | SC-5 | Phase 1 |

## SC-to-Step Traceability

### Phase 1

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-1 | default.txt Pre-Response Gate contains points 1-3 + Forbidden Rationalizations inline | 1.1, 1.2 |
| SC-2 | Evidence Hierarchy REMOVED from default.txt | 1.3 |
| SC-3 | Cost Model stays inline in default.txt | 1.1 |
| SC-4 | Point 4 in separate section outside Pre-Response Gate | 1.4 |
| SC-6 | Agent still dispatches skills (behavioral) | 1.6 |
| SC-7 | Agent still applies forbidden rationalizations inline (behavioral) | 1.6 |
| SC-8 | Behavioral tests exist in RED state before change | 1.5 |
| SC-9 | spec-audit.md Step 0a emits BLOCK/HALT not WARNING | 1.7 |
| SC-10 | Remediation procedure for audit FAIL | 1.7 |
| SC-11 | No escape hatch language in restructured gate | 1.2 |

### Phase 2

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-5 | AGENTS.md Step 1 changed to "context and task intent" | 2.1 |

## Implementation Steps

### Phase 1: Restructure `prompts/default.txt` + Fix spec-audit.md + Behavioral Tests

**Safety/Rollback:** No destructive operations in this phase — all changes are text edits to `.md` and `.txt` files. Rollback via `git checkout` on individual files.

**Feasibility:**

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/prompts/default.txt` Pre-Response Gate section | ✅ | Spec confirms lines 5-16 contain the gate block |
| 1.3 | `.opencode/guidelines/065-verification-honesty.md` | ✅ | Spec confirms Evidence Hierarchy lives in 065 |
| 1.5 | `.opencode/tests/behaviors/` | ✅ | Directory exists per test infrastructure |
| 1.7 | `.opencode/skills/audit/tasks/spec-audit.md` line 90-92 | ✅ | Spec confirms Step 0a location |

#### Step 1.1 — Restructure Pre-Response Gate header and points 1-3

Edit `.opencode/prompts/default.txt`:

- Keep the Pre-Response Gate header
- Keep points 1-3 (scan available_skills, call skill() when triggered, justify when no match) inline under the header
- Keep Forbidden Rationalizations inline under the header
- Keep Cost Model inline under the header (coupled with rationalization #4)
- Remove the Evidence Hierarchy subsection from the gate
- Ensure no escape hatch language ("use best judgment", "as needed", "TBD", "TODO", "left to implementor") is present

**Verification:** `grep` for dispatch points + rationalization patterns present in default.txt Pre-Response Gate section. `grep` for absence of all 5 escape hatch patterns.

#### Step 1.2 — Verify no escape hatch language

Confirm the restructured gate contains none of: "use best judgment", "as needed", "TBD", "TODO", "left to implementor".

**Verification:** `grep -c` each pattern against default.txt — all must return 0.

#### Step 1.3 — Remove Evidence Hierarchy from default.txt

Delete the Evidence Hierarchy subsection from the Pre-Response Gate section. The canonical source is `065-verification-honesty.md` §Evidence Hierarchy.

**Verification:** `grep "Evidence Hierarchy" .opencode/prompts/default.txt` returns empty.

#### Step 1.4 — Separate point 4 into own section

Move point 4 (sub-agent dispatch via `task()`) out of the Pre-Response Gate block into its own section titled "Sub-Agent Routing Boundary" in `default.txt`. Same positional enforcement (fires pre-output), cleaner grouping.

**Verification:** `grep` for sub-agent routing section outside Pre-Response Gate block in default.txt.

#### Step 1.5 — Write behavioral enforcement tests in RED state

Create behavioral test scripts in `.opencode/tests/behaviors/` that:

- **SC-6 test:** Send a task-triggering prompt via `opencode-cli run`, verify `skill()` call appears in stderr. Must FAIL before the restructuring change (RED state).
- **SC-7 test:** Send a rationalization-triggering prompt, verify agent does not rationalize. Must FAIL before the restructuring change (RED state).
- **SC-8 test:** Run with `--scenario` matching each gate SC — RED tests fail before change, GREEN tests pass after.

Use `with-test-home` wrapper. Assertions use `assert_stderr_pattern_present`/`assert_stderr_pattern_absent` for tool dispatch strings, and `assert_semantic` for behavioral SCs.

**Verification:** Run each test — confirm FAIL (RED state) before Phase 1 changes are applied.

#### Step 1.6 — Run behavioral tests to confirm RED state

Execute the behavioral tests written in Step 1.5. All must FAIL because the restructuring change has not been applied yet. This confirms the tests are valid RED-state tests.

**Verification:** Each test returns non-zero exit code with expected failure output.

#### Step 1.7 — Fix spec-audit.md Step 0a and add remediation procedure

Edit `.opencode/skills/audit/tasks/spec-audit.md`:

- **Step 0a (line ~90-92):** Change missing analytical artifacts from emitting a WARNING to emitting BLOCK/HALT. The gate must match the SKILL.md which already specifies HALT for missing artifacts.
- **Remediation section:** Add mandatory procedure for audit FAIL:
  1. Diagnose — identify which SCs failed and root cause
  2. Remediate — fix the spec to address failing SCs
  3. Re-audit — re-run spec-audit with revised spec
  4. Escalate — if FAIL cannot be remediated, escalate to developer with failing SCs, root cause, and recommended action
  5. Never proceed past FAIL — unremediated FAIL must not advance to implementation

**Verification:** `grep` for absence of "emit a WARNING" in spec-audit.md Step 0a. `grep` for presence of "BLOCK/HALT". `grep` for remediation procedure sections (diagnose, remediate, re-audit, escalate).

#### Step 1.8 — Run behavioral tests to confirm GREEN state

Re-run the behavioral tests from Step 1.5. All must PASS now that the restructuring change has been applied. This confirms the tests are valid GREEN-state tests.

**Verification:** Each test returns zero exit code.

### Phase 2: Clarify AGENTS.md Wording

**Safety/Rollback:** No destructive operations. Rollback via `git checkout .opencode/AGENTS.md`.

**Feasibility:**

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 2.1 | `.opencode/AGENTS.md` Step 1 (lines ~30-40) | ✅ | Spec confirms location |

#### Step 2.1 — Change AGENTS.md Step 1 wording

Edit `.opencode/AGENTS.md` Step 1 from:

> "Evaluate the user message against ALL available skill descriptions."

To:

> "Evaluate your current context and task intent against ALL available skill descriptions. (The match is between what you need to do next and what the skill does — not the literal user utterance.)"

**Verification:** `grep` AGENTS.md for "context and task intent" — must return at least one match. `grep` for "Evaluate the user message" — must return zero matches.

## Exit Criteria

- [ ] Phase 1 complete: default.txt restructured, spec-audit.md fixed, behavioral tests written in RED state
- [ ] Phase 2 complete: AGENTS.md Step 1 wording changed
- [ ] All string SCs (SC-1 through SC-5, SC-9, SC-11) verified via grep
- [ ] All behavioral SCs (SC-6, SC-7, SC-8) verified via opencode-cli run
- [ ] Semantic SC (SC-10) verified via clean-room sub-agent read
- [ ] Plan committed to feature branch `feature/1900-pre-response-gate-restructure`

## Implementation Pipeline Gate Steps

The following implementation-pipeline gate steps MUST be executed after plan approval:

| Gate | Skill/Task | When |
|------|-----------|------|
| Pre-work | `git-workflow --task pre-work` | Before any file modification |
| Implementation | `implementation-pipeline` | Dispatch each phase to clean-room sub-agents |
| Verification | `verification-before-completion` | After implementation, before completion claim |
| Finishing checklist | `finishing-a-development-branch --task checklist` | Before PR |
| Review prep | `git-workflow --task review-prep` | Before PR creation |
| PR creation | `git-workflow --task pr-creation` | After review prep |
| Cleanup | `git-workflow --task cleanup` | After PR merge |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Spec is approved | `github_issue_read(method=get_labels, issue_number=1900)` → `approved-for-pr` label | ✅ |
| All 7 analytical artifacts exist | `ls .opencode/.issues/1900/artifacts/` → 7 files | ✅ |
| default.txt Pre-Response Gate at lines 5-16 | Spec §Root Cause Analysis | ✅ |
| spec-audit.md Step 0a at lines 90-92 | Spec §Proposed Changes | ✅ |
| AGENTS.md Step 1 at lines 30-40 | Spec §Root Cause Analysis | ✅ |
