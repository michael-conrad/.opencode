## Bug Report

The YAML frontmatter in `.opencode/skills/playwright-cli/SKILL.md` fails to parse, causing the content-verification test suite to report `PARSE_ERROR` instead of `PASS`.

### Error

```
YAML ERROR: mapping values are not allowed here
  in "<unicode string>", line 2, column 347:
     ... /setting up Playwright. REQUIRED: dispatch via skill() before an ... 
                                         ^
```

### Root Cause

The `description` field in the YAML frontmatter contains a colon character (`:`) in the phrase `REQUIRED: dispatch via skill() before an...` which YAML interprets as a mapping key-value separator. The description is not quoted, so the colon breaks parsing.

### Fix

Quote the `description` value in the YAML frontmatter, or escape the colon.

### Evidence

Detected by `bash .opencode/tests/test-enforcement.sh --tag pr-creation` on 2026-06-29. The `skill-yaml-frontmatter-parse` check reports 41/42 passed, 1 failed (playwright-cli).

### Severity

Content-verification FAIL — pre-existing, not a Phase 6 regression.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
