---
remote_issue: 2134
remote_url: https://github.com/michael-conrad/.opencode/issues/2134
---

> **Full spec and artifacts: [`.opencode/.issues/2134/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2134/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2134/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`117-session-trigger-behavior.md` covers only session trigger echoing — a narrow subset of the self-simulation attack surface. The agent can write output via any mechanism and read it back as instructions.

## Scope

Complete rewrite with 4 sections: Self-Simulation Prohibition, Session Trigger No-Echo, Trigger Behavior Map, Suppression Rule.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Self-Simulation Prohibition section exists | string |
| SC-2 | Prohibition covers all mechanisms (shell, file, comment, tool output, session trigger) | string |
| SC-3 | Session Trigger No-Echo section exists | string |
| SC-4 | Trigger Behavior Map with 2 triggers exists | string |
| SC-5 | Suppression Rule exists | string |
| SC-6 | Purged triggers list removed | string |
| SC-7 | Source file cross-references removed | string |
| SC-8 | Cross-reference to 000 removed | string |

## Files Affected

- `.opencode/guidelines/117-session-trigger-behavior.md`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
