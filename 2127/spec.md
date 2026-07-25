---
remote_issue: 2127
remote_url: https://github.com/michael-conrad/.opencode/issues/2127
labels: [spec]
---

## Problem

`020-go-prohibitions.md` is ~420 lines / ~43KB. It has significant duplication with other preloaded guidelines (000, 065), internal duplication between sections, an obsolete sub-issue model in §5, and a Node.js-specific prohibition that should be a general `.tools/` rule.

## Proposed Solution

### Remove (duplicated in other preloaded guidelines):

| Section | Lines | Duplicated In |
|---|---|---|
| §1.1 Orchestrator Context Discipline | 80-135 | 000 (Orchestrator Context Lean, Result Contract Frugality) |
| §6 Progressive Iterative Implementation | 392-404 | 000 (Checkpoint Rollback Exception) |
| "stop" command | 406-420 | 000 |
| 5 individual lines in §1 (cost-blind, evidence substitution, continue waiver, silent halt, escalate without remediation) | 53, 64-73 | 000, 065 |
| 3 lines in §1.6 (live tool call, training data, metadata) | 284-286 | 065 |
| 3 ALWAYS DO lines restating above | 301-303 | internal duplication |
| 10 ALWAYS DO items (inline work, poisoned pipeline, discard on failure, edit-in-place, continue waiver, cost-blind, test substitution, remediate before escalate, PRELOADED_CONTEXT_REJECTED, submodule-only PR) | 214-250 (subset) | 000, 065 |

### Remove (obsolete):

| Section | Rationale |
|---|---|
| §5 Multi-task Plan Without Sub-issues | Sub-issue model is obsolete — plans are files in a spec folder |

### Collapse:

| Section | Action |
|---|---|
| §1.2 Interpretive Questions | Merge into §1 as additional bullet |
| §1.5 Soliciting Authorization | Collapse unique rule into §1, remove rest (verb-prefix restatement, tables) |

### Replace:

| Section | Current | Replacement |
|---|---|---|
| §4 Node.js Prohibition + §4.5 Project-Local Tools | Node.js-specific prohibition with exception path | General rule: all project-local tooling goes in `.tools/<tool>/`, system-isolated, gitignored, cleanable. Node.js is one application of the general principle, not a special case. |

### Keep (universal, not duplicated):

- §1: 22 unique authorization/interaction rules
- Authorization-Free Actions
- `for_analysis` Scope
- 7 unique ALWAYS DO items (verify codebase state, HALT at scope boundary, parse authorization phrases, halt produces status, search before halt, scope-limited behavioral testing)
- §1.6: 11 unique discussion mode items
- §2: Iterative Feedback

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Remove §1.1 Orchestrator Context Discipline | string | grep for absence of 'Orchestrator Context Discipline' |
| SC-2 | Remove §5 Multi-task Plan Without Sub-issues | string | grep for absence of 'Multi-task Plan Without Sub-issues' |
| SC-3 | Remove §6 Progressive Iterative Implementation | string | grep for absence of 'Progressive Iterative Implementation' |
| SC-4 | Remove "stop" command section | string | grep for absence of 'terminal halt' |
| SC-5 | Remove 5 duplicated lines in §1 (cost-blind, evidence substitution, continue waiver, silent halt, escalate) | string | grep for absence of each pattern |
| SC-6 | Remove 3 duplicated lines in §1.6 (live tool call, training data, metadata) | string | grep for absence of 'Never answer without a live tool call' |
| SC-7 | Remove 3 restated ALWAYS DO lines | string | grep for absence of 'Make a live tool call before every factual claim' |
| SC-8 | Remove 10 duplicated ALWAYS DO items | string | grep for absence of each pattern |
| SC-9 | §1.2 merged into §1 as bullet | string | grep for 'interpretive question' in §1 |
| SC-10 | §1.5 collapsed into §1 | string | grep for absence of 'Soliciting Authorization' header |
| SC-11 | §4 replaced with general `.tools/` rule | string | grep for '.tools/' in §4 |
| SC-12 | All keep sections remain | string | grep for each section header |
| SC-13 | No content loss — removed sections verified as duplicated in 000/065 | behavioral | Compare removed section content against 000/065 equivalents; verify all rules preserved in source |
| SC-14 | No orphaned cross-references to removed section names | string | grep for removed section names across .opencode/ — only 000/065 remain |
| SC-15 | No line-count or word-count metrics used as success measurement | string | grep for absence of 'wc -l', 'file size', 'Final file size' in spec |

## Implementation Plan

### Phase 1: Remove duplicated sections (§1.1, §5, §6, stop command)
### Phase 2: Remove duplicated lines within §1 and §1.6
### Phase 3: Remove 10 duplicated ALWAYS DO items
### Phase 4: Collapse §1.2 and §1.5 into §1
### Phase 5: Replace §4/§4.5 with general `.tools/` rule
### Phase 6: Verify all keep sections remain and no content loss

## Files Affected

- `.opencode/guidelines/020-go-prohibitions.md` — compacted
- `.opencode/guidelines/070-environment.md` — remove duplicate Node.js section (lines 224-257)

## Risks

- **Content loss**: Removed sections must be verified to exist in 000/065. Mitigation: SC-13 verifies each removal is safe.
- **Cross-reference breakage**: 070-environment.md references §4. Mitigation: update 070 to reference the new `.tools/` rule.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the duplicated rules must remain in 000.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
