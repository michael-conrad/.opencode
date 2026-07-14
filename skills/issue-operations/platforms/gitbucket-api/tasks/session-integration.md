# GitBucket Session Integration

## Overview

Session init script (`.opencode/tools/session-init`) provides GitBucket credentials from environment and git remote.

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found"
  return 1
fi
```

## Authenticate

```bash
gb auth login -H https://gitbucket.example.com/gitbucket/
```

## Validate Credentials

```bash
gb auth status
# Shows current auth status and effective actor
```

## Best Practices

- [ ] 1. **Use `gb auth login`** - Authenticate with token for persistent credentials
- [ ] 2. **Error handling** - Check `gb auth status` output for specific error types
- [ ] 3. **Cross-platform** - Config locations work on Linux, macOS, Windows
