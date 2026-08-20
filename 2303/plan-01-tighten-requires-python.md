# Phase 1 — Tighten requires-python

**Concern:** Tighten the `requires-python` constraint in the PEP 723 header of `.opencode/tools/plan` to exclude CPython 3.14 so uv selects a Python version with available pytamer wheels.

**Files:**
- `.opencode/tools/plan`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2303 is approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists
- Structure artifact and dependency contract exist
- `.opencode/tools/plan` currently declares `requires-python = "~=3.12"` in its PEP 723 header

**Exit Conditions:**
- The `requires-python` constraint in the PEP 723 header of `.opencode/tools/plan` is exactly `>=3.12,<3.14`
- The bash guard at the top of the file remains intact
- A usage note documents `UV_PYTHON=3.12` as an optional workaround

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC-1**
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-pre-regression-*`
- [ ] 2. **Pre-regression verify (**sub-agent**).** Verify the pre-regression results. **→ SC-1**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-pre-regression-verify-*`
- [ ] 3. **RED (**sub-agent**).** Write a failing enforcement test asserting the `requires-python` constraint is exactly `>=3.12,<3.14`. **→ SC-1**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The test inspects the `# requires-python` line in `.opencode/tools/plan` and asserts its value is exactly `>=3.12,<3.14`
  - The test FAILS because the current value is `~=3.12`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-red-*`
- [ ] 4. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass. **→ SC-1**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Change the `requires-python` value in the PEP 723 header of `.opencode/tools/plan` from `~=3.12` to `>=3.12,<3.14`
  - Add a usage note documenting `UV_PYTHON=3.12` as an optional workaround
  - Do not modify the bash guard at the top of the file
  - No scope creep — only the minimum change needed
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-green-*`
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC-1**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-post-regression-*`
- [ ] 6. **Verify (**sub-agent**).** Verify the implementation against the success criterion. **→ SC-1**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Inspect the `# requires-python` line in `.opencode/tools/plan` and confirm its value is exactly `>=3.12,<3.14`
  - Confirm the bash guard at the top of the file is intact
  - Confirm the usage note documents `UV_PYTHON=3.12`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-verify-*`
- [ ] 7. **Commit (**inline**).** Stage and commit the test and the change together as one atomic slice.
  - Orchestrator runs `git add .opencode/tools/plan <test> && git commit -m "<message>"`
  - No co-author trailer during this implementation commit

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify the `requires-python` constraint is exactly `>=3.12,<3.14` and the bash guard is intact. **→ SC-1**
  - Dispatch a clean-room sub-agent with routing metadata only
  - Assert the constraint value and the intact bash guard

**Concern transition:** Leaving constraint tightening → entering CPython 3.12 verification. Phase 2 depends on Phase 1's constraint change being in place.
