# GitBucket Session Integration

## Overview

Session init script (`.opencode/tools/session-init`) provides GitBucket credentials from environment and git remote.

**Delegation:** Authentication workflow (login, credential validation, version pinning) is delegated to the `gb-cli` authenticate task card. This task retains session credential handling: detecting GitBucket from the remote URL and validating credential presence. Read [the gb-cli authenticate task card](../../../../gb-cli/tasks/authenticate.md).

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found"
  return 1
fi
```

## Session Init Detection

Session init script (`.opencode/tools/session-init`) detects GitBucket from remote URL and outputs:

```
github.platform: gitbucket
gitbucket.html_url: https://gitbucket.example.com/gitbucket/
gitbucket.has_credentials: true
```

**If `gitbucket.has_credentials=false`**, token is missing from `.env`.

## Validate Credentials

```bash
gb auth status
# Shows current auth status and effective actor
```

If authentication fails, delegate to the gb-cli authenticate task card. Read [the gb-cli authenticate task card](../../../../gb-cli/tasks/authenticate.md).

## Best Practices

- [ ] 1. **Use `gb auth login`** - Authenticate with token for persistent credentials
- [ ] 2. **Error handling** - Check `gb auth status` output for specific error types
- [ ] 3. **Cross-platform** - Config locations work on Linux, macOS, Windows
