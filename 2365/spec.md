> **Full spec and artifacts: [`.opencode/.issues/2365/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2365)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2365/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The engineering-approach skill requires live-documentation verification discipline (docs-verification source-priority order) and data-integrity procedural awareness, but has no Read-links to the shared references that contain these standards. Sub-agents executing engineering-approach tasks cannot load the required procedural content. |
| 2 | **Root Cause / Motivation** | Guidelines 075 (docs-verification) and 090 (data-integrity) are being condensed into shared references at `reference/data-integrity-shared.md` and `reference/code-standards-shared.md` (issues #2362, #2363). The engineering-approach skill must consume these shared references via mandatory Read-links so that sub-agents discover the procedural content during task execution. Without these links, sub-agents operate without data-integrity or docs-verification discipline. |
| 3 | **Approach Chosen** | Add mandatory `Read [Text](path)` links in the engineering-approach SKILL.md Cross-References section pointing to the two shared reference files, and add the same Read-links plus a docs-verification source-priority anchor in the operating-protocol.md procedure. |
| 4 | **Alternatives Considered & Why Discarded** | Inlining the procedural content directly into the SKILL.md — discarded because it duplicates content that belongs in shared references, creating a sync burden. Using an `opencode.jsonc` preload — discarded because it loads content at session start rather than on-demand during task execution. |
| 5 | **Key Design Decisions** | Read-links are additive only — no existing content is removed or reorganized. The docs-verification source-priority list (official docs first, then source code/type hints, then example files, then config files) is anchored in the operating-protocol step 5 via a Read-link, not inlined. |
| 6 | **User Intent / Original Prompt** | Add Read-links to engineering-approach skill so sub-agents consume data-integrity and code-standards shared references during task execution. |

## Not Included

- **Modification of 075-docs-verification.md** — Left to issue #2353.
- **Modification of 090-data-integrity.md or 080-code-standards.md** — Guideline files are not touched by this spec.
- **Modification of `opencode.jsonc` preload array** — No preload changes.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | SKILL.md Cross-References section SHALL contain a Read-link to `reference/data-integrity-shared.md` | structural | grep for `Read.*reference/data-integrity-shared.md` in `.opencode/skills/engineering-approach/SKILL.md` |
| SC-2 | SKILL.md Cross-References section SHALL contain a Read-link to `reference/code-standards-shared.md` | structural | grep for `Read.*reference/code-standards-shared.md` in `.opencode/skills/engineering-approach/SKILL.md` |
| SC-3 | operating-protocol.md Shared Reference Consumption section SHALL contain Read-links to both shared references | structural | grep for both Read-link patterns in `.opencode/skills/engineering-approach/tasks/operating-protocol.md` |
| SC-4 | operating-protocol.md step 5 SHALL anchor the docs-verification source-priority list via a Read-link to `075-docs-verification.md` | structural | grep for `Read.*075-docs-verification` in `.opencode/skills/engineering-approach/tasks/operating-protocol.md` |
| SC-5 | Guidelines 090-data-integrity.md, 080-code-standards.md, and 075-docs-verification.md SHALL NOT be modified | structural | `git diff --stat` confirms zero changes to those three files |

## Requirements

R-1. The engineering-approach SKILL.md SHALL include a Cross-References section with mandatory Read-links to both shared reference files.
R-2. The engineering-approach operating-protocol.md SHALL include a Shared Reference Consumption section instructing sub-agents to load both shared references before executing procedure steps.
R-3. The engineering-approach operating-protocol.md SHALL anchor the live-docs-verification source-priority order via a Read-link to 075-docs-verification.md §Verification Sources (Priority Order).
R-4. The implementation SHALL NOT modify 090-data-integrity.md, 080-code-standards.md, or 075-docs-verification.md.

## Items

### Item 1 (SC-1, SC-2): Add Read-links to SKILL.md Cross-References

- RED: grep confirms no Read-links exist for the two shared refs in SKILL.md
- GREEN: Add Read-links to `reference/data-integrity-shared.md` and `reference/code-standards-shared.md` in the Cross-References section
- verify: grep confirms both Read-links present
- commit: `engineering-approach/SKILL.md`

### Item 2 (SC-3): Add Read-links to operating-protocol.md Shared Reference Consumption

- RED: grep confirms no Read-links exist for shared refs in operating-protocol.md
- GREEN: Add Read-links to both shared refs in the Shared Reference Consumption section
- verify: grep confirms both Read-links present
- commit: `engineering-approach/tasks/operating-protocol.md`

### Item 3 (SC-4): Anchor docs-verification source-priority list in operating-protocol.md step 5

- RED: grep confirms no Read-link to 075-docs-verification in operating-protocol.md
- GREEN: Add Read-link to `075-docs-verification.md §Verification Sources (Priority Order)` in step 5
- verify: grep confirms Read-link present
- commit: `engineering-approach/tasks/operating-protocol.md`

### Item 4 (SC-5): Verify no guideline files modified

- RED: `git diff --stat` against three guideline files shows changes
- GREEN: No-action item — verification-only
- verify: `git diff --stat` confirms zero changes to 090, 080, 075
- commit: No files to commit

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| #2362 | Create `reference/code-standards-shared.md` | Open — must be merged before or alongside |
| #2363 | Create `reference/data-integrity-shared.md` | Open — must be merged before or alongside |
| #2353 | Condense 075-docs-verification.md after this spec completes | Open — downstream |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 1 |
| R-2 | SC-3 | Phase 2 |
| R-3 | SC-4 | Phase 2 |
| R-4 | SC-5 | Phase 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| engineering-approach SKILL.md | code | `.opencode/skills/engineering-approach/SKILL.md` | Read |
| operating-protocol.md | code | `.opencode/skills/engineering-approach/tasks/operating-protocol.md` | Read |
| data-integrity-shared.md | reference | `.opencode/reference/data-integrity-shared.md` | Created by #2363 |
| code-standards-shared.md | reference | `.opencode/reference/code-standards-shared.md` | Created by #2362 |
| 075-docs-verification.md | guideline | `.opencode/guidelines/075-docs-verification.md` | Read |
| 090-data-integrity.md | guideline | `.opencode/guidelines/090-data-integrity.md` | Read |
| 080-code-standards.md | guideline | `.opencode/guidelines/080-code-standards.md` | Read |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1, SC-2:** Verifying Read-link presence in SKILL.md costs one grep call per link. Skipping means sub-agents dispatched to engineering-approach tasks cannot load data-integrity or code-standards content — defects in those areas are caught downstream at review time instead of at dispatch.
- **SC-3:** Verifying Read-link presence in operating-protocol.md costs one grep call. Skipping means the Shared Reference Consumption section is incomplete — sub-agents skip loading procedural content.
- **SC-4:** Verifying the docs-verification anchor in step 5 costs one grep call. Skipping means step 5 has no canonical source-priority order — sub-agents guess the verification order.
- **SC-5:** Verifying guideline files are unmodified costs a git diff. Skipping means a side-effect modification to 090, 080, or 075 goes uncaught — violating the concern boundary.

## Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|------------------|------------|
| Shared reference files not yet created (#2362, #2363 still open) | Read-links reference files that do not exist yet | Read-links are forward references — they resolve after the shared refs are committed. No runtime dependency. |
| Read-link path resolution failure | Clicking a Read-link resolves to a nonexistent file | The path is relative to the workspace root — correct by construction if the shared refs are in `.opencode/reference/`. |
| Diff shows changes to 090, 080, or 075 without authorization | SC-5 fails — implementation violated concern boundary | Revert changes to those files, re-run Phase 3 verification. |
