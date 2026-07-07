# RED Phase Tests for Issue #1712

## SC-1: PR creation flow queries GitHub with `state=open` filter

**Evidence Type:** `behavioral`
**Test Method:** `opencode-cli run`

### Test Prompt

```
The branch has an existing closed PR. Create a fresh PR for this issue.
```

### Expected Behavior

The agent should query GitHub with `state=open` filter when checking for existing PRs. If only closed PRs exist, it should create a new PR rather than reopening the closed one.

### Assertion

```bash
assert_semantic "SC-1" "Agent queries GitHub with state=open filter when checking existing PRs, and creates a new PR when only closed PRs exist on the branch"
```

---

## SC-2: Closed PRs on the branch do not trigger re-open logic

**Evidence Type:** `behavioral`
**Test Method:** `opencode-cli run`

### Test Prompt

```
Close the existing PR for this issue. Then say "create a PR" to create a fresh one.
```

### Expected Behavior

The agent should NOT reopen the closed PR. It should create a new PR with fresh code.

### Assertion

```bash
assert_semantic "SC-2" "Agent does not reopen closed PR; creates fresh PR instead"
```

---

## SC-3: Developer must explicitly say "use the closed PR" for it to be considered

**Evidence Type:** `behavioral`
**Test Method:** `opencode-cli run`

### Test 1: Without explicit instruction

**Prompt:**

```
There's a closed PR on this branch. Create a PR for this issue.
```

**Expected:** Agent creates a NEW PR (not reopens closed one)

**Assertion:**

```bash
assert_semantic "SC-3a" "Agent creates fresh PR without explicit 'use the closed PR' instruction"
```

### Test 2: With explicit instruction

**Prompt:**

```
Use the closed PR for this issue.
```

**Expected:** Agent considers the closed PR

**Assertion:**

```bash
assert_semantic "SC-3b" "Agent considers closed PR when explicitly told 'use the closed PR'"
```

---

## SC-5: No regression in existing PR update behavior (open PRs on branch still get updated)

**Evidence Type:** `behavioral`
**Test Method:** `opencode-cli run`

### Test Prompt

```
There's an open PR on this branch. Push new commits and update the PR.
```

### Expected Behavior

The agent should update the existing open PR (push new commits), not create a new one.

### Assertion

```bash
assert_semantic "SC-5" "Agent updates existing open PR instead of creating new one"
```
