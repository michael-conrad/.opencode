> **Full spec and artifacts: [.opencode#2366/](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2366/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2366/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The approval-gate skill SKILL.md already contains the authoritative Authorization Scope Model (scope table, verb-prefix parsing table, spec-to-plan cascade, re-implementation workflow, for_pr routing, label handling, bug discovery protocol), but duplicate versions of these sections also live in `010-approval-gate.md`. The guidelines also reference inline scope values from the verb-prefix parsing table rather than pointing to the skill card as the canonical source. This fragmentation means any update to the scope model requires touching multiple files, and sub-agents loading guidelines get stale or incomplete scope data.

## Scope

**In scope:**
- Remove duplicated scope model content from `010-approval-gate.md` and ensure its existing Read-link covers the removed sections
- Replace inline verb-prefix references in `020-go-prohibitions.md` with Read-links to the skill card Authorization Scope Model
- Add Read-links in the approval-gate SKILL.md Cross-References section pointing to `020-go-prohibitions.md` §1.1 (orchestrator context discipline) and §1.6 (discussion mode mandates)

**Out of scope:**
- Changing the approval-gate skill Trigger Dispatch Table, Invocation, or routing metadata — routing is structural and unchanged
- Adding new scope values or changing existing scope semantics — purely organizational
- Modifying `000-critical-rules.md` — its scope model references are already Read-links to the skill card

## Approach

Three independent phases, each touching exactly one file:
1. Edit `010-approval-gate.md` to remove the duplicated scope model content (Key Scope Values table, Scope-Dependent PR Strategy, Authorization Scope Is Permission section). The existing Read-link at line 9 already points to the skill card — ensure it covers the removed content.
2. Edit `020-go-prohibitions.md` to replace all inline verb-prefix scope value references (lines 191, 198, 232, 234, 250) with Read-links to the skill card Authorization Scope Model.
3. Edit the approval-gate SKILL.md Cross-References section to add explicit Read-links to `020-go-prohibitions.md` §1.1 (orchestrator context discipline) and §1.6 (discussion mode mandates).

## Impact

**Risks:**
- Sub-agents that loaded 010-approval-gate.md in a prior session and cached its content may not re-read — mitigated by the mandatory verification-honesty and context-completeness gates that require fresh reads
- The 010-approval-gate.md is Tier 1 preloaded — removing content reduces preload size, which is strictly beneficial
- No behavioral change to agent dispatch since the approval-gate skill routing is untouched

**Key dependencies:** None — all phases are independent and can be executed in any order.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|-------------------|----------------------|
| SC-1 | `010-approval-gate.md` SHALL NOT contain a duplicated Authorization Scope Model table (Key Scope Values, Scope-Dependent PR Strategy, Authorization Scope Is Permission). The existing Read-link at the top of the file SHALL cover the removed content. | `structural` | `grep` for `for_review_prep\|for_spec\|for_plan\|for_implementation\|for_pr\|for_release_pr\|for_analysis` in 010; verify only the Read-link reference remains | `.opencode/guidelines/010-approval-gate.md` |
| SC-2 | `020-go-prohibitions.md` SHALL replace inline verb-prefix scope values at identified locations with Read-links to `approval-gate skill → Authorization Scope Model`. | `structural` | `grep` for inline scope value patterns in 020; verify replaced with Read-links | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-3 | The approval-gate SKILL.md Cross-References section SHALL include a Read-link to `020-go-prohibitions.md` §1.1 orchestrator context discipline. | `structural` | `grep` for "orchestrator context discipline" in SKILL.md | `.opencode/skills/approval-gate/SKILL.md` |
| SC-4 | The approval-gate SKILL.md Cross-References section SHALL include a Read-link to `020-go-prohibitions.md` §1.6 discussion mode mandates. | `structural` | `grep` for "discussion mode mandates" in SKILL.md | `.opencode/skills/approval-gate/SKILL.md` |
| SC-5 | The approval-gate SKILL.md description field in frontmatter SHALL accurately reflect the skill as the authoritative source for the scope model. | `string` | Read SKILL.md frontmatter description; verify it references scope model authority | `.opencode/skills/approval-gate/SKILL.md` |

## Requirements

R-1. The approval-gate SKILL.md SHALL be the single authoritative source for the Authorization Scope Model.
R-2. `010-approval-gate.md` SHALL NOT contain duplicated scope model tables or content.
R-3. `020-go-prohibitions.md` SHALL reference the skill card scope model via Read-links, not inline values.
R-4. The approval-gate SKILL.md Cross-References section SHALL include Read-links to related guidelines sections.
R-5. The approval-gate SKILL.md frontmatter description SHALL accurately describe the skill's role as scope model authority.

## Items

### Item 1 (SC-1): Remove duplicated scope model from 010-approval-gate.md

- RED: Assert that 010-approval-gate.md currently contains duplicated scope model table
- GREEN: Remove duplicate scope model content, verify existing Read-link covers removed sections
- verify: `grep` for scope value patterns — only Read-link reference remains
- commit: Edit 010-approval-gate.md

### Item 2 (SC-2): Replace inline verb-prefix references in 020-go-prohibitions.md

- RED: Assert that 020-go-prohibitions.md currently contains inline verb-prefix scope values
- GREEN: Replace with Read-links to skill card Authorization Scope Model
- verify: `grep` for remaining inline values — only Read-links remain
- commit: Edit 020-go-prohibitions.md

### Item 3 (SC-3): Add orchestrator-context-discipline Read-link to SKILL.md

- RED: Assert that SKILL.md Cross-References is missing explicit link to 020 §1.1
- GREEN: Add Read-link for orchestrator context discipline
- verify: `grep` for "orchestrator context discipline" in SKILL.md
- commit: Edit SKILL.md (together with Item 4)

### Item 4 (SC-4): Add discussion-mode-mandates Read-link to SKILL.md

- RED: Assert that SKILL.md Cross-References is missing explicit link to 020 §1.6
- GREEN: Add Read-link for discussion mode mandates
- verify: `grep` for "discussion mode mandates" in SKILL.md
- commit: Edit SKILL.md (together with Item 3)

### Item 5 (SC-5): Verify description accuracy in SKILL.md frontmatter

- RED: Assert current description may not reflect scope model authority
- GREEN: Update frontmatter description if needed
- verify: Read updated description
- commit: Edit SKILL.md

## Dependencies

None. All phases are independent and can be executed in any order.

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1, SC-5 | 1, 5 |
| R-2 | SC-1 | 1 |
| R-3 | SC-2 | 2 |
| R-4 | SC-3, SC-4 | 3, 4 |
| R-5 | SC-5 | 5 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| approval-gate SKILL.md | code (skill card) | `.opencode/skills/approval-gate/SKILL.md` | Live read |
| 010-approval-gate.md | code (guideline) | `.opencode/guidelines/010-approval-gate.md` | Live read |
| 020-go-prohibitions.md | code (guideline) | `.opencode/guidelines/020-go-prohibitions.md` | Live read |

## Enforcement Gate

> All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the duplicate removal costs one grep search. Skipping means agents loading 010-approval-gate.md see stale duplicated content and make scope decisions from the wrong source.
- SC-2: Verifying the inline value replacement costs one grep search. Skipping means 020-go-prohibitions.md still contains inline values that drift independently from the canonical source.
- SC-3: Verifying the Read-link addition costs one grep search. Skipping means the Cross-References section omits a key reference that orchestrators should follow.
- SC-4: Verifying the Read-link addition costs one grep search. Skipping means the Cross-References section omits a key reference that orchestrators should follow.
- SC-5: Verifying description accuracy costs one read call. Skipping means agents routing to the skill get a description that understates its scope model authority.

## Edge Cases

- **Preloaded guideline content:** Both 010 and 020 are Tier 1 preloaded. Removing content from 010 reduces preload size — cannot break anything. Replacing inline values with Read-links in 020 reduces preload size — cannot break anything.
- **Sub-agent context:** Sub-agents loading 010 or 020 will see Read-links instead of inline tables. They MUST follow Read-links per the mandatory cross-reference standard.
- **Orchestrator routing:** The approval-gate skill routing metadata (TDT, Invocation, DISPATCH_GATE, Pre-Flight Guard) is untouched. No behavioral change to agent dispatch.
- **No-op on empty sections:** If the Cross-References section already has the required Read-links, SKILL.md changes are no-op. Verify before editing.
