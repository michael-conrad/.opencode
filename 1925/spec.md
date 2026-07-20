## Problem

The deck has no mechanism to prevent new citation-style cross-references (`See \`FILE.md\``) from being introduced. The holistic fix (#1924) rewrites existing ones, but without linting, new ones will appear in future PRs.

## Fix

Add a linting rule that detects the pattern `See \`...\`` in guidelines, SKILL.md files, and task files, and flags it as a FAIL. The rule is run on demand — not part of constant processing — and is integrated into the markdown lint pipeline in `.opencode/AGENTS.md`.

Document the canonical cross-reference format (`Read [Text](path)`) in a guideline file, specifying:
- The form: `Read [descriptive text](relative/path.md)`
- When to use it: any time a file references content in another file
- What it means: the agent must follow the link to get the complete rule

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A linting rule detects `See \`...\`` patterns in guidelines and flags them as FAIL | `behavioral` | Run lint on a test file containing `See \`FILE.md\``; verify FAIL |
| SC-2 | The linting rule is integrated into the markdown lint pipeline in `.opencode/AGENTS.md` | `string` | grep for the lint rule in AGENTS.md build/lint/test commands |
| SC-3 | A guideline documents the canonical `Read [Text](path)` cross-reference format | `string` | grep for cross-reference format documentation in guidelines |
| SC-4 | The documentation specifies the form, when to use it, and what it means | `string` | grep for form specification, usage guidance, and meaning in the documentation |

## Affected Files

- `.opencode/guidelines/` — new or updated guideline documenting cross-reference format
- `.opencode/AGENTS.md` — build/lint/test commands (lint rule integration)

## Interdependency Ordering

- **BLOCKED BY**: Nothing (ships independently)
- **BLOCKS**: Nothing
- **INDEPENDENT OF**: #1923 (band-aid), #1924 (rewrites), #1926 (behavioral tests)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)