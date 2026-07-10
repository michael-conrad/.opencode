# Phase 9: Verify and Close Stale Open Issues

## SCs

- **SC-16**: #1229 verified as fully implemented and closed (behavioral)
- **SC-17**: #1064 verified as fully implemented and closed (behavioral)

## Steps

- [ ] 1. **Verify #1229** — Call `github_issue_read(method=get, issue_number=1229, owner=michael-conrad, repo=.opencode)`:
  - Check state. If already closed: verify implementation evidence exists in body/comments.
  - If open: read full issue body and comments. Verify each success criterion against codebase state.
  - If fully implemented: call `github_issue_write(method=update, issue_number=1229, state=closed, state_reason=completed)`
  - Document verification evidence in `.opencode/.issues/1834/stale-issue-closure-evidence.md`
- [ ] 2. **Verify #1064** — Call `github_issue_read(method=get, issue_number=1064, owner=michael-conrad, repo=.opencode)`:
  - Same procedure as #1229.
  - If fully implemented: close with reason `completed`.
  - Document verification evidence.
- [ ] 3. **VbC** — SC-16: `github_issue_read(method=get, issue_number=1229)` → state is closed AND implementation evidence exists. SC-17: same for #1064.
- [ ] 4. **Commit** — `git commit -am "phase-9: verify and close stale issues #1229 #1064 (#1834)"`
