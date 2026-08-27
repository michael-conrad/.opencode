> **Full spec and artifacts: [`.opencode/.issues/2364/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2364)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2364/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC: Update mcp-tool-usage skill — anchor five-tier hierarchy & glob semantics

## Intent and Executive Summary

**Problem Statement:** The five-tier tool hierarchy and the built-in glob tool's verified semantics (LIM-1 through LIM-6) currently live in the preloaded `060-tool-usage.md` guideline, which is scheduled for condensation. Unless a canonical anchor is established first, seven glob-semantics Read-links across six consuming cards dangle and tool-selection authority fragments the moment the preloaded section is removed.

**Root Cause / Motivation:** The glob semantics section was written into `060-tool-usage.md` (§2) as the "single authoritative source," and consuming cards Read-link there. The preload budget requires condensing 060 (~2.9k token savings), which removes that section. The mcp-tool-usage skill is already the designated tool-selection authority — 060 §1 redirects there and the dispatch table registers it — but it contains no glob semantics content today. The anchor must exist before the removal; otherwise every consumer loses its canonical source at condensation time.

**Approach Chosen:** Anchor-before-remove. Consolidate the five-tier hierarchy and glob semantics into `mcp-tool-usage/SKILL.md` as the single source of truth: verify hierarchy completeness against 060 §1, add the glob semantics section between the hierarchy and the Critical Rules content, update the selection-guide task card, and reroute every glob-semantics Read-link in consuming cards to the skill card synchronously. `060-tool-usage.md` itself stays untouched — its condensation is a separate downstream issue.

**Alternatives Considered & Why Discarded:**

- Keep glob semantics in `060-tool-usage.md` and anchor only the hierarchy in mcp-tool-usage — discarded: forfeits the bulk of the ~2.9k preload savings that motivate the condensation, since §2 is the larger section.
- Anchor glob semantics in a new standalone reference document (e.g. `.opencode/reference/glob-semantics.md`) — discarded: adds a third routing hop (guideline → reference doc) and splits tool-selection authority across two files; mcp-tool-usage is already the registered tool-selection authority.
- Reroute consuming cards' Read-links in a follow-up issue after condensation — discarded: creates a link-rot window in which Read-links point at removed content; synchronous rerouting in this spec eliminates dangling references entirely.

**Key Design Decisions:**

- Single canonical anchor in the skill card, not the preloaded guideline — tradeoff: SKILL.md grows (~40 lines) and the full limitation set loads only via Read-link, in exchange for the preload budget recovered by the downstream condensation.
- Anchor-before-remove ordering (this spec precedes the 060 condensation) — tradeoff: temporary content duplication (glob semantics exists in both files until condensation) in exchange for a zero link-rot window.
- SC-4 is pattern-defined (grep criterion), not a frozen file list — tradeoff: implementers must re-run link discovery at implementation time, in exchange for robustness against consuming cards added between spec approval and implementation.

**User Intent / Original Prompt:** "The five-tier tool hierarchy and glob LIM-1..6 semantics currently live in the preloaded 060-tool-usage.md guideline and will be removed from preload. mcp-tool-usage must become the single canonical home." — issue #2364 body, with scope: "Make mcp-tool-usage the authoritative source for the five-tier hierarchy + glob semantics; add mandatory Read [Text](path) links for any consuming cards."

## Not Included

- **Condensing or modifying `060-tool-usage.md`** — removal of §1/§2 content is a separate downstream issue; this spec only establishes the anchor that issue removes from preload.
- **Duplicating glob semantics into any other file** — a second copy reintroduces exactly the fragmentation this spec exists to eliminate.
- **Non-glob Read-links to `060-tool-usage.md`** — notebook-mcp references and §1 API-Client links in other cards (e.g. `210-scripting.md`) stay untouched; only glob-semantics links are rerouted.
- **Behavioral enforcement tests for agent glob usage** — this spec removes no preload content and changes no runtime context; verification is structural/string per the testability assessment. Behavioral Read-link efficacy belongs to the condensation issue.
- **Changes to the opencode.jsonc preload array** — the 12 Tier 1 guidelines stay preloaded until the condensation issue.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|-----------------------|
| SC-1 | The mcp-tool-usage SKILL.md five-tier hierarchy section SHALL be complete relative to `060-tool-usage.md` §1: tier summary, srclight indexing note, PROHIBITED list, and API Client Mandatory mandate all present. | structural | Clean-room sub-agent reads both files and compares content-element inventories; every element present in 060 §1 SHALL have a counterpart in SKILL.md. | `.opencode/skills/mcp-tool-usage/SKILL.md`; `.opencode/guidelines/060-tool-usage.md` §1 |
| SC-2 | The mcp-tool-usage SKILL.md SHALL contain a glob semantics section carrying the LIM-1 through LIM-6 limitation table, the canonical path-parameter invocation idiom with at least one verified-working example, the forbidden silent-empty shapes, and the empty-result disambiguation rule, positioned between the five-tier hierarchy content and the Critical Rules / `.ipynb` mandate content, with the frontmatter description routing glob-semantics triggers. | structural | Content inspection by clean-room sub-agent plus `skildeck-lint` structural validation of SKILL.md. | `.opencode/guidelines/060-tool-usage.md` §2 (source); `.opencode/skills/mcp-tool-usage/SKILL.md` (target) |
| SC-3 | The selection-guide task card SHALL reference the SKILL.md glob semantics section and provide task-level glob tool selection guidance. | structural | Content inspection by clean-room sub-agent of the selection-guide task card. | `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` |
| SC-4 | Zero consuming cards SHALL retain a glob-semantics Read-link to `060-tool-usage.md`; every glob-semantics Read-link SHALL point at the mcp-tool-usage SKILL.md. The consuming set is pattern-defined: any card containing a Read-link to `060-tool-usage.md` inside glob-semantics prose (LIM references, path-parameter glob forms, empty-result rule). | string | grep across `.opencode/guidelines/` and `.opencode/skills/`: zero glob-context `060-tool-usage.md` Read-links remain; each consuming card carries at least one mcp-tool-usage Read-link. | Consuming set verified at spec time: `.opencode/guidelines/020-go-prohibitions.md`; `.opencode/skills/audit/tasks/content-audit-investigator.md`; `.opencode/skills/audit/tasks/coherence-maintenance-investigator.md`; `.opencode/skills/audit/tasks/coherence-maintenance-validator.md`; `.opencode/skills/verification-before-completion/tasks/completion.md`; `.opencode/skills/sre-runbook/tasks/generate.md` (2 link sites) |

## Requirements

R-1. The mcp-tool-usage SKILL.md SHALL be the canonical anchor for the five-tier tool hierarchy and SHALL contain a superset of the tier content summarized in `060-tool-usage.md` §1 (tier summary, srclight indexing note, PROHIBITED list, API Client Mandatory mandate).

R-2. The mcp-tool-usage SKILL.md SHALL contain a glob semantics section carrying the verified limitations table LIM-1 through LIM-6.

R-3. The glob semantics section SHALL contain the canonical path-parameter invocation idiom with at least one verified-working example and the forbidden silent-empty pattern shapes.

R-4. The glob semantics section SHALL contain the empty-result disambiguation rule requiring tool-call evidence of correct invocation and path reachability before any absence conclusion.

R-5. The glob semantics section SHALL be positioned between the five-tier hierarchy content and the Critical Rules / `.ipynb` mandate content in SKILL.md.

R-6. The mcp-tool-usage SKILL.md frontmatter description SHOULD include glob semantics as a routing trigger.

R-7. The selection-guide task card SHALL reference the glob semantics section and provide task-level glob tool selection guidance.

R-8. Every consuming card whose glob-semantics prose Read-links to `060-tool-usage.md` SHALL be updated to Read-link to the mcp-tool-usage SKILL.md instead, with no change to the surrounding prose's semantic content.

R-9. This spec's implementation SHALL NOT introduce glob semantics content into any file other than the mcp-tool-usage skill deck. The existing copy in `060-tool-usage.md` §2 remains until the separate condensation issue removes it.

R-10. This spec's implementation SHALL NOT modify `060-tool-usage.md`, the opencode.jsonc preload array, or any non-glob Read-link.

## Items

### Item 1 (SC-1): Anchor five-tier hierarchy completeness

- RED: Enforcement check FAILS — content-element inventory comparison finds at least one element present in 060 §1 and absent from the mcp-tool-usage SKILL.md hierarchy section.
- GREEN: Add the missing hierarchy elements to SKILL.md (additive only).
- verify: Clean-room comparison of SKILL.md against live 060 §1; `skildeck-lint` passes.
- commit: SKILL.md hierarchy completeness.

### Item 2 (SC-2): Add glob semantics section to SKILL.md

- RED: Enforcement check FAILS — SKILL.md contains no glob semantics section.
- GREEN: Add the section (LIM-1..6 table, canonical path-parameter idiom, verified-working examples, forbidden shapes, empty-result disambiguation rule) between the hierarchy and Critical Rules content; extend the frontmatter description with glob triggers.
- verify: Content inspection plus `skildeck-lint`; confirm no glob-semantics duplication introduced outside the skill deck.
- commit: SKILL.md glob semantics section + description routing.

### Item 3 (SC-3): Update selection-guide task card

- RED: Enforcement check FAILS — the selection-guide task card contains no glob semantics guidance.
- GREEN: Add glob tool selection guidance referencing the SKILL.md glob semantics section.
- verify: Content inspection of the task card.
- commit: selection-guide glob guidance.

### Item 4 (SC-4): Reroute consuming cards' Read-links

- RED: grep finds at least one glob-context Read-link to `060-tool-usage.md` in a consuming card.
- GREEN: Replace each glob-context Read-link with a Read-link to the mcp-tool-usage SKILL.md (link-only change; surrounding prose semantics unchanged).
- verify: grep — zero glob-context `060-tool-usage.md` Read-links remain; each consuming card carries an mcp-tool-usage Read-link.
- commit: Read-link rerouting across consuming cards.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/guidelines/060-tool-usage.md` §2 | Source content for the glob semantics anchor; SHALL be read live at implementation time (no cached copies) | Satisfied — present at spec time |
| `.opencode/skills/mcp-tool-usage/` skill deck | Target of the anchor; SHALL exist before anchoring | Satisfied — present at spec time |
| 060 condensation issue (downstream) | SHALL be merged only after SC-1..SC-4 pass; SHALL NOT remove 060 §2 before this spec completes | Pending — follow-up issue |
| `.opencode/reference/spec-structure-standards.md` | Structure standard this spec is assembled against | Satisfied |
| `.opencode/reference/cost-model-standards.md` | Cost-frame standard this spec follows | Satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-2 | Phase 2 |
| R-4 | SC-2 | Phase 2 |
| R-5 | SC-2 | Phase 2 |
| R-6 | SC-2 | Phase 2 |
| R-7 | SC-3 | Phase 3 |
| R-8 | SC-4 | Phase 4 |
| R-9 | SC-2, SC-3, SC-4 | Phases 2-4 |
| R-10 | SC-1, SC-2, SC-3, SC-4 | Phases 1-4 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| mcp-tool-usage skill card | config | `.opencode/skills/mcp-tool-usage/SKILL.md` | Read at spec time: five-tier hierarchy present; no glob semantics section |
| 060-tool-usage guideline §1-§2 | doc | `.opencode/guidelines/060-tool-usage.md` | Read at spec time: §1 tier summary + redirect to skill; §2 glob semantics LIM-1..LIM-6 |
| selection-guide task card | doc | `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` | Read at spec time: no glob semantics content |
| Consuming cards (glob Read-links) | doc | 6 files, 7 link sites (listed in SC-4 Documentation Sources) | grep at spec time: 7 glob-context Read-links to `060-tool-usage.md` |
| spec-structure-standards | doc | `.opencode/reference/spec-structure-standards.md` | Read at spec time |
| cost-model-standards | doc | `.opencode/reference/cost-model-standards.md` | Read at spec time |
| Glob tool limitation probing | doc (recorded) | `060-tool-usage.md` §2.1 provenance | Live probing recorded 2026-08-26 against this repository |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying hierarchy completeness against live 060 §1 costs one clean-room comparison. Skipping means hierarchy elements silently drop at condensation time and every downstream tool-selection decision misroutes until the missing tier is noticed in production — a 1000× death-spiral entry.
- **SC-2:** Inspecting the glob section for all six LIM entries, the canonical idiom, and the disambiguation rule costs one content read. Skipping means agents revert to silent-empty glob shapes and record false absence conclusions — each false absence costs a full rework cycle when the "missing" artifact resurfaces downstream.
- **SC-3:** Verifying selection-guide references the glob section costs one read. Skipping means dispatched tool-selection sub-agents decide glob questions from memory instead of the anchored limitation set.
- **SC-4:** Running the grep criterion costs seconds. Skipping means Read-links dangle the moment 060 condensation merges and every consuming card silently degrades to memory-based glob behavior — link rot discovered only at first misrouting.

## Edge Cases

- **Input boundaries:** `060-tool-usage.md` §2 is edited between spec approval and implementation (source drift). Expected behavior: the implementer SHALL re-read 060 §2 live at GREEN time; the anchored content reflects the live source, not a cached copy. Resolution: SC-2 verification compares against the live 060 §2 at verify time.
- **State transitions:** Phases run sequentially (SC-1 → SC-2 → SC-3 → SC-4). SC-4 depends on SC-2 because a Read-link to a skill card that does not yet contain the glob section is a dangling reference during the transition; the dependency DAG keeps the reroute last.
- **Failure modes:** A new consuming card with a glob Read-link to 060 appears between spec approval and implementation. Expected behavior: SC-4's pattern-defined grep criterion SHALL catch it — the consuming set is not a frozen file list. Resolution: the RED grep re-runs at implementation time and discovers the current consuming set.
- **Failure modes:** Remote label write fails (label absent on the remote platform). Expected behavior: the pipeline proceeds; the local `issue.yaml` labels array is canonical. Resolution: remote label application is best-effort and never blocking.
- **Failure modes:** The remote issue already exists at dispatch time (retroactive import). Expected behavior: the existing issue number SHALL be reused; no duplicate issue POST. Resolution: check-before-POST per the non-idempotent API mutation rule.
- **Failure modes:** SKILL.md growth (~40 lines) breaks frontmatter or structural constraints. Expected behavior: `skildeck-lint` SHALL fail the verify step. Resolution: re-run the affected item's RED/GREEN cycle from the last known good commit.
- **Concurrency:** Not applicable — single-branch serialized content edits under the git workflow; no shared mutable state.
- **Recovery:** Any failed verify step restarts the affected item's RED/GREEN cycle from the last known good commit checkpoint; no partial state carries forward.

---

🤖 Co-authored with AI: OpenCode (huggingface/Qwen/Qwen3.8-2.4T-A95B)
