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

- [ ] 1. **Environment variables**
   ```bash
   export GB_HOST=https://gitbucket.example.com/gitbucket/
   export GB_TOKEN=your-token
   export GB_USER=username
   export GB_PASSWORD=password
   ```

- [ ] 2. **Project .env file** (`<project>/.env`)
   ```bash
   # .env
   GB_HOST=https://gitbucket.example.com/gitbucket/
   GB_TOKEN=your-token
   GB_USER=username
   GB_PASSWORD=password
   ```

- [ ] 3. **gb config file** (`~/.config/gb/config.toml`)
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

# Or set environment variables
export GB_TOKEN=your-token
export GB_HOST=https://gitbucket.example.com/gitbucket/
```

## Validate Credentials

```bash
gb auth status
# Shows current auth status and effective actor
```

## Environment Variables

GitBucket credentials come from `.env` file:

```bash
# .env
GB_HOST=https://gitbucket.example.com/gitbucket/
GB_TOKEN=your-personal-access-token
GB_USER=username
GB_PASSWORD=password
```

**Token vs Basic Auth:**

| Method | Use Case | Environment Variables | Status |
|--------|----------|----------------------|--------|
| Token | All operations | `GB_TOKEN` | ✅ Working |
| Basic | Web fallback | `GB_USER`, `GB_PASSWORD` | ✅ Working (web fallback) |

## Credential Validation

```bash
# Validate token works
gb auth status
```

## Best Practices

- [ ] 1. **Use `gb auth login`** - Authenticate with token for persistent credentials
- [ ] 2. **Token auth primary** - Use `GB_TOKEN` for all API operations
- [ ] 3. **Web fallback** - `GB_USER`/`GB_PASSWORD` preseed web fallback prompts
- [ ] 4. **Error handling** - Check `gb auth status` output for specific error types
- [ ] 5. **Cross-platform** - Config locations work on Linux, macOS, Windows
