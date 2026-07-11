# Phase 3: Behavioral Enforcement Tests

**Phase ID:** behavioral-tests
**Issue:** .opencode#1855
**Dependencies:** Phase 1 (validator tests need updated validator), Phase 2 (intent-dispatch tests need GREEN verification)
**SC Coverage:** SC-7, SC-8, SC-9, SC-12

## Step 12: Write behavioral test — validator rejects old pattern (SC-2)

**File:** `.opencode/tests/behaviors/1855-sc2-validator-rejects-old-pattern.sh`

**Test design:**
1. Create a temporary SKILL.md with old-pattern description: `"Use when creating a branch. Invoke for: branch creation. Trigger phrases: create branch."`
2. Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` on the test file
3. Assert: exit code 1, stderr contains "Use when" or "old pattern" rejection message

**RED phase:** Write test before Phase 1 validator changes. Test fails because validator still accepts old pattern.
**GREEN phase:** After Phase 1 validator changes. Test passes because validator rejects old pattern.

## Step 13: Write behavioral test — validator accepts new pattern (SC-3)

**File:** `.opencode/tests/behaviors/1855-sc3-validator-accepts-new-pattern.sh`

**Test design:**
1. Create a temporary SKILL.md with new-pattern description: `"Branch lifecycle management. Dispatch when the agent needs to create a branch. User phrases: create branch."`
2. Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` on the test file
3. Assert: exit code 0

**RED phase:** Write test before Phase 1 validator changes. Test fails because validator rejects new pattern (requires "Use when").
**GREEN phase:** After Phase 1 validator changes. Test passes because validator accepts new pattern.

## Step 14: Write behavioral test — git-workflow intent dispatch (SC-7)

**File:** `.opencode/tests/behaviors/1855-sc7-git-workflow-intent-dispatch.sh`

**Test design:**
1. Send prompt: "I need to create a pull request for the changes I just made"
2. Run via `opencode-cli run` with `with-test-home` wrapper
3. Assert: stderr contains `skill("git-workflow")` or `'Skill "git-workflow"'`

**RED phase:** Write test before Phase 2 rewrites. Test may fail because old descriptions train agent to pattern-match user phrases.
**GREEN phase:** After Phase 2 rewrites. Test passes because new descriptions train agent to reason about intent.

**Risk mitigation:** Use scope-limited behavioral testing. Assess hardware with `ollama-probe hw` before running. Use `BEHAVIOR_TIMEOUT=420s` and `BEHAVIOR_MAX_RETRIES=2`.

## Step 15: Write behavioral test — spec-creation intent dispatch (SC-8)

**File:** `.opencode/tests/behaviors/1855-sc8-spec-creation-intent-dispatch.sh`

**Test design:**
1. Send prompt: "I need to write a specification for a new feature"
2. Run via `opencode-cli run` with `with-test-home` wrapper
3. Assert: stderr contains `skill("spec-creation")` or `'Skill "spec-creation"'`

**RED phase:** Write test before Phase 2 rewrites.
**GREEN phase:** After Phase 2 rewrites.

**Risk mitigation:** Same as Step 14.

## Step 16: Write behavioral test — verification-before-completion intent dispatch (SC-9)

**File:** `.opencode/tests/behaviors/1855-sc9-verification-before-completion-intent-dispatch.sh`

**Test design:**
1. Send prompt: "I've finished implementing the changes, I need to verify everything is correct"
2. Run via `opencode-cli run` with `with-test-home` wrapper
3. Assert: stderr contains `skill("verification-before-completion")` or `'Skill "verification-before-completion"'`

**RED phase:** Write test before Phase 2 rewrites.
**GREEN phase:** After Phase 2 rewrites.

**Risk mitigation:** Same as Step 14.

## Step 17: Update content-verification test d1-description-format.sh

**File:** `.opencode/tests/content-verification/d1-description-format.sh`

**Current assertion (line 10):**
```bash
if grep -q '^description: "Use when' "$SKILL_FILE"; then
  echo "PASS: SC-1 — description starts with 'Use when'"
```

**New assertion:**
```bash
if ! grep -q '^description: "Use when' "$SKILL_FILE"; then
  echo "PASS: SC-1 — description does NOT start with 'Use when'"
```

**RED/GREEN:** RED: test passes with old pattern (asserts "Use when" exists). GREEN: after Phase 2, test passes with new assertion (asserts "Use when" absent).

## Step 18: Run full validation pass

Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` on the entire skills directory. Verify exit code 0.

## Step 19: Run scope-limited behavioral test suite

Run behavioral tests for this spec only:
```bash
bash .opencode/tests/behaviors/1855-sc2-validator-rejects-old-pattern.sh
bash .opencode/tests/behaviors/1855-sc3-validator-accepts-new-pattern.sh
bash .opencode/tests/behaviors/1855-sc7-git-workflow-intent-dispatch.sh
bash .opencode/tests/behaviors/1855-sc8-spec-creation-intent-dispatch.sh
bash .opencode/tests/behaviors/1855-sc9-verification-before-completion-intent-dispatch.sh
```

All must PASS.

## Step 20: Run existing behavioral test suite (SC-12)

Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no existing tests break.

**Risk mitigation:** Default to `--changed` scope-limited run. Only run full suite if model speed permits (`ollama-probe hw` → VRAM ≥ 8 GB, local model ≥ 7B).

## Phase 3 Completion

- [ ] All 5 behavioral test scripts written
- [ ] Content-verification test updated
- [ ] SC-7: Agent dispatches git-workflow on intent to create PR (behavioral)
- [ ] SC-8: Agent dispatches spec-creation on intent to write spec (behavioral)
- [ ] SC-9: Agent dispatches verification-before-completion on intent to verify (behavioral)
- [ ] SC-12: No existing behavioral tests break (behavioral)
- [ ] Z3 check: verify phase output has PASS status
