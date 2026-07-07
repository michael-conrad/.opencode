# RED Phase Test - Issue #1712

## Test: PR creation flow does NOT use `state=open` filter (RED)

### Test File
`.opencode/.issues/1712/tests/red-phase.sh`

### Test Purpose
Verify that the agent currently does NOT use `state=open` filter when checking existing PRs, causing it to re-open closed PRs instead of creating fresh ones.

### Test Steps

1. **Setup**: Create a test scenario where a closed PR exists on the branch
2. **Action**: Agent is asked to create a fresh PR for the issue
3. **Verify RED**: Confirm the agent:
   - Queries GitHub WITHOUT `state=open` filter (current buggy behavior)
   - Attempts to re-open or re-use the closed PR (current buggy behavior)
   - Does NOT create a fresh PR

### Expected RED Result
Agent SHOULD:
- Find the closed PR on the branch
- Attempt to re-open it or use it
- NOT create a new PR

### Test Command
```bash
# This test should FAIL (exit code != 0) because the bug exists
bash .opencode/.issues/1712/tests/red-phase.sh
```

### RED Exit Criteria
- [ ] Test file created at `.opencode/.issues/1712/tests/red-phase.sh`
- [ ] Test confirms agent does NOT use `state=open` filter
- [ ] Test confirms agent attempts to re-open closed PR
- [ ] Test FAILS (exit code != 0) — this is the RED state

### Notes
- This is a behavioral test — it verifies the agent's actual behavior
- The test should FAIL because the bug exists (RED state)
- After GREEN (implementation), the test should PASS
