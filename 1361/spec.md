## Problem

When running tests or builds, agents encounter warnings that indicate real configuration defects (e.g., `requires-python` tilde specifier without patch version). These warnings are logged to stderr but silently ignored — no bug report is filed, no issue is created. The defect persists until someone manually notices it.

The agent treats warnings as noise rather than signals. This lets breaking configuration defects accumulate silently.

### Example (observed in hermes-ingest-pubmed)

```
warning: The `requires-python` specifier (`~=3.12`) in `hermes-ingest-pubmed` uses the tilde specifier (`~=`) without a patch version. This will be interpreted as `>=3.12, <4`. Did you mean `~=3.12.0` to constrain the version as `>=3.12.0, <3.13`?
```

This warning appeared during `uv run pytest` execution. The agent continued running tests without reporting the defect. The `pyproject.toml` remains misconfigured.

## Requirement

When the agent encounters a warning, error, or diagnostic message during test/build execution that indicates a **configuration defect** (not a test failure), it MUST:

1. **Recognize the defect** — parse stderr/stdout for known defect patterns (e.g., deprecation warnings with fix suggestions, specifier ambiguity, missing configuration)
2. **File a bug report** — create a GitHub Issue in the appropriate repo (determined by the file path or project context) with:
   - Title describing the defect
   - Body containing the full warning text, the offending file path, and the suggested fix
   - Label `bug`
3. **Continue execution** — do not halt or block on the defect unless it prevents the current task from completing

### Scope

This applies to **configuration and tooling defects** that are surfaced as warnings during normal agent operations (test runs, builds, lint checks, type checks). It does NOT apply to:

- Test failures (handled by existing verification-before-completion workflow)
- Runtime errors (handled by existing exception handling)
- Informational output (progress bars, status messages)

### Defect Categories (Initial)

| Pattern | Example | Action |
|---------|---------|--------|
| `requires-python` specifier ambiguity | `~=3.12` without patch version | File bug with fix suggestion |
| Deprecated API usage with migration path | `@validator` → `@field_validator` | File bug with migration link |
| Missing/empty config sections | `pyproject.toml` missing `[tool.pytest]` | File bug |
| Version pinning conflicts | `ruff` version mismatch between `pyproject.toml` and `.pre-commit-config.yaml` | File bug |
| Stale dependency references | Import path changed but dependency not updated | File bug |

### Anti-Patterns (Forbidden)

- Suppressing warnings with `--quiet` or similar flags
- Ignoring stderr output that contains defect signals
- Adding the defect to a "known issues" list instead of filing a real bug report
- Logging the warning to chat without creating an issue

## Verification

| Check | Method | Required Result |
|-------|--------|-----------------|
| Warning triggers bug report | Run test with `requires-python` defect → agent creates issue | Issue filed in correct repo |
| Test failures NOT double-filed | Run test with actual test failure → agent uses existing verification workflow | No duplicate issue for test failures |
| Correct repo routing | Agent determines correct repo from file path context | Issue filed in repo owning the defective file |

## Ancestry

- Parent: None
- Children: None

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)