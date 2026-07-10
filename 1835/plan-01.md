# Phase 1 — Global Pre-Phase

**Concern:** Setup, pre-flight, coherence, baseline checks

**Files:** None (no file modifications)

**SCs:** SC-22 (No existing analytical capability is removed or weakened)

**Dependencies:** none

**Entry Criteria:** Spec #1835 approved, feature branch exists

**Exit Criteria:** All pre-flight checks pass, branch is ready for implementation

## Step-by-Step

- [ ] 1. (**inline**) Verify spec is approved — check `approved-for-*` label on issue #1835
  - Command: `github_issue_read(method=get_labels, issue_number=1835, owner=michael-conrad, repo=.opencode)`
  - Expected: label `approved-for-pr` present
  - SC: All

- [ ] 2. (**inline**) Verify feature branch exists and is current
  - Command: `git branch --list feature/1835-analytical-depth-restoration`
  - Expected: branch exists

- [ ] 3. (**inline**) Verify `.opencode/.issues/1835/` directory exists
  - Command: `ls .opencode/.issues/1835/`
  - Expected: directory exists

- [ ] 4. (**inline**) Run `local-issues sync` to ensure worktree is current
  - Command: `.opencode/tools/local-issues sync`
  - Expected: sync succeeds

- [ ] 5. (**inline**) Read all existing task files that will be modified to establish baseline (for SC-22: no existing capability removed)
  - Command: Read each file listed in spec's affected files table
  - Expected: baseline established, no existing analytical capability removed
  - SC: SC-22

## Phase Completion

- [ ] All pre-flight checks pass
- [ ] Baseline established for SC-22 verification
- [ ] Proceed to Phase 2

## Concern Transition

Phase 1 establishes the baseline. Phase 2 creates the 7 new analytical task files that form the core of the spec-creation pipeline's analytical depth restoration.
