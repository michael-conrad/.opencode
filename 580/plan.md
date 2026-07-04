# Plan: Staleness Check for PR-Creation Enforcement Gate

**Issue:** #580
**Spec:** [PR creation must verify branch is up-to-date with target base](https://github.com/michael-conrad/.opencode/issues/580)
**Concern:** Single — PR creation must verify branch is up-to-date with target base
**Phase count:** 1 (single phase, single PR)

## Goal

Before any PR is created, the enforcement gate independently verifies the branch is not behind the target base. This is a belt-and-suspenders check — the review-prep step already rebases, but the target may have advanced between stages. The enforcement gate performs its own live staleness check rather than relying on prior-step evidence artifacts.

## Architecture

The staleness check follows the exact pattern already established in `review-prep/push-and-cleanup.md` Step 1.25:

1. `git fetch origin` — ensure remote refs are current
2. `git rev-list --count --left-right origin/<target>...HEAD` — detect staleness
3. If `BEHIND > 0`: `git rebase origin/<target>` — auto-rebase
4. On rebase conflict: route to `conflict-resolution` skill (three-tier classification)
5. Only on success: proceed to PR creation

No intermediate evidence artifacts. No file-based state passing. Git state IS the evidence.

## Files

| File | Change |
|------|--------|
| `skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | Add Step 1.3: staleness check and auto-rebase (after Step 1.2 commit count verification, before Step 1.5 existing PR state) |
| `skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | Add item 9: staleness check to the checklist |
| `tests/behaviors/staleness-gate.sh` | New behavioral test |

## Phase Table

| Phase | Description | Files | RED | GREEN | PR Boundary |
|-------|-------------|-------|-----|-------|-------------|
| 1 | Add staleness check to enforcement gate | enforcement-gate.md, pre-pr-checklist.md, staleness-gate.sh | Behavioral test: agent verifies staleness before PR creation | Add Step 1.3 + checklist item 9 | Single PR |

## Exit Criteria

- [ ] Behavioral test passes: agent fetches target and checks `git rev-list --count --left-right` before PR creation
- [ ] `enforcement-gate.md` has Step 1.3 with fetch, rev-list, auto-rebase, conflict routing
- [ ] `pre-pr-checklist.md` has item 9 with staleness check
- [ ] All existing tests still pass

## Self-Review Evidence

- Spec #580 is the authoritative source
- Pattern follows `review-prep/push-and-cleanup.md` Step 1.25 (existing, tested)
- `conflict-resolution` skill already handles three-tier classification — no changes needed
- No `dev`-specific hardcoding — target is resolved dynamically per TBD per #1540
- No `release-promotion` references — moot per #1540

---

## Phase 1: Add Staleness Check to Enforcement Gate

### Step-by-Step Instructions

#### Step 1: RED — Write Behavioral Test

**Dispatch:** `task(subagent_type="general")`

Create `tests/behaviors/staleness-gate.sh`:

```bash
#!/usr/bin/env bash
# Behavioral test: agent verifies staleness before PR creation
# SC-1: enforcement gate fetches target and checks git rev-list --count --left-right
# SC-8: agent creates PR only after live staleness verification passes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Test scenario: agent is asked to create a PR
# The enforcement gate must independently verify staleness
# PRIMARY evidence: assert_semantic (behavioral) — clean-room inspector judges agent actions
# SECONDARY corroboration: assert_stderr_pattern_present (string) — confirms tool dispatch
run_test "staleness-gate" \
  "create a PR for the feature branch" \
  --assertions '
    assert_semantic "SC-1" "Agent fetches the target branch and checks staleness via git rev-list --count --left-right before creating the PR"
    assert_semantic "SC-2" "When branch is behind target, enforcement gate auto-rebases before PR creation"
    assert_semantic "SC-3" "Tier 1 and Tier 2 conflicts during rebase are auto-resolved via conflict-resolution skill"
    assert_semantic "SC-4" "Tier 3 intent conflicts cause HALT with clear report to developer"
    assert_semantic "SC-6" "Staleness check applies to ALL PRs regardless of target branch with no dev-specific hardcoding"
    assert_semantic "SC-8" "Agent creates the PR only after verifying the branch is up-to-date with the target base"
    assert_stderr_pattern_present "git fetch origin"
    assert_stderr_pattern_present "git rev-list --count --left-right"
  '
```

**RED expected:** Test FAILS because enforcement gate doesn't have the staleness check yet.

#### Step 2: GREEN — Add Step 1.3 to enforcement-gate.md

**Dispatch:** `task(subagent_type="general")`

Insert a new Step 1.3 between Step 1.2 (Commit Count Verification) and Step 1.5 (Check Existing PR State) in `skills/git-workflow/tasks/pr-creation/enforcement-gate.md`.

The new step follows the pattern from `review-prep/push-and-cleanup.md` Step 1.25 but uses a dynamically resolved target (not hardcoded to `origin/dev`). The target is the PR's base branch, passed via task context or resolved from the current branch's upstream:

```markdown
### Step 1.3: Staleness Check and Auto-Rebase (MANDATORY)

Detect whether the feature branch is behind the target base and auto-rebase if stale. The target is resolved dynamically — NOT hardcoded to `origin/dev`.

```bash
git fetch origin
# Target resolved from PR base branch (passed via task context or session-init)
# For feature PRs: origin/<target> where target is the PR's base branch
BEHIND=$(git rev-list --count --left-right origin/<target>...HEAD | awk -F'\t' '{print $2}')
```

**If `BEHIND > 0` (stale branch):**

```bash
git rebase origin/<target>
```

- **Rebase succeeds (clean):** Proceed to Step 1.5.
- **Rebase conflict:** Invoke `conflict-resolution` skill to classify per three-tier system:
  - **Tier 1 (Trivial):** auto-resolve, silent — proceed to Step 1.5
  - **Tier 2 (Textual but safe):** auto-resolve, note in chat — proceed to Step 1.5
  - **Tier 3 (Intent conflict):** HALT and escalate to developer with conflict details

**If `BEHIND == 0` (clean branch):** Proceed normally to Step 1.5.

**AUTHORITY:** Spec #580 — staleness check at enforcement gate. Target is dynamic per TBD (#1540).
```

#### Step 3: GREEN — Add Item 9 to pre-pr-checklist.md

**Dispatch:** `task(subagent_type="general")`

Add a new item 9 to the checklist in `skills/pr-creation-workflow/tasks/pre-pr-checklist.md`, after item 8 (Cross-Model Validation):

```markdown
**9. Staleness Check (MANDATORY)**

```bash
git fetch origin
# Target resolved dynamically from PR base branch
BEHIND=$(git rev-list --count --left-right origin/<target>...HEAD | awk -F'\t' '{print $2}')
```

- `BEHIND == 0` → Proceed
- `BEHIND > 0` → HALT — branch is stale. Run `git rebase origin/<target>` and re-verify.
- Conflict during rebase → Invoke `conflict-resolution` skill per three-tier system.
```

#### Step 4: REFACTOR — Re-run Behavioral Test

**Dispatch:** `task(subagent_type="general")`

Run the behavioral test:

```bash
bash .opencode/tests/behaviors/staleness-gate.sh
```

**Expected:** Test PASSES — enforcement gate now has the staleness check.

#### Step 5: COMMIT

**Dispatch:** `task(subagent_type="general")`

```bash
git add .opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md
git add .opencode/skills/pr-creation-workflow/tasks/pre-pr-checklist.md
git add .opencode/tests/behaviors/staleness-gate.sh
git commit -m "#580 Add staleness check to PR-creation enforcement gate

- enforcement-gate.md: add Step 1.3 staleness check (fetch, rev-list, auto-rebase, conflict routing)
- pre-pr-checklist.md: add item 9 staleness check
- tests/behaviors/: add staleness-gate behavioral test

Co-authored-by: OpenCode (deepseek-v4-flash) <noreply@example.com>
Co-authored-by: Michael Conrad <m.conrad.202@gmail.com>"
```

### VbC Block

After GREEN, verify:

| Check | Command | Expected |
|-------|---------|----------|
| Step 1.3 exists in enforcement-gate.md | `grep -c "Step 1.3" .opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | >= 1 |
| Item 9 exists in pre-pr-checklist.md | `grep -c "Staleness Check" .opencode/skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | >= 1 |
| Behavioral test passes | `bash .opencode/tests/behaviors/staleness-gate.sh` | Exit code 0 |
| No stale dev-specific hardcoding | `grep -c "origin/dev" .opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | Should be 0 (dynamic target only) |
| No release-promotion references | `grep -c "release-promotion" .opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | Should be 0 |

### Phase Completion Block

- [ ] RED test written and FAILS
- [ ] GREEN: Step 1.3 added to enforcement-gate.md
- [ ] GREEN: Item 9 added to pre-pr-checklist.md
- [ ] REFACTOR: Behavioral test PASSES
- [ ] COMMIT: All changes committed together
- [ ] VbC: All checks pass

### Concern Transition

No transition — single phase, single concern.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
