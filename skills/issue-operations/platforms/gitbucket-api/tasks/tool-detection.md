# GitBucket API - Tool Detection and Version Check

## Entry Criteria

- GitBucket operation requested
- `github.platform == gitbucket`

## TOOL_MISSING Detection

Before any `gb` command, verify the tool is available:

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found. Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs"
  return 1
fi
```

## Version Check

Verify `gb` version >= 0.6.1 before proceeding:

```bash
GB_VERSION=$(gb --version 2>/dev/null | grep -oP '[\d]+\.[\d]+\.[\d]+' | head -1)
if [ -z "$GB_VERSION" ]; then
  echo "VERSION_CHECK_FAILED: Could not determine gb version"
  return 1
fi
if ! printf '%s\n' "0.6.1" "$GB_VERSION" | sort -V | head -1 | grep -q "^0.6.1$"; then
  echo "VERSION_CHECK_FAILED: gb $GB_VERSION < required 0.6.1"
  return 1
fi
```

## Exit Criteria

- gb CLI confirmed available
- Version confirmed >= 0.6.1
- BLOCKED with TOOL_MISSING or VERSION_CHECK_FAILED if requirements not met
