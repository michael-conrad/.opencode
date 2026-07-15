# Task: checklist

## Purpose

Run the completion checklist to verify a branch is fully ready for PR creation.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## Operating Protocol

- [ ] 1. Invoked by: `skill({name: "finishing-a-development-branch"})` → `task()` for `checklist`
- [ ] 2. When to use: After `--task prepare` is complete
- [ ] 3. Exit criteria: All checklist items pass, compare URL verified, HALT and report readiness

## Branch Completion Checklist

```markdown
## Branch Completion Checklist

### Changes
- [ ] All changes committed
- [ ] No untracked files remaining
- [ ] Commit messages are descriptive
- [ ] Co-authored-by trailers present

### Code Quality
- [ ] `ruff check` passes (zero errors)
- [ ] `ruff format --check` passes (advisory)
- [ ] `pyright` passes (zero errors)
- [ ] No dead code detected

### Tests
- [ ] All tests pass
- [ ] No skipped tests without reason
- [ ] New code has test coverage

### SC Verification
- [ ] Per-SC evidence table produced for all success criteria
- [ ] All per-SC evidence rows show PASS (no FAIL or MISSING EVIDENCE)
- [ ] No FORBIDDEN outcomes ("functionally equivalent", "close enough") used in evidence table
- [ ] VbC 4-column table (ID, Criterion, Test, Result) present in PR body
- [ ] VbC table format matches spec (read PR body and confirm column headers, row structure)
- [ ] VbC table populated from VbC output artifacts, not hand-written (verify source is `tmp/behavioral-evidence-*` or equivalent artifact path)
- [ ] For behavioral SCs, re-run `bash .opencode/tests-v2/behaviors/<scenario>.sh` and verify PASS — do NOT accept a prior run's output as evidence; agent state may have changed between implementation and completion

### Structural & Acceptance Verification
- [ ] Structural completeness verified (all checklist items in scope are checked)
- [ ] Acceptance criteria verified (per-SC evidence table in previous section)

### Branch
- [ ] Branch pushed to remote (orchestrator responsibility when `pr_strategy = stacked`)
- [ ] Upstream tracking set (orchestrator responsibility when `pr_strategy = stacked`)
- [ ] Compare URL generated (orchestrator responsibility when `pr_strategy = stacked`)
- [ ] Compare URL accessible

### Todowrite State
- [ ] No stale todowrite state (all items `completed` or cleared via `todowrite(todos=[])`)

### Documentation
- [ ] AI co-authored attribution in new files
- [ ] Module docstrings present
- [ ] No narration print statements

### URL Extraction (MANDATORY — Zero Tolerance)
- [ ] If outputting a post-creation URL (PR URL, Issue URL), the URL field MUST be copied verbatim from the API response's `html_url` field
- [ ] Do NOT retype, reconstruct, or assemble the URL from known values (org, repo, number)
- [ ] Paste the URL exactly as returned by the API — character for character
- [ ] Verification checkpoint: Compare the pasted URL character-by-character against the `html_url` field in the API response before sending

### Chat Output Format (MANDATORY — Zero Tolerance)
- [ ] Executive summary present as **first** chat output element (before any URL)
- [ ] Outcome line present after summary
- [ ] URL label is context-appropriate: "Compare URL" (pre-PR, `compare/$DEFAULT_BRANCH...`) or "PR URL" (post-PR, `pull/N`) — label and URL format MUST match; mismatch is a critical violation
- [ ] URL present (after summary, before byline)
- [ ] AI byline in format `🤖 <AgentName> (<ModelId>) <status>` appears **last** (after URL)
- [ ] No URL before executive summary (CRITICAL VIOLATION if violated)
- [ ] No byline before URL (CRITICAL VIOLATION if violated)

**This format applies to EVERY halt point where implementation is reported complete:**
- review-prep after implementation
- Sub-agent result reports from implementation-pipeline task()
- Phase boundary halts (merge gates between phases)
- Approval-gate post-implementation reports

**Evidence requirement:** Verify format by reviewing chat output before marking this checklist item complete. Assertions without reviewing the actual output are VERIFICATION-GAP findings.

**Auto-fix on failure:** If any element is missing or misordered, fix the output before proceeding. Missing elements are MISSING-ELEMENT (auto-fix). Wrong ordering is STRUCTURE-VIOLATION (auto-fix).

### Ready for PR?
- [ ] All checklist items pass
- [ ] Compare URL verified

### Issue Closure Verification
- [ ] Verify all issues referenced by the merged PR are closed on GitHub
- [ ] If issues remain open after verified merge, close them with a comment referencing the merged PR

### Post-Merge Cleanup Verification
- [ ] `skill({name: "git-workflow", args: "--task cleanup"})` invoked after PR merge confirmation (CRITICAL — skipping is a guideline violation)
- [ ] 🚫 FORBIDDEN: Reading cleanup task files into context and task()ing a generic sub-agent with custom step-by-step instructions. This is a critical-rules-048 violation. The ONLY permitted invocation is `skill({name: "git-workflow", args: "--task cleanup"})`.
- [ ] Local trunk branch synced with origin/$DEFAULT_BRANCH (trunk HEAD matches origin/$DEFAULT_BRANCH HEAD)
- [ ] Merged feature branch deleted (local and remote)
- [ ] No stale worktrees remaining from the merged branch

### Sub-Issue Linkage Verification
- [ ] If the plan has multiple phases, verify that `get_sub_issues` count on the plan issue matches the number of phases in the plan body. If counts don't match, run `issue-operations --task link-sub-issue` to create missing linkages before proceeding to review-prep
```

## What Skills MUST Check

- [ ] 1. **Before reporting readiness:**

   - Is working tree clean?
   - Do all quality checks pass?
   - Is branch pushed?
   - Is compare URL accessible?

- [ ] 2. **During preparation:**

   - Are there leftover debug prints?
   - Are there TODO/FIXME comments?
   - Are there unrelated changes?

## Context Required

- Related skills: `finishing-a-development-branch` (parent skill), `verification-before-completion` (evidence)
- Related tasks: `prepare`

## Live Verification: Checklist Evidence (MANDATORY)

**Each checklist item MUST be verified via tool call, not just checked off. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Checklist Item | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "All changes committed" | Verify clean working tree | `git status --porcelain` → check empty | VERIFICATION-GAP |
| "Branch pushed to remote" | Verify tracking branch exists | `git branch -vv` → check `[origin/<branch>]` | MISSING-ELEMENT |
| "Tests passing" | Run actual test command | `uv run pytest test/` → check exit code | VERIFICATION-GAP |
| "Lint passing" | Run actual lint command | `uvx ruff check src/ test/` → check exit code | VERIFICATION-GAP |
| "No debug prints" | Search for debug statements | \`grep(pattern="print\\( | debugger |
| "No TODO/FIXME" | Search for placeholder comments | \`grep(pattern="TODO | FIXME |
| "No unrelated changes" | Verify diff scope matches spec | `git diff "$DEFAULT_BRANCH" --name-only` → compare with spec files | CONFLICTING |

**Evidence artifact:** Tool call results for each checklist verification.

### Finding Classification

| Finding | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Uncommitted changes found | VERIFICATION-GAP | FAIL | Commit before proceeding |
| Branch not pushed | MISSING-ELEMENT | auto-fix | Push immediately |
| Lint/test failures | VERIFICATION-GAP | FAIL | HALT — fix issues before PR |
| Debug prints or TODOs found | STRUCTURE-VIOLATION | auto-fix | Remove before proceeding |
| Unrelated files in diff | CONFLICTING | FAIL | Report — scope may have deviated |
