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
- [ ] **Canonical commit rule:** the branch resolves to exactly one squashed commit per issue; the squashed commit carries dual co-author trailers (AI + human) per the canonical rule stated consistently across the PR/squash/enforcement/finishing gates
- [ ] Co-authored-by trailers present on the squashed commit — on an agent-created, unmerged, unshared feature branch, absence is an auto-fixable MISSING-ELEMENT (agent adds dual co-author trailers and force-pushes with `--force-with-lease`); it is NOT a decision-requiring blocker. On a shared, merged, or trunk branch, trailer absence defers to the generic force-push authorization gate.

### Agent-Owned Trailer Remediation (MISSING-ELEMENT auto-fix)

When the "Co-authored-by trailers present" item finds missing trailers on the agent's own, unmerged, unshared feature branch, the producing agent SHALL self-remediate without soliciting a developer force-push decision:

1. **Amend or squash the agent's own commits** to add the repo-standard two-trailer format from `commit-prep.md`:
   ```bash
   git commit --amend --no-edit \
       --trailer "Co-authored-by: <AgentName> (<ModelId>) <noreply@example.com>" \
       --trailer "Co-authored-by: <dev.name> <dev.email>"
   ```
   For multiple commits, use `git rebase -i` to squash/reword the agent's own commits and add the trailers.
2. **Force-push the agent's own branch with `--force-with-lease` only**:
   ```bash
   git push --force-with-lease origin HEAD:<branch_name>
   ```
   `--force` is FORBIDDEN (R-4). The `--force-with-lease` push is authorized only because the branch is the agent's own, unmerged, and unshared.
3. **Do NOT solicit a developer force-push decision.** The remediation is agent-owned; the generic force-push authorization gate does not apply to the agent's own unmerged, unshared branch.
4. **Reuse the repo-standard trailer format** — no alternative trailer schema is introduced.

### Agent-Owned Branch Scope Guard (MANDATORY)

The auto-force-push carve-out above is confined STRICTLY to the agent's own, unmerged, unshared feature branch. The producing agent SHALL verify all three conditions before any `--force-with-lease` push:

1. **Agent's own branch** — the branch was created by this agent for this work; it is not a branch another developer created or shares.
2. **Unmerged** — the branch has not been merged into the trunk.
3. **Unshared** — the branch has not been pushed to a shared remote or shared with another developer.

On a **shared, merged, or trunk branch**, the checklist SHALL **refuse auto-force-push** and defer to the generic force-push authorization gate (`000-critical-rules.md`). The auto-force-push carve-out does NOT apply; the producing agent MUST NOT amend/squash-and-force-push without explicit developer authorization. This scope guard does not weaken the generic force-push authorization gate — it only confines the agent-owned carve-out to the agent's own, unmerged, unshared branch.

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
- [ ] AI co-authored attribution in new files — a missing "Co-authored with AI:" footer byline in a new file is an auto-fixable MISSING-ELEMENT: the producing agent adds the missing footer byline, preserving any existing bylines; it is NOT escalated as a decision-requiring blocker.

### Footer Byline Auto-Fix (MISSING-ELEMENT auto-fix)

When the "AI co-authored attribution in new files" item finds a new file missing the "Co-authored with AI:" footer byline, the producing agent SHALL auto-fix it without escalating to the developer:

1. **Add the missing footer byline** to the new file, using the repo-standard format from `080-code-standards.md`:
   ```markdown
   *Co-authored with AI: <AgentName> (<ModelId>)*
   ```
2. **Preserve any existing bylines** — never overwrite or remove a prior agent's byline (080-code-standards R-5). If editing a file that already has a `Co-authored with AI:` line, append the producing agent's byline on a new line rather than replacing.
3. **Do NOT weaken the mandatory co-author attribution requirement (R-7).** The auto-fix adds the missing byline; it never skips the attribution check.
4. **Do NOT escalate byline absence as a decision-requiring blocker.** The remediation is agent-owned.

### Module Docstrings
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
- Sub-agent result reports from plan execution
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
- [ ] Dispatch `git-workflow --task cleanup` after PR merge confirmation (CRITICAL — skipping is a guideline violation)
- [ ] 🚫 FORBIDDEN: Reading cleanup task files into context and task()ing a generic sub-agent with custom step-by-step instructions. This is a critical-rules-048 violation. The ONLY permitted invocation is dispatching `git-workflow --task cleanup`.
- [ ] Local trunk branch synced with origin/$DEFAULT_BRANCH (trunk HEAD matches origin/$DEFAULT_BRANCH HEAD)
- [ ] Merged feature branch deleted (local and remote)
- [ ] No stale worktrees remaining from the merged branch

### Sub-Issue Linkage Verification
- [ ] Sub-issues are NEVER created at branch-finishing time — plan-phase sub-issues are created before implementation only,
  never retrospectively at finishing
- [ ] If plan-phase sub-issues exist, treat them as read-only references — do NOT create, link, or modify them at finishing
  time
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
| Missing Co-authored-by trailers on agent-own unmerged branch | MISSING-ELEMENT | auto-fix | Agent adds trailers and force-pushes with `--force-with-lease` — do NOT solicit a developer force-push decision (see Agent-Owned Trailer Remediation) |
| Missing Co-authored-by trailers on shared/merged/trunk branch | MISSING-ELEMENT | FAIL | Refuse auto-force-push and defer to generic force-push authorization gate (see Agent-Owned Branch Scope Guard) |
