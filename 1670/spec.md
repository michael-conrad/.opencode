## Problem

Issue #1669 spec body contained an unresolved `{N}` template placeholder and a broken `issues-data` branch URL in the `> **Full spec and artifacts**` line. The sub-agent that wrote the spec did not resolve template variables before posting.

## Root Cause

The `create` task from `spec-creation` produced output with unresolved `{N}` placeholders. The orchestrator accepted and posted the output without verifying the body for template artifacts.

## Fix Applied

- Removed the broken `> **Full spec and artifacts**` line entirely
- Removed the `## AI Agent Instructions` section that referenced `.issues/{N}/`
- The spec body is now self-contained with no template placeholders

## Verification

- [ ] No `{N}` or unresolved template variables remain in the body
- [ ] No broken URLs remain in the body
- [ ] All success criteria, affected files, and constraints are intact

🤖 OpenCode (deepseek-v4-flash) created