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

## Credential Sources (Priority Order)

Credentials are loaded in this order:

- [ ] 1. **gb config file** (`~/.config/gb/config.toml`)
   ```toml
   default_host = "https://gitbucket.example.com/gitbucket/"
   [hosts."https://gitbucket.example.com/gitbucket/"]
   token = "your-personal-access-token"
   user = "alice"
   protocol = "https"
   ```



## Authenticate

```bash
# Login with token
gb auth login -H https://gitbucket.example.com/gitbucket/
```

## Validate Credentials

```bash
gb auth status
# Shows current auth status and effective actor
```

## Credential Validation

```bash
# Validate token works
gb auth status
```

## Best Practices

- [ ] 1. **Use `gb auth login`** - Authenticate with token for persistent credentials
- [ ] 2. **Error handling** - Check `gb auth status` output for specific error types
- [ ] 3. **Cross-platform** - Config locations work on Linux, macOS, Windows
