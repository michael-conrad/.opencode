---
name: submodule-verify
description: Verify that all referenced submodule hashes are reachable via tags or branches (liveness check). Invoked during pr-creation enforcement-gate Step 0. This is verification ONLY — no auto-remediation. ALL git operations are dispatched to this sub-agent.
type: sub-agent-command
provenance: AI-generated
compatibility: opencode
---

# Command: submodule-verify

## Purpose

Verify that all submodule hashes referenced in the parent repo are reachable via tags or branches in their respective submodule remotes. This is a liveness check that ensures every submodule SHA can be fetched from upstream — it does NOT auto-remediate or advance submodule pointers.

## Operating Protocol

1. **Mandatory invocation during PR enforcement gate:** This command is invoked by `pr-creation/enforcement-gate` Step 0
2. **Verification ONLY:** This command NEVER modifies any submodule state. It is read-only verification.
3. **Sub-agent dispatch:** The main agent dispatches this command; all git operations run in a clean sub-agent context

## Entry Criteria

- `.gitmodules` exists in the repository
- PR creation is authorized

## Exit Criteria

- Every submodule hash referenced in the parent repo is reachable via a tag or branch
- Result contract provides per-submodule reachability status
- If ANY hash is unreachable: status is BLOCKED with specific failure information

## Procedure

### Step 1: Enumerate Submodules and Collect Referenced SHAs

```bash
git submodule status
```

For each submodule line, extract:
- Path (second field or from `.gitmodules`)
- Referenced SHA (first field, after the `-` prefix if present)

```bash
git ls-tree HEAD -- <submodule-path> | awk '{print $3}'
```

### Step 2: Check Reachability of Each SHA

For each submodule with its referenced SHA:

```bash
cd <submodule-path>

# Fetch all tags and branches from remote
git fetch origin --tags

# Check if SHA is reachable from the pre-work tag
git tag --contains <sha> | grep -q "^<parent-repo>/<issue-number>" && echo "REACHABLE via pre-work tag" || {
    # Check if SHA is reachable from the feature tag
    git tag --contains <sha> | grep -q "^<parent-repo>/<issue-number>-<sub>" && echo "REACHABLE via feature tag" || {
        # Check if SHA is reachable from dev branch
        git branch --contains <sha> | grep -q "dev" && echo "REACHABLE via dev branch" || {
            # Check if SHA is reachable from any other ref
            git tag --contains <sha> | head -1 && echo "REACHABLE via other ref" || echo "UNREACHABLE"
        }
    }
}

cd <parent-repo-root>
```

### Step 3: Classify Results

For each submodule:

| Reachability | Status | Action |
| -- | -- | -- |
| Reachable via pre-work tag `<parent-repo>/<issue-number>` | ✅ PASS | Proceed |
| Reachable via feature tag `<parent-repo>/<issue-number>-<sub>` | ✅ PASS | Proceed |
| Reachable via `dev` branch or any other branch | ✅ PASS | Proceed |
| Reachable via any tag | ✅ PASS | Proceed |
| NOT reachable by any tag or branch | ❌ FAIL | BLOCK PR creation |

### Step 4: Report

If ALL submodule hashes are reachable: Return DONE with per-submodule evidence.

If ANY submodule hash is unreachable: Return BLOCKED with specific failure information.

**There is NO auto-remediation.** If a hash is unreachable, the developer must resolve it manually (e.g., by pushing the missing tags or updating the submodule reference).

## Result Contract

```yaml
status: DONE | BLOCKED
task: submodule-liveness-check
submodule_results:
  - path: <submodule-path>
    committed_sha: <sha>
    reachable: bool
    reachable_via: <tag-name or ref-name or "unreachable">
evidence_artifacts:
  - tool: git ls-tree HEAD <path>
    output: <sha>
  - tool: git tag --contains <sha>
    output: <tag list>
```

## CRITICAL: No Auto-Remediation

The liveness check is verification only. The agent MUST NOT:
- Advance submodule pointers to `origin/dev`
- Create bump commits for submodule SHA changes
- Run `git submodule foreach "git checkout origin/dev"`
- Modify any submodule state as part of this check

If liveness verification fails, report the failure and BLOCK PR creation. The developer must resolve the unreachable hash manually.

## Context Required

- `github.owner`, `github.repo`: From session init
- Parent repo short name: Derived from repository name
- `issue_number`: From authorization context
- Submodule paths: From `.gitmodules`