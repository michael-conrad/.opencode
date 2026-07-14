## Problem

The opencode guidelines use cross-references of the form `See \`FILENAME.md\` §SECTION` or `See \`SKILLNAME\` skill`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

The guidelines are structured correctly for progressive disclosure — lightweight identifiers pointing to content that should be loaded on demand. The agent has the tools to resolve every cross-reference (`read` for guideline files, `skill()` for skills, `grep` for section lookup). The failure is that the cross-references are framed as citations, not as load directives.

## Root Cause

The word "See" is a passive verb. The agent interprets it as a citation, not an instruction. The backtick-wrapped filename is not recognized as a loadable resource. The `§` section reference is not recognized as a navigation target. The agent has no rule anywhere in the system that says cross-references are load directives.

## Fix

Add a mandate to the system prompt (`.opencode/prompts/default.txt`) and project instructions (`.opencode/AGENTS.md`) that explicitly states:

1. When a guideline or skill file says "See `FILENAME.md` §SECTION" or "See `SKILLNAME` skill", this is a load directive, not a citation. The text before "see" is a summary. The complete rule lives at the referenced location. Search your context for the referenced section before acting on the rule.

2. When a guideline or skill file says "Read [Text](path)", this is an instruction to call `read` on that path. The referenced content is not pre-loaded. Follow the link to get the complete rule.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/prompts/default.txt` contains the cross-reference load directive mandate | `string` | grep for mandate language in default.txt |
| SC-2 | `.opencode/AGENTS.md` contains the same cross-reference load directive mandate | `string` | grep for mandate language in .opencode/AGENTS.md |
| SC-3 | Existing citation-style cross-references in guidelines are NOT modified by this spec (band-aid only) | `structural` | Verify no guideline files were modified by this change |

## Affected Files

- `.opencode/prompts/default.txt` — system prompt
- `.opencode/AGENTS.md` — project instructions

## Research Card

`.issues/research-cards/cross-reference-lobotomization.md`

## Interdependency Ordering

- **BLOCKED BY**: Nothing (first in chain)
- **BLOCKS**: #1924 (holistic rewrites depend on this mandate)
- **INDEPENDENT OF**: #1925 (linting), #1926 (behavioral tests)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)