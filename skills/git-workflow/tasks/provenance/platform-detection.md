# Task: provenance/platform-detection

## Purpose

Detect submodule host platform from remote URL and test API availability to determine provenance tracking tier. This is the prerequisite step for all provenance operations — it identifies where and how to track changes in the submodule's own repository.

## Entry Criteria

- Submodule has been pushed (for dev-push) or promoted (for promotion)
- Submodule remote URL is available via `git remote get-url origin`

## Exit Criteria

- Platform detected (github / gitbucket / unknown)
- API availability tested and classified into access levels
- Detection result cached for session duration
- No HALT or blocking of git workflow on failure

## Procedure

### Step 0: Platform Detection

Parse the remote URL to identify the hosting platform:

```python
def detect_submodule_platform(remote_url):
    # Extract hostname: git@<hostname>:<owner>/<repo>.git or https://<hostname>/...
    hostname = extract_hostname(remote_url)
    
    if hostname == "github.com":
        return {"platform": "github", "owner": owner, "repo": repo}
    elif is_gitbucket_pattern(hostname):  # non-github with /owner/repo pattern
        return {"platform": "gitbucket", "owner": owner, "repo": repo}
    else:
        return {"platform": "unknown", "owner": owner, "repo": repo}
```

URL parsing patterns:
- `git@github.com:owner/repo.git` → `github.com`
- `https://github.com/owner/repo.git` → `github.com`
- `git@gitbucket.example.com:owner/repo.git` → `gitbucket`
- `https://internal.example.com/git/owner/repo.git` → `gitbucket` (non-standard)
- Unknown patterns → `unknown`

### Step 1: Test API Availability

Test the detected platform's API to determine access level:

**GitHub:**
```python
github_get_file_contents(owner=<owner>, repo=<repo>, path="")
# Map errors:
# HTTP 403 → access_level: "no-access"
# HTTP 404 → access_level: "no-repo"
# Auth error → access_level: "auth-failed"
# Success → access_level: "full"
```

**GitBucket:**
```python
./.opencode/tools/gitbucket-api get-repo <owner> <repo>
# Map errors similarly to GitHub
```

**Unknown platform:**
```
→ {platform: "unknown", access_level: "no-access", reason: "unsupported platform"}
```

### Step 2: Cache Detection Result

Cache the detection result for the remainder of the session:

```python
detection_cache[owner_and_repo] = {
    "platform": platform,
    "access_level": access_level,
    "reason": reason,
    "detected_at": timestamp
}
```

Cache key format: `<owner>/<repo>`
Cache is session-scoped — resets when the agent session ends.

### Step 3: Report Detection Result

Report the detection outcome:

```
Platform Detection: <github | gitbucket | unknown>
Access Level: <full | issue-only | no-access | auth-failed | no-repo>
Provenance Tier: <1 | 2 | 3>

Submodule: <owner>/<repo>
Remote: <remote_url>
```

If detection produced unexpected results:
- `unknown` platform → report silently, proceed with Tier 3
- API errors → report silently, proceed with fallback tier

## Access Level Semantics

| Level | Meaning | Provenance Tier | Action |
| -- | -- | -- | -- |
| `full` | Issue + PR creation available | Tier 1 | Create issue + PR in submodule repo |
| `issue-only` | Issue creation works, PR fails | Tier 2 | Create issue only in submodule repo |
| `no-access` | No API access (HTTP 403) | Tier 3 | Commit message as provenance record |
| `auth-failed` | Authentication error | Tier 3 | Commit message as provenance record |
| `no-repo` | Repository not found | Tier 3 | Commit message as provenance record |

## Acceptance Criteria

| ID | Criterion |
| -- | -- |
| P10 | Platform detection parses URLs correctly (github.com, gitbucket, unknown) |
| P11 | Error handling maps errors to access levels correctly |
| P12 | Detection results cached for session duration |
| P13 | Three-tier classification accurate |

## Common Issues

| Issue | Resolution |
| -- | -- |
| Non-standard URL format | Best-effort parsing; classify as unknown if unrecoverable |
| API rate limited | Treat as no-access, fall back to Tier 3 |
| Submodule has no remote | Classify as unknown platform |
| Network timeout during API test | Treat as no-access, fall back to Tier 3 |
| Self-hosted GitHub Enterprise | Parsed by hostname matching, otherwise unknown |

## Context Required

- Related tools: `github_*` MCP tools, `.opencode/tools/gitbucket-api`
- Related tasks: `provenance/dev-push-provenance`, `provenance/promotion-provenance`