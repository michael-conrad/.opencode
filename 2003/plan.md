---
title: Implementation Plan — Orchestrator bypasses spec-creation pipeline
status: draft
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 2003
---

**STATUS:** DRAFT
**CREATED:** 2026-07-19

## Overview

Single-phase implementation. All 4 SCs are tightly coupled — the behavioral test and critical-rules entry are one atomic change. The behavioral test must be in RED state before the critical-rules entry is added, and in GREEN state after.

## Phase 1 — Add behavioral enforcement test + critical-rules entry

### SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Behavioral enforcement test exists verifying agent dispatches to `spec-creation` | 1 | 1.1 |
| SC-2 | Critical-rules entry classifying direct `github_issue_write` for spec content as Tier 2 violation | 1 | 1.2 |
| SC-3 | Behavioral test is in RED state before implementation | 1 | 1.3 |
| SC-4 | Behavioral test is in GREEN state after implementation | 1 | 1.4 |

### Steps

#### Step 1.1 — Create behavioral enforcement test script

Create `.opencode/tests-v2/behaviors/spec-creation-dispatch.sh` as an artifact-only generator following the template in `.opencode/tests-v2/behaviors/template.sh`.

- **SCENARIO_NAME:** `spec-creation-dispatch`
- **SCENARIO_PROMPT:** A real-domain task that triggers spec-creation dispatch (NOT a prose-recall prompt). Example: `"Create a spec for issue #42. I need a specification document for the new feature."` (matching the pattern from `sc1-dispatch-count.sh`)
- The script sources `helpers.sh`, calls `behavior_run`, and exits 0
- No assertion or evaluation logic in the script (artifact-only generator per AGENTS.md)

| Reference | Verified? | Evidence |
|-----------|-----------|----------|
| `.opencode/tests-v2/behaviors/template.sh` | ✅ | File exists |
| `.opencode/tests-v2/behaviors/helpers.sh` | ✅ | File exists |
| `.opencode/tests-v2/behaviors/sc1-dispatch-count.sh` | ✅ | Reference pattern exists |

#### Step 1.2 — Add critical-rules entry to 000-critical-rules.md

Add a new critical-rules entry in the Tier 2 section of `.opencode/guidelines/000-critical-rules.md` classifying direct `github_issue_write` for spec content as a Tier 2 violation.

The entry should be placed near the existing inline-work violation patterns (around line 639) and must:
- Classify as Tier 2 (process-integrity)
- Reference the spec-creation pipeline as the required dispatch target
- Use the standard `### [critical-rules-XXX]` format

| Reference | Verified? | Evidence |
|-----------|-----------|----------|
| `.opencode/guidelines/000-critical-rules.md` | ✅ | File exists |
| Existing inline-work patterns at line 639 | ✅ | `grep` confirmed |

#### Step 1.3 — RED phase: Run behavioral test before change

Run the behavioral test script BEFORE adding the critical-rules entry. The test MUST FAIL (RED state) because the agent has no prohibition against direct `github_issue_write` for spec content.

```bash
BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/spec-creation-dispatch.sh
```

- Verify exit code is 0 (artifact generation succeeded)
- Verify artifacts exist in `./tmp/behavioral-evidence-spec-creation-dispatch-RED-*/`
- Verify the agent's stderr does NOT contain `Skill "spec-creation"` (confirms RED state — agent does NOT dispatch to spec-creation)
- If the test PASSES before the change: the test prompt is defective — fix the prompt

| Reference | Verified? | Evidence |
|-----------|-----------|----------|
| `BEHAVIOR_PHASE=RED` env var | ✅ | Documented in AGENTS.md |
| Artifact directory pattern | ✅ | Documented in AGENTS.md |

#### Step 1.4 — GREEN phase: Add critical-rules entry and re-run

Add the critical-rules entry from Step 1.2 to `.opencode/guidelines/000-critical-rules.md`, then re-run the behavioral test. The test MUST PASS (GREEN state) because the agent now has a prohibition against direct `github_issue_write` for spec content.

```bash
BEHAVIOR_PHASE=GREEN bash .opencode/tests-v2/behaviors/spec-creation-dispatch.sh
```

- Verify exit code is 0 (artifact generation succeeded)
- Verify artifacts exist in `./tmp/behavioral-evidence-spec-creation-dispatch-GREEN-*/`
- Verify the agent's stderr contains `Skill "spec-creation"` (confirms GREEN state — agent dispatches to spec-creation)
- If the test FAILS after the change: verify the critical-rules entry is correct and re-run

| Reference | Verified? | Evidence |
|-----------|-----------|----------|
| Critical-rules entry from Step 1.2 | ✅ | Created in same phase |
| `BEHAVIOR_PHASE=GREEN` env var | ✅ | Default value in helpers.sh |

### Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (adding files, appending to existing file)
- Rollback plan: `git checkout -- .opencode/tests-v2/behaviors/spec-creation-dispatch.sh .opencode/guidelines/000-critical-rules.md` to revert both files
- Data loss risk: None

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/tests-v2/behaviors/template.sh` | ✅ | `ls` confirmed |
| 1.1 | `.opencode/tests-v2/behaviors/helpers.sh` | ✅ | `ls` confirmed |
| 1.2 | `.opencode/guidelines/000-critical-rules.md` | ✅ | `ls` confirmed |
| 1.3 | `BEHAVIOR_PHASE` env var | ✅ | Documented in AGENTS.md |
| 1.4 | `BEHAVIOR_PHASE=GREEN` default | ✅ | Default in helpers.sh line 40 |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Behavioral test template exists | `ls .opencode/tests-v2/behaviors/template.sh` | ✅ |
| Helpers exist with `behavior_run` | `ls .opencode/tests-v2/behaviors/helpers.sh` | ✅ |
| Critical-rules file exists | `ls .opencode/guidelines/000-critical-rules.md` | ✅ |
| Existing inline-work patterns at line 639 | `grep -n 'github_issue_write' .opencode/guidelines/000-critical-rules.md` | ✅ |
| No existing spec-creation dispatch test | `ls .opencode/tests-v2/behaviors/spec-creation-dispatch.sh` (expected: not found) | ✅ |
