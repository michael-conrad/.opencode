> **Full spec and artifacts: [`.opencode/.issues/1420/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1420)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1420/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

There is no rule mandating YAML as the format for LLM-to-LLM structured data transfers (result contracts, state files, work state files, etc.). The absence of this rule allowed JSON-like structures to be used in spec #1418, prescribing a data format that is not the project standard. JSON is not suitable for LLM-to-LLM communication because it lacks comments, is less human-readable for multi-line values, and is not the established convention in this project's skill task files and enforcement files.

## Fix

Add a rule to `080-code-standards.md` (or `000-critical-rules.md` as Tier 2) mandating YAML for all LLM-to-LLM structured data transfers, with JSON prohibited for this purpose.

### Proposed Wording

In `080-code-standards.md`, add a new section:

```
### LLM-to-LLM Data Transfer Format — YAML Only

All structured data exchanged between AI agents (result contracts, work state
files, task context, evidence artifacts, and any other LLM-to-LLM data transfer)
MUST use YAML format. JSON is prohibited for LLM-to-LLM communication.

**Rationale:** YAML supports comments, is more readable for multi-line values,
and is the established convention in this project's skill task files and
enforcement files. JSON lacks comments and is less suitable for the
documentation-adjacent nature of LLM-to-LLM contracts.

**Exception:** JSON is permitted for:
- External API calls (GitHub API, GitBucket API, etc.)
- Configuration files that require JSON (e.g., `opencode.jsonc`)
- Data interchange with non-LLM systems
```

### Files Affected

| File | Change |
|------|--------|
| `guidelines/080-code-standards.md` | Add YAML-only rule for LLM-to-LLM data transfers |
| `.opencode/.issues/1418/spec.md` | Ensure no JSON-like structures remain in the spec |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)