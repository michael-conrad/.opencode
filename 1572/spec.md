## Problem

The YAML frontmatter validation in `test-enforcement.sh` reports `PARSE_ERROR` for `playwright-cli/SKILL.md`. This causes the YAML frontmatter validation to fail for this skill file.

## Root Cause

The YAML frontmatter in `playwright-cli/SKILL.md` contains content that `yaml.safe_load` cannot parse. This may be due to special characters, invalid YAML syntax, or content that looks like YAML but isn't valid.

## Evidence

```
playwright-cli/SKILL.md YAML frontmatter: PARSE_ERROR
```

## Classification

Pre-existing — this failure was present before any Phase 5 changes.

## Suggested Fix

Read `playwright-cli/SKILL.md` and fix the YAML frontmatter so it parses correctly with `yaml.safe_load`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)