# Phase 1 — import-remote completeness gate

**Concern:** Replace the directory-existence-only halt in `import-remote` with a completeness gate that materializes missing required mirror files.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md`

**SCs:** SC1

**Dependencies:** None

**Entry Conditions:**
- Spec #2301 is approved (`approved-for-for_pr` label present in local `issue.yaml`)
- Feature branch exists
- Structure artifact and dependency contract exist

**Exit Conditions:**
- `import-remote` enumerates all required mirror files (`spec.md`, `comments.md`, `remote.md`, `state.md`, frontmatter `github_issue`/`remote_url`) when the local issue directory exists
- `import-remote` materializes any missing required mirror files rather than halting on directory existence alone
- Only halts when the directory is genuinely complete

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-regression-*`
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 2. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-regression-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 3. **RED (**sub-agent**).** Write a failing enforcement test for the completeness gate (scenario 2301). **→ SC1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-red-*`
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The test asserts that when the local issue directory exists, all required mirror files are checked and missing ones are materialized
- [ ] 4. **GREEN (**sub-agent**).** Implement the completeness gate in `import-remote.md`. **→ SC1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Enumerate required mirror files and materialize any that are missing; only halt when the directory is genuinely complete
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 6. **Verify (**sub-agent**).** Verify implementation against success criteria. **→ SC1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Confirm the completeness gate materializes missing files and only halts on a genuinely complete directory
- [ ] 7. **Commit (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC1**
  - Orchestrator runs `git add <files> && git commit -m "<message>"`
  - No co-author trailers during implementation commits

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify the completeness gate enumerates all required mirror files and materializes missing ones. **→ SC1**

**Concern transition:** Leaving the completeness gate implementation → entering the behavioral test proving `spec.md` is materialized. Phase 2 depends on Phase 1's completeness gate.
