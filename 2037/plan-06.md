# Phase 6 — Behavioral enforcement test

## Phase Metadata

- **Concern:** Create a single behavioral enforcement test script that verifies all 5 discussion discipline rules are followed by the agent. Test must use `assert_semantic` for behavioral SCs and `assert_stderr_pattern_*` for structural corroboration. Must pass with 100% clean PASS.
- **Files:** `.opencode/tests-v2/behaviors/universal-discussion-discipline.sh`
- **SCs:** SC-7 (behavioral)
- **Dependencies:** Phase 5 complete and committed; all 5 discussion discipline rules exist in guideline files
- **Entry conditions:** Phase 5 committed to feature branch; all 5 rules exist in `020-go-prohibitions.md` and `000-critical-rules.md`
- **Exit conditions:** Behavioral test script exists and passes with 100% clean PASS

## Code Path Coverage

| File | Change Type | Code Path |
|------|------------|-----------|
| .opencode/tests-v2/behaviors/universal-discussion-discipline.sh | Create | New behavioral enforcement test |

## Cross-Cutting SCs

- **Behavioral enforcement test consistency:** Single test script must cover SC-1 through SC-5, not just one rule. Each SC gets its own `assert_semantic` call.

## Interface Boundaries

- `Behavioral enforcement test files (.opencode/tests-v2/behaviors/)` — new file created

## State Transitions

- **From:** No behavioral enforcement test exists for universal discussion discipline
- **To:** Behavioral enforcement test exists and passes with 100% clean PASS
- **Invariant:** All 5 rules exist in guideline files — test only verifies behavioral compliance, does not modify rules.

## Step-by-step

- [ ] 41. **Pre-RED baseline (**clean-room**).** Run Phase 1-5 behavioral tests to confirm they all still pass. Run `bash .opencode/tests-v2/behaviors/` to establish full baseline. **→ SC-7**

- [ ] 42. **RED — Write combined behavioral enforcement test (**sub-agent**).** Create `.opencode/tests-v2/behaviors/universal-discussion-discipline.sh` with:
  - Test header with SC-to-assertion traceability comments (`# SC-1:`, `# SC-2:`, etc.)
  - `behavior_run` with a prompt that triggers all 5 discussion discipline concerns
  - `assert_semantic` calls for each behavioral SC (SC-1 through SC-5)
  - `assert_stderr_pattern_*` for structural corroboration (tool dispatch strings)
  - Test MUST FAIL at this point (no combined test exists yet)
  - **→ SC-7**

- [ ] 43. **GREEN — Implement the behavioral test (**sub-agent**).** Write the full test script with proper prompt construction (real-domain task, not prose-recall), assertion helpers from `helpers.sh`, and clean-room semantic evaluation. The test must:
  - Use `behavior_run` with a prompt that naturally triggers discussion discipline scenarios
  - Assert SC-1: agent does NOT use question tool (assert_semantic)
  - Assert SC-2: agent does NOT pigeon-hole in natural language (assert_semantic)
  - Assert SC-3: agent decomposes multi-topic messages (assert_semantic)
  - Assert SC-4: agent orders topics by importance (assert_semantic)
  - Assert SC-5: agent defaults to open-ended discussion (assert_semantic)
  - Include structural corroboration via `assert_stderr_pattern_*` where applicable
  - **→ SC-7**

- [ ] 44. **GREEN doublecheck (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/universal-discussion-discipline.sh`. Verify 100% clean PASS. If FAIL, diagnose and remediate (increase timeout, inspect stdout/stderr, adjust prompt specificity). **→ SC-7**

- [ ] 45. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/universal-discussion-discipline.sh && git commit -m "Phase 6: Behavioral enforcement test for universal discussion discipline"`

#### Phase 6 VbC

- [ ] 46. **VbC (**clean-room**).** Verify SC-7 (behavioral): dispatch `behavioral-test-evaluation` from `verification-before-completion`. Clean-room sub-agent reads behavioral evidence artifacts and evaluates whether the test passes with 100% clean PASS and covers all 5 SCs. **→ SC-7**

**Concern transition:** All phases complete. No further phases.
