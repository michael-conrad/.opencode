> **Full spec and artifacts: [`.opencode/.issues/1230/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/1230/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1230/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exec Summary

The pre-push hook's Gate 0 blocks all pushes to `main|master|dev` to enforce PR-based branch protection. However, GitHub wiki repos (`.wiki.git`) may not support PRs — they require direct push to `master`. The hook currently blocks these legitimate pushes. The fix adds a `.wiki` remote URL check to Gate 0 so wiki submodule pushes bypass the protection gate while all other pushes remain blocked.

### Cards (dependency order)

1. **Add .wiki remote detection to Gate 0** — In `.opencode/hooks/pre-push`, before the `case "$REMOTE_BRANCH"` check, compare the remote URL (passed as `$2` to the pre-push hook) against `.wiki.git` pattern. Skip Gate 0 if matched.

### Key Decisions

- **Narrow exception, not broad submodule exemption**: The original spec proposed exempting all submodule pushes. This was too broad — non-wiki submodules should follow the same branch protection rules. Only `.wiki` repos are exempted because they have no viable PR workflow.

### Risk Callouts

- **False negative on remote URL pattern**: If the remote URL does not contain `.wiki.git` (e.g., custom hostname), the hook may still block a wiki push. Mitigation: document the `SKIP_BRANCH_PROTECTION=1` override as fallback.

**Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Gate 0 blocks pushes to `main|master|dev` in the main repo (unchanged) | `git push origin dev` from root → exit code 1 with BLOCKED message | Ensure .wiki check does not short-circuit main-repo pushes | GREEN | `.opencode/hooks/pre-push` | Bug/Problem section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-2 | Gate 0 blocks pushes to `main|master|dev` in non-wiki submodules (unchanged) | `git -C nonwiki push origin master` → exit code 1 with BLOCKED message | Ensure .wiki pattern is specific enough to exclude non-wiki submodule remotes | GREEN | `.opencode/hooks/pre-push` | Root Cause section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-3 | Gate 0 permits pushes to `master` in `.wiki` repos | `git -C wiki push origin master` → exit code 0, push proceeds | Ensure the `.wiki.git` pattern check correctly identifies wiki remote URLs | GREEN | `.opencode/hooks/pre-push` | Fix Approach section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-4 | Behavioral enforcement test verifies agent behavior: SC-3 passes with real push simulation | `bash .opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` → exit code 0 | Before any implementation, write the behavioral test in `.opencode/tests/behaviors/`; confirm RED state (test fails before change); then implement | RED (behavioral) | `.opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` | behavioral-test-mandate | Phase 1 | RED | unit | G0-BEHAVE | null | sc-1230-pre-push-wiki.sh | phase-1 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | `.wiki.git` substring match in remote URL | Most reliable indicator of a GitHub wiki repo; covers both `https` and `ssh` URL formats | MUST | SC-3 |
| DEC-2 | No broad submodule exemption | Non-wiki submodules should follow same branch protection; only wiki repos lack PR workflow | MUST NOT | SC-1, SC-2 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | `.wiki.git` pattern misses wiki repo with custom remote URL | Low | Medium | Document `SKIP_BRANCH_PROTECTION=1` override | SC-3 |
| RISK-2 | `.wiki.git` pattern false-positive blocks legitimate non-wiki push | Low | Low | Pattern is specific to `.wiki.git` suffix — unlikely to match non-wiki URLs | SC-2 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Explicit Non-Goals

- No changes to Gate 1 (merged branch topology check)
- No changes to `SKIP_BRANCH_PROTECTION` override mechanism
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
| Live verification | `git -C wiki push origin master` | Confirm the bug exists |
| Direct source search | `.opencode/.issues/AGENTS.md` | Confirm issue directory layout standards |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1230/`.
After creation, `local-issues sync 1230` MUST be run and the result committed to create the local `.opencode/.issues/1230/` entry.
The implementation plan will be created in `.opencode/.issues/1230/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)