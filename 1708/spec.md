## Problem

When asked to create a release PR, the agent bypasses the existing skill deck and creates submodule-pointer-only PRs that get rejected. The skills exist but the agent does not dispatch to them:

- `changelog-generator` — has `since-last-release` task for generating changelog entries
- `git-workflow` — has `pr-creation` task with `{is_release: true}` flag
- `pr-creation-workflow` — has `pre-pr-checklist` task

Instead, the agent manually creates a branch with only submodule pointer changes, files a PR, and gets rejected. The agent also committed `.issues/` plan artifacts into the release commit (later amended out).

## Root Cause

The agent is not evaluating the skill deck before taking action. The Pre-Response Gate Procedure in `.opencode/AGENTS.md` mandates evaluating all available skill descriptions before producing output, but the agent is not following this procedure for release PR creation.

## Evidence

- PR #15 (Dailies) was created as a submodule-pointer-only PR and rejected with "contains wrong branch stuff"
- The agent attempted to commit `.issues/12/` plan artifacts into the release commit
- The agent pushed directly to submodule `master` branches before being corrected to use feature branches + PRs
- `changelog-generator` skill was never dispatched until explicitly told to

## Expected Behavior

When "approved for release pr" is received, the agent should:
1. Dispatch `changelog-generator --task since-last-release` to generate changelog/release notes
2. Dispatch `git-workflow --task pr-creation` with `{is_release: true}` flag
3. Include changelog updates, release notes, and any version bumps in the PR
4. NOT create submodule-pointer-only PRs

## Fix Status

The fix is tracked by #1709 (10-phase spec). As of 2026-07-07:
- **Phases 1-4, 7, 8: DONE** — trigger phrases, Pre-Response Gate wiring, authorization gate, escape hatch closure, release branch naming, post-merge wiring
- **Phases 5, 6, 9, 10: PENDING** — version-manager skill, release-promoter skill, pre-release validation, behavioral enforcement tests

## Environment

- Repo: NewSRX-Tech-LLC/Dailies (GitBucket)
- Branch: master (trunk-based, no dev branch)
- Submodules: 30+ submodules, each independently developed
- Pre-commit hook blocks submodule-pointer-only commits

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
