# Phase 2 — URL construction and verification regression guard

**Concern (C2):** URL construction and verification — preserve `set -euo pipefail`, the owner/repo character-match checks, and the ERROR + exit 1 error returns after the Phase 1 base resolution change. The URL template and character-match verification remain unchanged; SC-4 is the regression guard over the whole function.

**Files:**
- `.opencode/skills/git-workflow/enforcement/url_validation.sh`
- Behavioral regression test artifact(s)

**SCs:** SC-4

**Dependencies:** Phase 1 (base resolution change must be in place before this regression guard runs)

**Entry condition:** Phase 1 complete — SC-1, SC-2, SC-3 verified PASS and their changes committed.

**Exit condition:** SC-4 verified PASS; `set -euo pipefail`, owner/repo character-match checks, and error returns intact after the base resolution change.

**Code Path Coverage:** `construct_compare_url()` in `url_validation.sh` — `set -euo pipefail`, owner/repo character-match verification, missing-arg and mismatch ERROR + exit 1 returns.

**Interface Boundaries:** `construct_compare_url --owner --repo --branch [--base]` sourceable shared module interface (IF-1). No caller signature change.

**State Transitions:** ST-1 — verification/error paths unchanged after the base resolution change.

**Cost frame:** Running the behavioral regression test for this item costs minutes of execution time. Skipping the regression guard SC-4 means the verification/error handling silently regresses while the URLs pass structural checks.

---

### Item 4 (SC-4)

- [ ] 17. **RED — write the failing behavioral regression assertion.** Write a behavioral regression test asserting `set -euo pipefail`, owner/repo character-match checks, and error returns still work. (**sub-agent**)
  - The test must FAIL if the base resolution change regresses verification/error handling.
- [ ] 18. **GREEN — preserve verification and error handling.** Ensure the base resolution change does not alter the verification/error paths. (**sub-agent**)
  - Retain `set -euo pipefail`.
  - Retain the owner/repo character-match checks and the ERROR + exit 1 returns on missing args and on mismatch.
- [ ] 19. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 20. **Verify.** Verify the implementation against SC-4. (**sub-agent**)
  - Run the behavioral regression test with missing args and with owner/repo not in URL.
  - Assert ERROR + exit 1 on both, and assert `set -euo pipefail` is retained.
- [ ] 21. **Commit.** Stage and commit the regression-guard test together with any verification-preserving change as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Item completion:** SC-4 verified PASS. Verification/error handling intact after the base resolution change.

---

#### Phase 2 VbC

- [ ] 22. **VbC (clean-room).** Verify SC-4 — `set -euo pipefail`, owner/repo character-match checks, and ERROR + exit 1 on missing args and on mismatch remain intact after the base resolution change.

**Concern transition:** All concerns complete. Base-branch resolution (C1) and URL construction/verification (C2) both implemented and verified. Proceed to plan index Post-Implementation (audit, Z3 check, structural checks, pre-PR gate, regression check, review-prep, create PR, exec summary).

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
