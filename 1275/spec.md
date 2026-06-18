# [SPEC-FIX] check-pr Phase 3: live-verify issue references, cross-cutting interdependency scan, supersession check

## Defect

`check-pr.md` Phase 3 (Close Linked Issues) searches the wrong direction — it queries for issues referencing the PR number. The actual relationship is the reverse: PR bodies and commit messages contain `#N` references to issues. Additionally, the phase has no live-verification, no cross-cutting interdependency scan, and no supersession check.

## Required Phase 3 Procedure

### Step 3.1: Extract Issue References from PR Body
### Step 3.2: Extract Issue References from Commit Messages
### Step 3.3: Extract Issue References from Verification/Audit Artifacts
### Step 3.4: Deduplicate Candidate List
### Step 3.5: Live-Verify Each Candidate Issue
### Step 3.6: Cross-Cutting Interdependency Scan
### Step 3.7: Supersession Check
### Step 3.8: Close Eligible Issues Depth-First

## Bright-Line Rules

**RULE:** Every issue reference MUST be live-verified before closure.
**RULE:** An issue that is not 100% completed but appears it should have been MUST be reported to the developer.
**RULE:** Supersession check searches for issues that the candidate supersedes, NOT issues that supersede the candidate.

## Affected File

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/tasks/check-pr.md` | Replace Phase 3 single step with 8-step procedure above |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Phase 3 extracts `#N` references from PR body without requiring `Fixes`/`Closes` prefix | `string` | grep for `#N` or `issue_number` extraction pattern in Phase 3 |
| SC-2 | Phase 3 extracts `#N` references from all commits in each merged PR | `string` | grep for `get_commits` or commit message scan in Phase 3 |
| SC-3 | Phase 3 searches `./tmp/`, `./issues/`, `./*/.issues/` for verification/audit artifacts | `string` | grep for `./tmp`, `./issues/` scan patterns in Phase 3 |
| SC-4 | Phase 3 live-verifies each candidate issue via API before closure | `behavioral` | `opencode-cli run` — agent given merged PR with issue reference, verify agent reads issue via API before closing |
| SC-5 | Phase 3 alerts developer when issue is not 100% completed but appears it should have been | `behavioral` | `opencode-cli run` — agent given merged PR referencing an incompleted issue, verify agent reports discrepancy without closing |
| SC-6 | Phase 3 performs cross-cutting interdependency scan (sub-issues, siblings, parent, shared concern) | `behavioral` | `opencode-cli run` — agent given merged PR with sub-issue structure, verify agent checks related issues |
| SC-7 | Phase 3 supersession check searches for issues the candidate supersedes, not vice versa | `string` | grep for supersession direction in Phase 3 — only superseded-issue check present |
| SC-8 | Phase 3 closes eligible issues depth-first (sub-repos first, children before parents) | `string` | grep for depth-first closure ordering in Phase 3 |
