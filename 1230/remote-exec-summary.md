> **Full spec and artifacts: [`.opencode/.issues/1230/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/1230/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1230/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exec Summary

The pre-push hook's Gate 0 blocks all pushes to `main|master|dev` to enforce PR-based branch protection. Wiki repositories across all major platforms (GitHub, GitLab, Bitbucket) are separate git repos that do not support PRs — direct push to the default branch is the only delivery mechanism. The hook currently blocks these legitimate pushes. The fix adds wiki remote URL detection to Gate 0 using dual pattern matching (`.wiki.git` for GitHub/GitLab, `/wiki` for Bitbucket).

### Cards (dependency order)

1. **Add wiki remote detection to Gate 0** — In `.opencode/hooks/pre-push`, before the `case "$REMOTE_BRANCH"` check, compare the remote URL (passed as `$2` to the pre-push hook) against `.wiki.git` and `/wiki` patterns. Skip Gate 0 if matched.

### Key Decisions

- **Dual pattern match** (`.wiki.git` + `/wiki`): `.wiki.git` covers GitHub and GitLab; `/wiki` covers Bitbucket — both patterns verified against official documentation
- **No broad submodule exemption**: Non-wiki submodules should follow the same branch protection rules

### Risk Callouts

- **Undocumented platforms (GitBucket, Gitea, Gogs)**: Wiki URL patterns for these platforms could not be verified due to incomplete documentation. `SKIP_BRANCH_PROTECTION=1` override exists as an escape hatch for edge cases

**Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Gate 0 blocks pushes to `main|master|dev` in the main repo (unchanged) | `git push origin dev` from root → exit code 1 with BLOCKED message | Ensure wiki check does not short-circuit main-repo pushes | GREEN | `.opencode/hooks/pre-push` | Bug/Problem section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-2 | Gate 0 blocks pushes to `main|master|dev` in non-wiki submodules (unchanged) | `git -C nonwiki push origin master` → exit code 1 with BLOCKED message | Ensure wiki pattern is specific enough to exclude non-wiki submodule remotes | GREEN | `.opencode/hooks/pre-push` | Root Cause section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-3 | Gate 0 permits pushes to default branch in wiki repos with `.wiki.git` URLs | Simulate push with `.wiki.git` remote URL → exit code 0 | Ensure `.wiki.git` pattern correctly identifies GitHub/GitLab wiki repos | GREEN | `.opencode/hooks/pre-push` | Fix Approach section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-4 | Gate 0 permits pushes to default branch in wiki repos with `/wiki` URLs (Bitbucket) | Simulate push with `repo/wiki` remote URL → exit code 0 | Ensure `/wiki` pattern correctly identifies Bitbucket wiki repos | GREEN | `.opencode/hooks/pre-push` | Fix Approach section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-5 | Behavioral enforcement test verifies agent behavior: SC-3 and SC-4 pass | `bash .opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` → exit code 0 | Before any implementation, write the behavioral test; confirm RED state; then implement | RED (behavioral) | `.opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` | behavioral-test-mandate | Phase 1 | RED | unit | G0-BEHAVE | null | sc-1230-pre-push-wiki.sh | phase-1 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Dual pattern match (`.wiki.git` + `/wiki`) | `.wiki.git` covers GitHub/GitLab; `/wiki` covers Bitbucket — both verified against official documentation | MUST | SC-3, SC-4 |
| DEC-2 | No broad submodule exemption | Non-wiki submodules should follow same branch protection | MUST NOT | SC-1, SC-2 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Wiki pattern misses undocumented platforms (GitBucket, Gitea, Gogs) | Medium | Medium | `SKIP_BRANCH_PROTECTION=1` exists for edge cases; file a spec-fix to extend patterns when new platform needed | SC-3, SC-4 |
| RISK-2 | `/wiki` false-positive on non-wiki repo whose path ends in `/wiki` | Low | Low | `/wiki` is checked as suffix of the repo path component, not arbitrary substring | SC-2 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Explicit Non-Goals

- No changes to Gate 1 (merged branch topology check)
- No changes to other hooks (pre-commit, etc.)
- No retroactive fix for existing blocked wiki pushes

## Regression Invariants

- [ ] 1. `git push origin dev` from the main repo MUST still be blocked
- [ ] 1. `git push origin master` from the main repo MUST still be blocked
- [ ] 1. `git push origin main` from the main repo MUST still be blocked
- [ ] 1. Non-wiki submodules pushing to `master` MUST still be blocked

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `.opencode/hooks/pre-push` lines 35-53 | Inspect Gate 0 implementation |
| Web research | Dedicated sub-agent via live search | Verify wiki URL patterns across GitHub, GitLab, Bitbucket |
| Official docs | [GitHub](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages), [GitLab](https://docs.gitlab.com/ee/user/project/wiki/), [Bitbucket](https://support.atlassian.com/bitbucket-cloud/docs/clone-a-wiki/) | Verify URL format, PR support, and branch naming per platform |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1230/`.
After creation, `local-issues sync 1230` MUST be run and the result committed to create the local `.opencode/.issues/1230/` entry.
The implementation plan will be created in `.opencode/.issues/1230/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)