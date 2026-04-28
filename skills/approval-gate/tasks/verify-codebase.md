# Task: verify-codebase

## Purpose

Re-evaluate codebase state before implementation to detect staleness or superseding issues. This task prevents implementing a spec that references files, functions, or APIs that no longer exist or have changed since the spec was written.

## Entry Criteria

- Authorization verified
- Sub-issues verified (if applicable)

## Exit Criteria

- Files mentioned in spec still exist at specified paths
- Referenced code is still valid (signatures match)
- No changes since spec written (or changes documented and accepted)
- No superseding issues found

## Procedure

### Step 1: Check File Existence

For each file mentioned in spec:
- Verify file still exists at specified path using `glob` or `read`
- Document any missing files
- If a file has been moved or renamed, search for its new location

```bash
# Check each file referenced in the spec
for file in <spec-referenced-files>; do
    if [ ! -f "$file" ]; then
        echo "MISSING: $file"
    fi
done
```

Missing files may indicate:
- The spec is stale (code has been refactored)
- The spec was written against a different branch
- Files were deleted after the spec was created

### Step 2: Check Code Validity

For each code reference in the spec:
- Verify function/class still exists using `srclight_get_signature` or `srclight_search_symbols`
- Verify signature matches spec expectations
- Document any changes

```python
# For each symbol referenced in the spec
symbol = srclight_get_signature(name="function_name")
if symbol is None:
    report("Symbol 'function_name' not found in codebase")
elif symbol != spec_signature:
    report("Signature mismatch for 'function_name'")
```

Key checks:
- Function parameters match (names and types)
- Return types match
- Class methods still exist
- Module imports are valid

### Step 3: Check for Superseding Issues

Search for newer issues that may supersede or conflict with the current spec:

```python
# Query for later issues that may supersede
issues = github_list_issues(owner=<github.owner>, repo=<github.repo>, state="open")
for issue in issues:
    if "[SPEC]" in issue["title"] and issue["number"] > current_spec:
        # Check if superseding
        if issue_supersedes_current(issue, current_spec):
            HALT("Superseding issue found: #{}".format(issue["number"]))
```

A superseding issue exists when:
- A newer spec covers the same scope with updated requirements
- A newer spec explicitly references and replaces the current spec
- The current spec's requirements are wholly subsumed by a newer spec

### Step 4: Handle Staleness

If staleness detected:
- **REVISE** the spec to reflect current reality
- **HALT** and wait for fresh approval
- **NEVER** implement a stale spec as-is

Staleness resolution options:
1. Update spec with current file paths and function signatures
2. Mark spec as revised with `STATUS: X.Y (REVISED - NEEDS APPROVAL)`
3. Wait for developer to approve the revised spec

## Staleness Indicators

| Indicator | Action |
|-----------|--------|
| File moved/renamed | Update spec with new location, flag as revised |
| Function signature changed | Update spec with new signature, flag as revised |
| Dependency updated | Update spec with new dependency version, flag as revised |
| Related spec implemented | Check if current spec is still needed |
| File deleted | Determine if spec is still valid without the file |
| New superseding spec created | HALT and report conflict |

## Adversarial Verification: Codebase State Claims

**Before trusting that files exist or code is valid as claimed, verify against actual filesystem and codebase state — not spec text claims, not cached results from earlier sessions.**

### Verification Checklist

- **File existence:** Use `glob` or `read` to verify each file mentioned in the spec exists at its specified path. If missing → VERIFICATION-GAP (flag-for-review).
- **Code references:** Use `srclight_get_signature` or `srclight_search_symbols` to verify each symbol mentioned in the spec exists and signatures match. If mismatch → CONFLICTING (flag-for-review).
- **Superseding issues:** Use `github_issue_read` to verify each candidate superseding issue is still open and covers the current spec's scope. Closed as `not_planned` → NOT superseding.
- **Staleness:** Use `srclight_recent_changes` or `git log --since=<spec-date>` to verify referenced files are unchanged since spec creation. If changed → VERIFICATION-GAP (conditional: re-verify).

## Enforcement References

- Evidence format + finding classification: see `enforcement/adversarial-verification.md`
- Scope parsing: see `enforcement/scope-parsing.md`
- Closed-issue verification: see `enforcement/closed-issue-verification.md`

## Context Required

- Related tasks: `verify-authorization`, `verify-blockers`
- `065-verification-honesty.md`: Verification claims must be backed by tool call evidence
- `spec-auditor --task ground-truth`: Adversarial verification model for metadata claims