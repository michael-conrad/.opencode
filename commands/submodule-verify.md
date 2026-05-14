# submodule-verify

Verify all submodule hashes are reachable via tags or ancestry before PR creation.

## Procedure

1. Read submodule SHAs from parent repo: `git ls-tree HEAD <submodule-path>`
2. For each SHA: `git tag --contains <sha>` — if output is empty, SHA is UNREACHABLE
3. Report per-hash: PASS (tag found) or FAIL (unreachable)
4. No auto-remediation — report only
5. Block PR if any FAIL

## Report Format

```
<submodule-path> @ <sha>: PASS | FAIL
```

## Verification

```bash
git ls-tree HEAD .opencode
git tag --contains <sha>
```
