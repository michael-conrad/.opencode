# Task: sub-issue-collection

## Purpose

Fetch sub-issues for a parent issue and build the issue-reference list for the PR body.

## Procedure

### Detect Branch Type

First, detect whether this is a single-issue or work PR:

```bash
# Check if work state file exists
ls {project_root}/tmp/{issue-N}/work.md 2>/dev/null

# If exists → work PR format
# If not exists → single/multi-task PR format
```

**PR strategy check (from scope fields):** Read `pr_strategy` from the work state file. When `pr_strategy == stacked`, use work PR format regardless. When `pr_strategy == none`, HALT — PR creation not authorized.

**Note:** GitHub autoclose (`Fixes #N`/`Closes #N`) does NOT trigger for PRs merging into the trunk. The cleanup task (`git-workflow --task cleanup`) is the sole closure mechanism. PR body keywords are informational labels for human readers.

### Multi-Task Spec with Sub-Issues

- [ ] 1. **Fetch sub-issues:**
   ```python
   sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=<parent>) <!-- Routes through issue-operations per SPEC #683 -->
   ```

- [ ] 2. **Build issue-reference list:** parent + all sub-issues
   ```python
   issue_reference_list = [<parent>] + [sub["number"] for sub in sub_issues]
   ```

- [ ] 3. **Include ALL issues in PR body using closing-keywords task:**
   Use `pr-creation-workflow` → `task("execute closing-keywords from pr-creation-workflow")` to format closing keyword lines. Determine repo ownership for each issue:
   - Issues in the same repo as the PR → `Fixes #N`
   - Issues in a different repo (e.g., submodule issues) → `Fixes owner/repo#N`
   ```markdown
   ## Summary
   <description of what changed>

   Fixes #<parent>
   Fixes #<child1>
   Fixes owner/repo#<child2>
   ```

### Work PR

For work PRs (assembled from multiple issues via the implementation-pipeline per the SKILL.md Trigger Dispatch Table):

- [ ] 1. **Read work state file** (`{project_root}/tmp/{issue-N}/work.md`) to get list of all issues in the work
- [ ] 2. **Build both sections:**
   - `## Work Issues` section listing each issue with its description
   - `Fixes #N` annotations for all issues at the bottom (use `pr-creation-workflow` → `task("execute closing-keywords from pr-creation-workflow")` to format)

```markdown
**Summary:**

<1-2 sentences describing the overall impact of the work>

**Outcome:** All approvals now follow one consistent workflow: sub-issue expansion → implementation-pipeline per the SKILL.md Trigger Dispatch Table → work branch → single PR.

## Work Issues

#660 — Add pre-implementation analysis task
#662 — Fix work branch squash verification
#621 — Collapse executing-plans into divide-and-conquer

Fixes #660
Fixes owner/repo#662
Fixes #621
```

### Multi-Task Spec WITHOUT Sub-Issues

If `get_sub_issues` returns empty for a multi-task spec, this is a CRITICAL VIOLATION — sub-issues should have been created before implementation. Halt and create sub-issues first.

## Example PR Bodies

**Single-task:**
```markdown
## Summary
Add OAuth2 authentication to the API layer.

Fixes #42
```

**Multi-task:**
```markdown
## Summary
Implement user authentication feature: database schema, API endpoints, and UI components.

Fixes #100
Fixes #101
Fixes #102
Fixes #103
```

**Work:**
```markdown
**Summary:**

Unified five approved issues into a single work implementation, eliminating forked execution paths.

**Outcome:** All approvals now follow one consistent workflow: sub-issue expansion → implementation-pipeline per the SKILL.md Trigger Dispatch Table → work branch → single PR.


## Work Issues

#660 — Add pre-implementation analysis task
#662 — Fix work branch squash verification
#621 — Collapse executing-plans into divide-and-conquer

Fixes #660
Fixes owner/repo#662
Fixes #621
```

## After PR Creation

- Report URL in chat ONLY (never to GitHub Issues)
- HALT — wait for human to merge
- Never merge PRs — HUMAN-ONLY operation