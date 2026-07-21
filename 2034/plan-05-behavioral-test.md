# Phase 5 — Behavioral enforcement test for "pr merged" → cleanup routing

## Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Behavioral enforcement test — verify agent dispatches cleanup (not check-pr) when user says "pr merged" |
| **Files** | `.opencode/tests-v2/behaviors/cleanup-routing.sh` |
| **SCs** | SC-6 |
| **Dependencies** | Phases 1, 2, 3, 4 (all trigger and content changes must be in place) |
| **Entry** | Phases 1-4 complete — all trigger routing and content changes deployed |
| **Exit** | Behavioral test created at `.opencode/tests-v2/behaviors/cleanup-routing.sh` and passes |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-6 | Behavioral test: "pr merged" dispatches cleanup, not check-pr | 5 | 19, 20, 21 |

## Safety/Rollback

**Phase 5 — Safety/Rollback:**
- Destructive operations: None (new file creation only)
- Rollback plan: `rm .opencode/tests-v2/behaviors/cleanup-routing.sh`
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 19 | `.opencode/tests-v2/behaviors/` directory | ✅ | Directory exists with existing behavioral test files |
| 19 | `with-test-home` wrapper | ✅ | Documented in `.opencode/AGENTS.md` |
| 19 | `assert_stderr_pattern_present` / `assert_stderr_pattern_absent` helpers | ✅ | Available in `.opencode/tests-v2/behaviors/helpers.sh` |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Behavioral test directory exists | `ls .opencode/tests-v2/behaviors/` | ✅ |
| Assertion helpers exist | `grep 'assert_stderr_pattern' .opencode/tests-v2/behaviors/helpers.sh` | ✅ |

## Code Path Coverage

| Code Path | Covered By |
|-----------|-----------|
| "pr merged" → cleanup dispatch (stderr evidence) | Step 19 (test script) |
| "pr merged" → NOT check-pr dispatch (stderr evidence) | Step 19 (test script) |

## Cross-Cutting SCs

| SC ID | Applies? | Note |
|-------|----------|------|
| SC-6 | ✅ | Primary SC — behavioral test |

## Interface Boundaries

| Interface | Relevance |
|-----------|-----------|
| Behavioral test harness (`with-test-home`, `helpers.sh`) | Test execution infrastructure |

## State Transitions

| From | To | Trigger |
|------|----|---------|
| No behavioral test for cleanup routing | Behavioral test exists and passes | File creation + test execution |

## Step-by-Step

- [ ] 19. **Create behavioral test script (**sub-agent**).** Create `.opencode/tests-v2/behaviors/cleanup-routing.sh` with:
  - Test header: `# Test: "pr merged" dispatches cleanup, not check-pr`
  - Source `helpers.sh`
  - Run `behavior_run "pr merged"` via `with-test-home`
  - Assert: `assert_stderr_pattern_present 'git-workflow-cleanup --task cleanup'` (cleanup dispatch occurs)
  - Assert: `assert_stderr_pattern_absent 'git-workflow-cleanup --task check-pr'` (check-pr dispatch does NOT occur)
  - Set `OVERALL_RESULT=1` on any assertion failure
  - Exit with `$OVERALL_RESULT`
  **→ SC-6**

- [ ] 20. **Run the behavioral test (**inline**).** Execute `bash .opencode/tests-v2/behaviors/cleanup-routing.sh`. The test MUST PASS (exit code 0). If it fails, diagnose and remediate. **→ SC-6**

- [ ] 21. **Collect behavioral evidence artifacts (**inline**).** Copy `$log_dir/stdout.log` and `$log_dir/stderr.log` from the test run to `{project_root}/tmp/behavioral-evidence-2034/` for audit trail. **→ SC-6**

- [ ] 22. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/cleanup-routing.sh && git commit -m "Phase 5: behavioral enforcement test for 'pr merged' → cleanup routing"`

### Phase 5 VbC

- [ ] 22. **VbC — behavioral test evaluation (**clean-room**).** After artifact generation from Step 20-21, dispatch `behavioral-test-evaluation` from `verification-before-completion`. The clean-room evaluator reads the test artifacts and judges whether the agent's actions satisfy SC-6. **→ SC-6 (evidence_type: behavioral)**

  **Mandatory gate:** PASS verdict for SC-6 requires clean-room evaluation PASS. "Artifact generated" is NOT a valid PASS verdict — only clean-room evaluation counts.

**Concern transition:** All phases complete. No further phases.
