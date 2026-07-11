# Plan: Reinforce substantive comment gate in skill descriptions

**Spec:** #1861 — [SPEC-FIX] Reinforce substantive comment gate in issue-operations and correspondence skill descriptions
**Authorization scope:** `for_pr`
**Phases:** 1 (single-task plan)

---

## Goal

Add substantiveness gate reinforcement to `issue-operations/SKILL.md` description and audience separation reinforcement to `correspondence/SKILL.md` description, plus a behavioral test verifying the agent does not post non-substantive comments to GitHub Issues.

## Architecture

Three independent changes:
1. **issue-operations/SKILL.md** — Add a clause to the YAML frontmatter `description` field that gates comment posting behind the substantiveness check
2. **correspondence/SKILL.md** — Add a clause to the YAML frontmatter `description` field that reinforces audience separation (internal vs stakeholder)
3. **tests/behaviors/** — New behavioral test that verifies the agent does NOT post non-substantive progress updates to GitHub Issues

## Files to Modify

| File | Change |
|------|--------|
| `skills/issue-operations/SKILL.md` | Add substantiveness gate clause to `description` field in YAML frontmatter |
| `skills/correspondence/SKILL.md` | Add audience separation reinforcement to `description` field in YAML frontmatter |
| `tests/behaviors/comment-churn-regression.sh` | New behavioral test file |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | issue-operations description includes substantiveness gate clause | 1 | 1.1 |
| SC-2 | correspondence description reinforces audience separation | 1 | 1.2 |
| SC-3 | Agent does NOT post non-substantive progress updates (behavioral) | 1 | 1.3 |
| SC-4 | Agent still posts substantive comments (behavioral) | 1 | 1.3 |

## Phase 1 — Description updates + behavioral test

### Step 1.1: Update issue-operations/SKILL.md description

**Action:** Edit the YAML frontmatter `description` field in `skills/issue-operations/SKILL.md` to append a substantiveness gate clause.

**Current description:**
```
"Issue operations dispatcher that routes to GitHub MCP or GitBucket API based on github.platform. Dispatch when creating, commenting on, or closing GitHub Issues. Also dispatch when adding labels, managing sub-issues, or routing to platform-specific implementations. Issue tracking is REQUIRED. User phrases: create issue, comment on issue, close issue, add label, manage sub-issue, link sub-issue."
```

**Required change:** Add a clause after the "Dispatch when" sentence that gates comment posting behind the substantiveness check. The clause should read something like: "Comment posting is gated by the substantiveness check in the comment task — non-substantive progress updates (status updates, phase complete, implemented X) MUST NOT be posted to GitHub Issues."

**Verification:** `grep` for "substantive" in `skills/issue-operations/SKILL.md` description field.

### Step 1.2: Update correspondence/SKILL.md description

**Action:** Edit the YAML frontmatter `description` field in `skills/correspondence/SKILL.md` to append an audience separation reinforcement clause.

**Current description:**
```
"Stakeholder communication drafter for emails, status updates, and external correspondence. Dispatch when drafting stakeholder emails, status updates, or external communications. Also dispatch when analyzing audience context, maintaining audience separation, or generating structured correspondence. Audience separation MUST be maintained — always required. User phrases: draft email, write stakeholder update, external communication, audience analysis, status report."
```

**Required change:** Add a clause that reinforces audience separation — internal audit findings and raw status updates go to chat, not to stakeholder channels. Something like: "Internal audit findings and raw status updates go to chat only — never to stakeholder channels."

**Verification:** `grep` for "audience separation" or "internal" in `skills/correspondence/SKILL.md` description field.

### Step 1.3: Create behavioral test for comment-churn regression

**Action:** Create `tests/behaviors/comment-churn-regression.sh` that:
1. Sends a prompt simulating a non-substantive progress update scenario (e.g., "Phase 1 is complete, posting update to issue #NN")
2. Verifies the agent does NOT call `github_add_issue_comment` or `github_issue_write` for comment posting
3. Sends a prompt simulating a substantive comment scenario (e.g., "Found a blocker, need to report it on issue #NN")
4. Verifies the agent DOES call `github_add_issue_comment` for substantive comments

**Verification:** Run `bash .opencode/tests/behaviors/comment-churn-regression.sh` and confirm PASS.

### Step 1.4: Commit and push

**Action:** Commit all three changes together with message: `"feat: reinforce substantive comment gate in skill descriptions (#1861)"`

## Safety/Rollback

No destructive operations in this phase. All changes are text edits to SKILL.md descriptions and a new test file. Rollback: `git checkout -- skills/issue-operations/SKILL.md skills/correspondence/SKILL.md && rm tests/behaviors/comment-churn-regression.sh`

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `skills/issue-operations/SKILL.md` | ✅ | Read in session |
| 1.2 | `skills/correspondence/SKILL.md` | ✅ | Read in session |
| 1.3 | `tests/behaviors/` | ✅ | Glob confirmed directory exists |

## Exit Criteria

- [ ] SC-1: issue-operations description contains substantiveness gate clause
- [ ] SC-2: correspondence description contains audience separation reinforcement
- [ ] SC-3: Behavioral test passes — agent does NOT post non-substantive comments
- [ ] SC-4: Behavioral test passes — agent DOES post substantive comments
- [ ] All changes committed to feature branch
