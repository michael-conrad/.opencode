# GitBucket Error Recovery

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Bad credentials" | Basic auth attempted | Use `gb auth login` with token |
| "Not Found" | Wrong endpoint URL | Verify path and owner/repo names |
| "Unauthorized" | Token missing or invalid | Run `gb auth status` to check auth state |
| 422 Unprocessable Entity | Validation error | Check request body format |
| TOOL_MISSING | `gb` CLI not installed | Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs |

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found. Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs"
  return 1
fi
```

## Authentication Errors

### "Bad credentials"

**Cause**: Using HTTP Basic authentication instead of token authentication.

**Correct**:
```bash
gb auth login -H https://gitbucket.example.com/gitbucket/
```

**Explanation**: GitBucket does not support HTTP Basic authentication for API calls. Use `gb auth login` with a token for all API operations.

### "Unauthorized"

**Cause**: Token missing, empty, or invalid.

**Solution**:
- [ ] 1. Run `gb auth status` to check current auth state
- [ ] 2. Verify token has correct scopes
- [ ] 3. Regenerate token in GitBucket UI if corrupted
- [ ] 4. Run `gb auth status` to check current auth state

## Endpoint Errors

### "Not Found"

**Cause**: Incorrect URL format or missing repository.

**Debug steps**:
```bash
# Verify repository exists
gb repo view org/project

# Check owner/repo names (case-sensitive)
```

**Common mistakes**:
- Wrong owner name (case-sensitive)
- Wrong repository name (case-sensitive)
- Missing `-R owner/repo` flag

### 422 Unprocessable Entity

**Cause**: Request body format incorrect.

**Example - Labels**:
```bash
# WRONG: Object format (GitHub style)
# gb handles this internally, but GitBucket API expects array format

# CORRECT: Use gb --label flag which sends correct format
gb issue create -t "Test" -R org/project --label bug,enhancement
```

## Session Init Detection

Session init script (`.opencode/tools/session-init`) detects GitBucket from remote URL and outputs:

```
github.platform: gitbucket
gitbucket.html_url: https://gitbucket.example.com/gitbucket/
gitbucket.has_credentials: true
```

**If `gitbucket.has_credentials=false`**, token is missing from `.env`.

## Token Validation

```bash
gb auth status
# Outputs: authentication status and user info if valid
```

## Fallback Strategy

If GitBucket API fails:
- [ ] 1. Check authentication (token present and valid) — `gb auth status`
- [ ] 2. Verify `-R owner/repo` flag is correct
- [ ] 3. Check repository exists and is accessible — `gb repo view owner/repo`
- [ ] 4. Fall back to GitBucket web UI for operations not supported by API
- [ ] 5. Use `gb api` passthrough for operations without dedicated subcommands
