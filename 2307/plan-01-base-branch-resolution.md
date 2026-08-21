# Phase 1 — Dynamic base branch resolution

**Concern (C1):** Base-branch resolution — replace the hardcoded `local base="dev"` default in `construct_compare_url()` with dynamic remote HEAD branch resolution (`$DEFAULT_BRANCH`), preserving the explicit `--base` override and adding the `main` fallback. Isolated from URL construction and character-match verification (concern C2).

**Files:**
- `.opencode/skills/git-workflow/enforcement/url_validation.sh`
- Behavioral test artifact(s)

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** none

**Entry condition:** Coherence gate and baseline check passed (plan index Pre-Implementation).

**Exit condition:** SC-1, SC-2, SC-3 verified PASS; `construct_compare_url` resolves the base per resolution order (override → dynamic → `main`) with no change to URL construction or verification paths.

**Code Path Coverage:** `construct_compare_url()` in `url_validation.sh` — base defaulting (`local base="dev"` line 18), `--base` case assignment.

**Interface Boundaries:** `construct_compare_url --owner --repo --branch [--base]` sourceable shared module interface (IF-1). The base resolution order (override → dynamic → `main`) is the target state. No caller signature change.

**State Transitions:** ST-1 — base from hardcoded `dev` → base from dynamic `$DEFAULT_BRANCH` with `--base` override and `main` fallback.

**Cost frame:** Running the behavioral shell test for each item costs minutes of execution time. Skipping SC-1 means every PR compare URL targets the non-existent `dev` branch until discovered downstream; skipping the `--base` override or `main` fallback (SC-2, SC-3) breaks callers or environments without a remote.

---

### Item 1 (SC-1)

- [ ] 1. **RED — write the failing behavioral assertion.** Write a behavioral shell test asserting `construct_compare_url` resolves the base from the remote HEAD branch instead of `dev`. (**sub-agent**)
  - Set up a controlled git remote whose HEAD branch is `master`.
  - Invoke `construct_compare_url --owner o --repo r --branch b`.
  - The test must FAIL because the base is currently hardcoded to `dev`.
- [ ] 2. **GREEN — resolve the base dynamically.** Replace `local base="dev"` with dynamic remote HEAD branch resolution. (**sub-agent**)
  - Resolve via `DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')`.
  - Use the resolved `$DEFAULT_BRANCH` as the base when no `--base` override was supplied.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-1. (**sub-agent**)
  - Run the behavioral shell test with a remote whose HEAD branch is `master`.
  - Assert the produced URL uses `master` as the base.
- [ ] 5. **Commit.** Stage and commit the base resolution change together with the behavioral test as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Item completion:** SC-1 verified PASS. `construct_compare_url` resolves the base from the remote HEAD branch, not `dev`.

### Item 2 (SC-2)

- [ ] 6. **RED — write the failing behavioral assertion.** Write a behavioral shell test asserting an explicit `--base` argument overrides the resolved default branch. (**sub-agent**)
  - Invoke `construct_compare_url --owner o --repo r --branch b --base dev`.
  - The test must FAIL if the override is removed by the dynamic resolution change.
- [ ] 7. **GREEN — preserve the `--base` override.** Ensure the `--base) base="$2"` assignment takes precedence over dynamic resolution. (**sub-agent**)
  - The explicit `--base` override must win over the resolved `$DEFAULT_BRANCH`.
- [ ] 8. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 9. **Verify.** Verify the implementation against SC-2. (**sub-agent**)
  - Run the behavioral shell test with `--base dev`.
  - Assert the produced URL uses `dev` as the base.
- [ ] 10. **Commit.** Stage and commit the override-preservation change together with the behavioral test as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Item completion:** SC-2 verified PASS. An explicit `--base` override takes precedence.

### Item 3 (SC-3)

- [ ] 11. **RED — write the failing behavioral assertion.** Write a behavioral shell test asserting the base falls back to `main` when the remote HEAD branch cannot be determined. (**sub-agent**)
  - Invoke `construct_compare_url` with no remote configured.
  - The test must FAIL if there is no `main` fallback.
- [ ] 12. **GREEN — add the `main` fallback.** Add the fallback when remote HEAD branch resolution is empty. (**sub-agent**)
  - Add `if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi`.
- [ ] 13. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 14. **Verify.** Verify the implementation against SC-3. (**sub-agent**)
  - Run the behavioral shell test with no remote configured.
  - Assert the produced URL uses `main` as the base.
- [ ] 15. **Commit.** Stage and commit the fallback change together with the behavioral test as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Item completion:** SC-3 verified PASS. Base falls back to `main` when the remote HEAD branch is undeterminable.

---

#### Phase 1 VbC

- [ ] 16. **VbC (clean-room).** Verify SC-1, SC-2, SC-3 — the base resolves dynamically from the remote HEAD branch, the `--base` override wins, and the `main` fallback applies when the remote HEAD branch is undeterminable.

**Concern transition:** Leaving base-branch resolution (C1) → entering URL construction and verification regression guard (C2). Phase 2 depends on Phase 1's base resolution change.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
