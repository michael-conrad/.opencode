> **Full spec and artifacts: [`issues/2353/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2353)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2353/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Condense 075-docs-verification.md — relocate procedural content to engineering-approach / verification-enforcement

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | The Tier 1 preloaded guideline `.opencode/guidelines/075-docs-verification.md` costs ~1.9k tokens, of which ~55% is procedural content (verification-source priority list, code-review checklist, illustrative examples) that duplicates content already consumed by the `engineering-approach` and `verification-enforcement` skills at implementation/verification time. This procedural content is preloaded into every agent session even though it is only exercised when those skills run. |
| 2 | **Root Cause / Motivation** | `075-docs-verification.md` is loaded unconditionally via the `opencode.jsonc` instructions array (Tier 1 preload). Its procedural sections — the source-priority list, the code-review checklist, and the illustrative examples — overlap the `engineering-approach` operating-protocol (which already Read-links the source-priority order) and the `verification-enforcement` content-generation gate. Keeping this procedural detail in the always-loaded guideline wastes tokens on every session while duplicating what the consuming skills already provide. |
| 3 | **Approach Chosen** | Relocate the three procedural content blocks to their consuming skills before removing them from the preloaded guideline: (1) inline the verification-source priority list into `engineering-approach/tasks/operating-protocol.md` step 5, (2) relocate the code-review checklist to `verification-enforcement`, (3) relocate the illustrative examples to `verification-enforcement`. Then condense `075-docs-verification.md` to retain only the zero-tolerance verify-against-live-docs core (Zero Tolerance Rule, Rule, critical-rules-008 enforcement block). The guideline remains preloaded; the file is not removed from the instructions array. |
| 4 | **Alternatives Considered & Why Discarded** | **Remove the guideline entirely and rely on the skills.** Discarded: `075-docs-verification.md` is a Tier 1 zero-tolerance rule that MUST remain preloaded — removing it from the instructions array caused a safety regression precedent (#497). The core mandate must be visible to every agent, not only those who load `engineering-approach` or `verification-enforcement`. |
| 5 | **Key Design Decisions** | **Relocate-before-remove ordering.** The source-priority list, checklist, and examples must exist in their target skill before they are removed from the guideline, guaranteeing content preservation (dependency DAG: SC-1/SC-2/SC-3 → SC-4). **Core retention with preload intact.** The condensed guideline keeps the Zero Tolerance Rule, the Rule, and the critical-rules-008 block, so the `opencode.jsonc` instructions array entry stays and all 12 Tier 1 guidelines remain loaded. **Inline Read-link cross-reference form.** Relocated content that references the retained core uses the inline `Read [Text](path)` form per AGENTS.md and the cross-reference-form-comparison research card (confidence 0.95), ensuring 100% Tier 1 access. |
| 6 | **User Intent / Original Prompt** | Condense `.opencode/guidelines/075-docs-verification.md` by moving the source-priority list to `engineering-approach`, achieving ~1.1k token savings while retaining the zero-tolerance verify-against-live-docs-before-implementing core. |

## 2. Not Included

- **Removing the live-docs-verification core** — The Zero Tolerance Rule, the Rule, and the critical-rules-008 enforcement block are the enforcement core and MUST remain in the preloaded guideline. Removing them is explicitly out of scope.
- **The `sre-runbook` "Verification Sources (in priority order)" table** — This is a domain-specific runbook table, not a duplicate of the generic guideline content, and does not need to change.
- **The "What Must Be Verified" table and "What COUNTS as Verification" sections** — These are procedural but not explicitly named in the issue scope. They are candidates for relocation, not mandated; this spec does not relocate them. The condensing scope is limited to the source-priority list, code-review checklist, and illustrative examples.
- **`opencode.jsonc` configuration change** — The guideline remains in the instructions array (core retained), so no config entry removal. No config interface change is made.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The verification-source priority list (official docs → source code/type hints → example files → config files) is inlined into `engineering-approach/tasks/operating-protocol.md` step 5, replacing the current `Read [075-docs-verification.md §Verification Sources (Priority Order)]` reference with the actual list content. | structural | Read `engineering-approach/tasks/operating-protocol.md` step 5 and assert the four priority items are present inline and the Read-link to the guideline's Verification Sources section is removed. |
| SC-2 | The code-review checklist from `075-docs-verification.md` (API calls match documentation, env var names match config, function params match type signatures, library usage matches docs, config formats match schema) is relocated into `verification-enforcement`. | structural | Read `verification-enforcement` files and assert the five code-review checklist items are present. |
| SC-3 | The illustrative examples from `075-docs-verification.md` (the Pydantic field-validator assumption-vs-verified example and the environment-variable assumption-vs-verified example, including their prohibited/correct pairs) are relocated into `verification-enforcement`. | structural | Read `verification-enforcement` files and assert the two example pairs (prohibited pattern + correct pattern) are present. |
| SC-4 | `.opencode/guidelines/075-docs-verification.md` is condensed to retain only the Zero Tolerance Rule, the Rule, and the critical-rules-008 enforcement block, with the relocated procedural sections (Verification Sources, Code Review Checklist, Examples) removed. | structural | Read `075-docs-verification.md` and assert the Zero Tolerance Rule heading, the Rule heading, and the critical-rules-008 heading are present, and the Verification Sources heading, Code Review Checklist heading, and Examples heading are absent. |
| SC-5 | All agent-facing cross-references to the retained live-docs core in `gh-cli/SKILL.md`, `gb-cli/SKILL.md`, `067-context-completeness.md`, `INDEX.md`, and `engineering-approach/tasks/operating-protocol.md` remain valid and any relocated content referencing the core uses the inline `Read [Text](path)` form. | structural | Grep the cross-reference sites for `075-docs-verification` and assert each reference resolves to the retained core, and assert relocated references use the inline Read-link form. |
| SC-6 | The condensed `075-docs-verification.md` achieves the ~1.1k token savings target relative to the original 5253 bytes / 183 lines, while the file remains present in the `opencode.jsonc` instructions array. | structural | Measure the condensed file size with `wc -c` and `wc -l` and assert the reduction is consistent with ~1.1k token savings; read `opencode.jsonc` and assert the `075-docs-verification.md` entry remains in the instructions array. |

## 4. Requirements

- R-1. The verification-source priority list SHALL be inlined into `engineering-approach/tasks/operating-protocol.md` step 5, replacing the Read-link to the guideline's Verification Sources section.
- R-2. The code-review checklist SHALL be relocated from `075-docs-verification.md` to `verification-enforcement`.
- R-3. The illustrative examples SHALL be relocated from `075-docs-verification.md` to `verification-enforcement`.
- R-4. `075-docs-verification.md` SHALL retain the Zero Tolerance Rule, the Rule, and the critical-rules-008 enforcement block after condensing.
- R-5. `075-docs-verification.md` SHALL remain in the `opencode.jsonc` instructions array after condensing.
- R-6. All agent-facing cross-references to the retained live-docs core SHALL remain valid and SHALL use the inline `Read [Text](path)` form.
- R-7. The condensed guideline SHALL achieve a token savings of approximately 1.1k tokens relative to the original file.

## 5. Items

### Item 1 (SC-1): Inline source-priority list into engineering-approach

- RED: Assert `engineering-approach/tasks/operating-protocol.md` step 5 still contains the Read-link to `075-docs-verification.md` and does not yet inline the four priority items.
- GREEN: Inline the verification-source priority list (official docs → source code/type hints → example files → config files) into step 5 and remove the Read-link.
- verify: Read step 5 and confirm the four priority items are present inline and the Read-link is removed.
- commit: Commit the `engineering-approach/tasks/operating-protocol.md` change.

### Item 2 (SC-2): Relocate code-review checklist to verification-enforcement

- RED: Assert `verification-enforcement` does not yet contain the five code-review checklist items.
- GREEN: Relocate the code-review checklist into `verification-enforcement`.
- verify: Read the `verification-enforcement` files and confirm the five checklist items are present.
- commit: Commit the `verification-enforcement` change.

### Item 3 (SC-3): Relocate illustrative examples to verification-enforcement

- RED: Assert `verification-enforcement` does not yet contain the two illustrative example pairs.
- GREEN: Relocate the two example pairs (Pydantic field-validator and environment-variable assumption-vs-verified) into `verification-enforcement`.
- verify: Read the `verification-enforcement` files and confirm the two example pairs are present.
- commit: Commit the `verification-enforcement` change.

### Item 4 (SC-4): Condense 075-docs-verification.md to the core

- RED: Assert `075-docs-verification.md` still contains the relocated procedural sections (Verification Sources, Code Review Checklist, Examples).
- GREEN: Remove the relocated procedural sections, retaining only the Zero Tolerance Rule, the Rule, and the critical-rules-008 block.
- verify: Read `075-docs-verification.md` and confirm the core headings are present and the relocated section headings are absent.
- commit: Commit the `075-docs-verification.md` condensing change.

### Item 5 (SC-5): Verify cross-reference integrity

- RED: Assert at least one cross-reference site (gh-cli, gb-cli, 067-context-completeness, INDEX.md, operating-protocol) still uses a form other than the inline Read-link for references that need to resolve to the retained core.
- GREEN: Ensure all cross-references to the retained core are valid and use the inline `Read [Text](path)` form.
- verify: Grep the cross-reference sites for `075-docs-verification` and confirm each resolves and uses the inline Read-link form.
- commit: Commit any cross-reference form fixes.

### Item 6 (SC-6): Verify token savings

- RED: Measure the current condensed guideline size and confirm it has NOT yet reached the target reduction.
- GREEN: (No source change — this is a verification gate.) Confirm the condensed guideline achieves ~1.1k token savings and remains in the instructions array.
- verify: Run `wc -c` and `wc -l` on `075-docs-verification.md` and confirm the reduction; read `opencode.jsonc` and confirm the entry remains.
- commit: No separate commit (verification-only item); evidence is captured in the verification artifact.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Issue #2365 (engineering-approach skill update — becomes canonical home for source-priority list) | Must be coordinated so `engineering-approach` is the canonical home for the source-priority list before the guideline is condensed | Pending |
| `engineering-approach/tasks/operating-protocol.md` | Already Read-links the source-priority list from `075-docs-verification.md`; this spec inlines that content (SC-1) | Satisfied (existing reference) |
| `verification-enforcement` skill | Content-generation verification gate; natural home for the relocated checklist and examples (SC-2, SC-3) | Satisfied (skill exists) |
| `opencode.jsonc` instructions array | Keeps `075-docs-verification.md` preloaded as a Tier 1 guideline; no removal (R-5) | Satisfied (core retained) |
| `cross-reference-form-comparison.md` research card (confidence 0.95) | Establishes inline `Read [Text](path)` as the only viable cross-reference form; governs SC-5 | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 4 |
| R-5 | SC-6 | Phase 6 |
| R-6 | SC-5 | Phase 5 |
| R-7 | SC-6 | Phase 6 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `075-docs-verification.md` | doc | `.opencode/guidelines/075-docs-verification.md` | Read (183 lines, 5253 bytes; section boundaries lines 9-23 and 162-181 core, lines 25-150 procedural) |
| `engineering-approach/tasks/operating-protocol.md` | doc | `.opencode/skills/engineering-approach/tasks/operating-protocol.md` | Read (step 5 Read-links the source-priority order from the guideline) |
| `verification-enforcement/SKILL.md` | doc | `.opencode/skills/verification-enforcement/SKILL.md` | Read (content-generation gate; does not currently contain checklist/examples) |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | Read (instructions array preloads `075-docs-verification.md`; WARNING requires all 12 Tier 1 loaded) |
| `INDEX.md` | doc | `.opencode/guidelines/INDEX.md` | Read (Tier 1 index entry for `075-docs-verification.md`) |
| `cross-reference-form-comparison.md` | research | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | Read (confidence 0.95; inline Read-link form is only viable form) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Inlining the source-priority list into the consuming skill costs one read of `operating-protocol.md`. Skipping means the content is lost when the guideline is condensed, and the source-priority order is no longer discoverable at implementation time — a defect discovered in production costing 1000× more to fix.
- SC-2: Relocating the code-review checklist costs one read of `verification-enforcement`. Skipping means the checklist is lost, weakening the content-generation verification gate and letting unverified content ship — a defect discovered at review, not gate 1.
- SC-3: Relocating the illustrative examples costs one read of `verification-enforcement`. Skipping means the examples are lost, reducing the gate's ability to distinguish assumption-based from verified implementation patterns.
- SC-4: Verifying the condensing retains the core costs one read of `075-docs-verification.md`. Skipping means a structurally-wrong condensing isn't caught until a session fails to enforce the zero-tolerance live-docs rule — a safety regression.
- SC-5: Verifying cross-reference integrity costs one grep across the reference sites. Skipping means a dangling reference to a removed section leaves agents unable to reach the retained core — an access regression with compounding cost.
- SC-6: Measuring token savings costs one `wc` call. Skipping means the primary motivation (token reduction) is unverified, and the condensing could ship without achieving its stated purpose.

## 11. Edge Cases

- **Input boundary — empty relocated source:** If the source-priority list, checklist, or examples are absent from `075-docs-verification.md` at condensing time, the relocation items (SC-1/SC-2/SC-3) MUST fail fast and report the missing content rather than condensing a guideline that never contained it.
- **State transition — relocate-before-remove:** The dependency DAG orders relocation (SC-1/SC-2/SC-3) strictly before condensing (SC-4). If any relocation item is incomplete, SC-4 MUST NOT remove the corresponding section, preserving content.
- **State transition — preload integrity:** If condensing (SC-4) would remove content the core depends on, or if `075-docs-verification.md` were removed from the instructions array, the Tier 1 preload invariant (all 12 guidelines loaded) is violated. The file SHALL remain preloaded with the core retained.
- **Failure mode — dangling cross-reference:** If a cross-reference site still points to a relocated section after condensing, SC-5 detects it and the fix MUST convert it to an inline `Read [Text](path)` reference to the retained core, per the cross-reference-form-comparison research card.
- **Failure mode — verification source differs from target:** If a cross-reference uses a form other than the inline Read-link (e.g., "See `file` §section"), SC-5 MUST flag it as a defect per AGENTS.md Read-Link Cross-Reference Rule and require the inline form.
- **Concurrency — no runtime state:** This is a documentation/guideline restructure; no source code symbols or runtime state change. There is no concurrency-sensitive code path.
- **Recovery:** Each item's verification gate re-reads the target file and asserts the expected content. If verification fails, the item is remediated (content re-relocated or re-condensed) before the next item proceeds; no partial condensing ships.

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
