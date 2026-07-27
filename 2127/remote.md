---
remote_issue: 2127
remote_url: https://github.com/michael-conrad/.opencode/issues/2127
---

> **Full spec and artifacts: [`.opencode/.issues/2127/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2127/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2127/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

- **Intent**: Compact `020-go-prohibitions.md` by removing content duplicated in `000-critical-rules.md`, removing an obsolete sub-issue model, and replacing a Node.js-specific prohibition with a general `.tools/` rule.
- **Problem Statement**: `020-go-prohibitions.md` is ~659 lines. Live verification reveals the ACTUAL duplication is limited to: §6 Progressive Iterative Implementation (restates 000's Checkpoint Rollback Exception), the "stop" command section, and the Channel-Routing Table. §5 contains an obsolete sub-issue model. There is internal duplication (3 restated ALWAYS DO lines). Content previously claimed as duplicated (§1.1, live tool call lines, cost-blind lines, 10 ALWAYS DO items) is actually unique to 020.
- **Approach Chosen**: Remove verified-duplicated sections, remove obsolete §5, remove internally-duplicated lines, collapse adjacent sections, replace Node.js-specific rule with general `.tools/` rule. Keep all unique-to-020 content.

## All-or-Nothing SC Enforcement Gate

All SCs MUST pass before the implementation is considered complete. A single FAIL blocks the entire change.

## Requirements

| ID | Requirement | Evidence Type |
|----|------------|---------------|
| REQ-1 | Remove §5 Multi-task Plan Without Sub-issues | string |
| REQ-2 | Remove §6 Progressive Iterative Implementation | string |
| REQ-3 | Remove "stop" command section | string |
| REQ-4 | Remove Channel-Routing Table | string |
| REQ-5 | Remove 3 restated ALWAYS DO lines | string |
| REQ-6 | §1.2 merged into §1 as bullet | string |
| REQ-7 | §1.5 collapsed into §1 | string |
| REQ-8 | §4 replaced with general `.tools/` rule | string |
| REQ-9 | All keep sections remain | string |
| REQ-10 | No content loss — removed sections verified as duplicated in 000 | semantic |
| REQ-11 | No orphaned cross-references to removed section names | string |
| REQ-12 | No line-count or word-count metrics used as success measurement | string |
| REQ-13 | Remove duplicate Node.js Prohibition section from 070-environment.md (lines 224-257) | string |

## Traceability

| Requirement | Success Criterion | Implementation Plan Phase |
|------------|------------------|--------------------------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-2 | SC-2 | Phase 1 |
| REQ-3 | SC-3 | Phase 1 |
| REQ-4 | SC-4 | Phase 1 |
| REQ-5 | SC-5 | Phase 2 |
| REQ-6 | SC-6 | Phase 3 |
| REQ-7 | SC-7 | Phase 3 |
| REQ-8 | SC-8 | Phase 4 |
| REQ-9 | SC-9 | Phase 5 |
| REQ-10 | SC-10 | Phase 5 |
| REQ-11 | SC-11 | Phase 5 |
| REQ-12 | SC-12 | Phase 5 |
| REQ-13 | SC-13 | Phase 5 |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Remove §5 Multi-task Plan Without Sub-issues | string |
| SC-2 | Remove §6 Progressive Iterative Implementation | string |
| SC-3 | Remove "stop" command section | string |
| SC-4 | Remove Channel-Routing Table | string |
| SC-5 | Remove 3 restated ALWAYS DO lines | string |
| SC-6 | §1.2 merged into §1 as bullet | string |
| SC-7 | §1.5 collapsed into §1 | string |
| SC-8 | §4 replaced with general `.tools/` rule | string |
| SC-9 | All keep sections remain | string |
| SC-10 | No content loss — removed sections verified as duplicated in 000 | semantic |
| SC-11 | No orphaned cross-references to removed section names | string |
| SC-12 | No line-count or word-count metrics used as success measurement | string |

## Files Affected

- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/guidelines/070-environment.md`

## Dependencies

- Depends on 000-critical-rules.md compaction (#2121).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
