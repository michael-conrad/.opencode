---
remote_issue: 2346
remote_url: https://github.com/michael-conrad/.opencode/issues/2346
promoted_at: 2026-08-27T03:25:12.649724+00:00
labels:
- needs-approval
- spec-draft
number: 2346
state: OPEN
title: '[SPEC] Condense 000-critical-rules.md — retain safety-critical cores only'
---

> **Full spec and artifacts: [`.opencode/.issues/2346/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2346)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2346/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

`.opencode/guidelines/000-critical-rules.md` is fully preloaded into orchestrator context via `.opencode/opencode.jsonc`. It costs ~8.3k tokens (~10% of the preloaded guideline burden) before the user's first prompt, yet ~10% of its content is procedural (cross-reference tables, mandate-tiering prose, channel-routing table) that duplicates skill-card content.

## Root Cause / Motivation

The file is the #497 regression-proof file: it MUST stay preloaded because a prior agent merged a PR when the file was absent from orchestrator context. But its movable procedural scaffolding — the Mandate Tiering section and the Channel-Routing Table section — duplicates content already canonically hosted in the `approval-gate` skill card and the `issue-operations-comments` skill card. The change is needed now because the duplicated procedural content inflates the preload cost without adding safety-critical value, and the relocation mechanism (mandatory `Read [Text](path)` links) is validated at 100% Tier 1 access rate by the cross-reference-form-comparison research card.

## Approach Chosen

Keep the file essentially fully preloaded (it is the #497 regression-proof file), but strip its movable procedural scaffolding — the `## Mandate Tiering` section and the `## Channel-Routing Table` section — replacing them with mandatory `Read [Text](path)` links to the canonical skill-card targets. The mandate-tiering content relocates to the `approval-gate` skill card; the channel-routing content relocates to the `issue-operations-comments` skill card. ALL `critical-rules-XXX` blocks remain byte-identical in orchestrator context.

## Alternatives Considered & Why Discarded

1. **Remove the movable sections entirely without relocation.** Discarded: this destroys safety-relevant procedural rules instead of moving them. The issue's requirement is to relocate, not delete — the information must remain accessible via the canonical `Read [Text](path)` form.
2. **Create a new shared canonical reference file and add it to the opencode.jsonc instructions array.** Discarded: this expands the preload footprint and requires an opencode.jsonc edit. The analysis confirms the content already exists in the `approval-gate` and `issue-operations-comments` skill cards — the canonical homes are the existing skill cards, not a new file.
3. **Rely on INDEX.md as the fallback for Tier 1.** Discarded: INDEX.md is for Tier 2+ sub-agent routing only; removing `000-critical-rules.md` from preload caused #497. The file MUST remain in the instructions array.

## Key Design Decisions

1. **`000-critical-rules.md` remains in the opencode.jsonc instructions array (preloaded).** Tradeoff: preserves the #497 regression-proof, at the cost of the file staying a preload burden (only the ~33 movable lines are removed).
2. **Relocation targets are the existing skill cards, not a new shared reference file.** Tradeoff: no opencode.jsonc edit is required and no new file is created, at the cost of relying on the `Read [Text](path)` link form (validated at 100% Tier 1 access) to preserve access to the relocated content.
3. **ALL `critical-rules-XXX` blocks are retained byte-identical.** Tradeoff: preserves every safety-critical core verbatim, at the cost of limiting token savings to the ~33 standalone movable lines (the git-config tables inside `critical-rules-026` are procedural but reside inside the block and are therefore retained).

## User Intent / Original Prompt

The user requested condensing `000-critical-rules.md` to retain only its safety-critical cores, relocating the procedural (duplicated) sections to skill cards via mandatory `Read [Text](path)` links while keeping the file essentially fully preloaded as the #497 regression-proof.

## Not Included

- **Removing any safety-critical core** — no `critical-rules-XXX` block is removed or modified; all are retained byte-identical.
- **Changing the human-only-merge rule (`critical-rules-merge`)** — retained verbatim.
- **Changing the no-self-authorization rule (`critical-rules-006`)** — retained verbatim.
- **Relying on INDEX.md as the fallback for Tier 1** — INDEX.md is for Tier 2+ sub-agent routing only; the file stays preloaded.
- **Moving the git-config authorization tables inside `critical-rules-026`** — these are procedural but reside inside the block and are retained verbatim per the retain-intact mandate.
- **Any application source code, test fixtures, DB, or production data** — this is a documentation/agent-config change in the `.opencode` repo only.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `.opencode/guidelines/000-critical-rules.md` is condensed by removing the movable standalone procedural sections (`## Mandate Tiering` and `## Channel-Routing Table`) and replacing them with mandatory `Read [Text](path)` links to the relocation targets, while ALL `critical-rules-XXX` blocks remain byte-identical. | structural | Read `000-critical-rules.md`; assert the two movable sections are removed and replaced with `Read [Text](path)` links; diff the `critical-rules-XXX` blocks against the pre-condensation baseline and assert byte-identical. | `.opencode/guidelines/000-critical-rules.md` (source) |
| SC-2 | The mandate-tiering content (Mandate Tiering table, Interaction Rule table, three-tier prose) is hosted canonically in the `approval-gate` skill card, and `000-critical-rules.md` references it via a mandatory `Read [Text](path)` link. | structural | Read the `approval-gate` skill card and assert the mandate-tiering content is present; assert the `Read [Text](path)` link in `000-critical-rules.md` resolves to the skill card. | `.opencode/skills/approval-gate/SKILL.md` (source) |
| SC-3 | The channel-routing table content (Action to Channel) is hosted canonically in the `issue-operations-comments` skill card, and `000-critical-rules.md` references it via a mandatory `Read [Text](path)` link. | structural | Read the `issue-operations-comments` skill card and assert the channel-routing content is present; assert the `Read [Text](path)` link in `000-critical-rules.md` resolves to the skill card. | `.opencode/skills/issue-operations-comments/SKILL.md` (source) |
| SC-4 | `000-critical-rules.md` remains in the `.opencode/opencode.jsonc` instructions array (still preloaded into orchestrator context), and no safety-critical core is removed — the human-only-merge rule (`critical-rules-merge`) and no-self-authorization rule (`critical-rules-006`) are unchanged. | structural | Read `.opencode/opencode.jsonc` instructions array and assert `000-critical-rules.md` is present; grep `000-critical-rules.md` and assert `critical-rules-merge` and `critical-rules-006` blocks are intact. | `.opencode/opencode.jsonc`, `.opencode/guidelines/000-critical-rules.md` (sources) |
| SC-5 | A real-domain prompt (via `opencode run` behavioral enforcement test) confirms the condensed `000-critical-rules.md` still causes the agent to enforce the retained safety-critical cores (no self-authorization, human-only-merge), and that the `Read [Text](path)` links cause the agent to load the relocated skill content. | behavioral | Run the behavioral enforcement test via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert via stderr-based helpers (`assert_stderr_pattern_present` / `assert_stderr_pattern_absent_all_models`) that the agent enforces the retained safety cores and loads the relocated content via the Read-link. | `.opencode/tests-v2/behaviors/` (behavioral test harness) |

## Requirements

- **R-1.** `000-critical-rules.md` SHALL be condensed to its safety-critical Tier 1 mandate cores.
- **R-2.** The movable standalone procedural sections (`## Mandate Tiering`, `## Channel-Routing Table`) SHALL be removed and replaced with mandatory `Read [Text](path)` links to the relocation targets.
- **R-3.** ALL `critical-rules-XXX` blocks SHALL remain byte-identical.
- **R-4.** `000-critical-rules.md` SHALL remain in the `.opencode/opencode.jsonc` instructions array (preloaded into orchestrator context).
- **R-5.** The relocated procedural content SHALL remain accessible to the orchestrator via the canonical `Read [Text](path)` inline-link form.
- **R-6.** The mandate-tiering content SHALL be hosted canonically in the `approval-gate` skill card.
- **R-7.** The channel-routing content SHALL be hosted canonically in the `issue-operations-comments` skill card.
- **R-8.** The condensation SHALL NOT remove any safety-critical core, change the human-only-merge rule, or change the no-self-authorization rule.

## Items

### Item 1 (SC-1): Condense 000-critical-rules.md

- RED: Read `000-critical-rules.md` — the movable sections (`## Mandate Tiering`, `## Channel-Routing Table`) are still present and not yet replaced with `Read [Text](path)` links.
- GREEN: Remove the two movable sections and replace them with mandatory `Read [Text](path)` links to the relocation targets; retain ALL `critical-rules-XXX` blocks byte-identical.
- verify: Read `000-critical-rules.md` and assert the movable sections are removed, the `Read [Text](path)` links are present, and the `critical-rules-XXX` blocks diff byte-identical against the pre-condensation baseline.
- commit: `.opencode/guidelines/000-critical-rules.md`.

### Item 2 (SC-2): Relocate mandate-tiering content to the approval-gate skill card

- RED: Read the `approval-gate` skill card — the mandate-tiering content is absent.
- GREEN: Add the canonical mandate-tiering content (Mandate Tiering table, Interaction Rule table, three-tier prose) to the `approval-gate` skill card; ensure the `Read [Text](path)` link in `000-critical-rules.md` resolves to it.
- verify: Read the `approval-gate` skill card and assert the mandate-tiering content is present; assert the `Read [Text](path)` link resolves.
- commit: `.opencode/skills/approval-gate/SKILL.md`.

### Item 3 (SC-3): Relocate channel-routing content to the issue-operations-comments skill card

- RED: Read the `issue-operations-comments` skill card — the channel-routing content is absent.
- GREEN: Add the canonical channel-routing table content to the `issue-operations-comments` skill card; ensure the `Read [Text](path)` link in `000-critical-rules.md` resolves to it.
- verify: Read the `issue-operations-comments` skill card and assert the channel-routing content is present; assert the `Read [Text](path)` link resolves.
- commit: `.opencode/skills/issue-operations-comments/SKILL.md`.

### Item 4 (SC-4): Verify preload preservation (#497 regression-proof)

- RED: Assert the file was dropped from the instructions array or a safety core was removed (fails the preservation check).
- GREEN: Assert `000-critical-rules.md` remains in the `.opencode/opencode.jsonc` instructions array and `critical-rules-merge` / `critical-rules-006` are intact.
- verify: Read `.opencode/opencode.jsonc` instructions array and grep `000-critical-rules.md` for the two safety-core blocks.
- commit: `.opencode/opencode.jsonc` (only if an edit is required; otherwise verification-only, no commit).

### Item 5 (SC-5): Behavioral enforcement test

- RED: Run the behavioral enforcement test — the agent does NOT follow a retained safety rule (e.g., self-authorization) or does NOT load the relocated content via the Read-link.
- GREEN: Ensure the condensed file + relocated content cause the agent to enforce the retained safety cores and load the relocated content via the Read-link.
- verify: Run `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and assert via stderr-based helpers that the agent enforces the retained safety cores and loads the relocated content.
- commit: `.opencode/tests-v2/behaviors/<scenario>.sh`.

## Dependencies

- **Reference:** `.opencode/guidelines/000-critical-rules.md` (source file)
  - **Relationship:** Must be read before condensation; the movable sections are identified by section name.
  - **Status:** Satisfied (source exists, 398 lines, tracked, clean).
- **Reference:** `.opencode/skills/approval-gate/SKILL.md` (relocation target)
  - **Relationship:** Must host the mandate-tiering content before the `Read [Text](path)` link is placed (SC-1 → SC-2).
  - **Status:** Satisfied (skill card exists; already carries a Mandate Tiering Interaction table).
- **Reference:** `.opencode/skills/issue-operations-comments/SKILL.md` (relocation target)
  - **Relationship:** Must host the channel-routing content before the `Read [Text](path)` link is placed (SC-1 → SC-3).
  - **Status:** Satisfied (skill card exists; already enforces the substantive comment gate).
- **Reference:** `.opencode/opencode.jsonc` (preload instructions array)
  - **Relationship:** Must keep `000-critical-rules.md` in the instructions array (SC-4 preservation).
  - **Status:** Satisfied (line 79 keeps the file in the array).
- **Reference:** cross-reference-form-comparison research card
  - **Relationship:** Validates the `Read [Text](path)` link form at 100% Tier 1 access rate (confidence 0.95).
  - **Status:** Satisfied (card exists at `.opencode/.issues/research-cards/cross-reference-form-comparison.md`).

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-1 | Item 1 |
| R-3 | SC-1, SC-4 | Item 1, Item 4 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-1, SC-2, SC-3, SC-5 | Item 1, Item 2, Item 3, Item 5 |
| R-6 | SC-2 | Item 2 |
| R-7 | SC-3 | Item 3 |
| R-8 | SC-1, SC-4 | Item 1, Item 4 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `000-critical-rules.md` | guideline source | `.opencode/guidelines/000-critical-rules.md` | read file, diff critical-rules-XXX blocks |
| `approval-gate` skill card | skill source | `.opencode/skills/approval-gate/SKILL.md` | read mandate-tiering content presence |
| `issue-operations-comments` skill card | skill source | `.opencode/skills/issue-operations-comments/SKILL.md` | read channel-routing content presence |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read instructions array for `000-critical-rules.md` |
| cross-reference-form-comparison research card | research | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read card (confidence 0.95) |
| behavioral test harness | test harness | `.opencode/tests-v2/with-test-home` | run `opencode run` with stderr-based assertions |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the condensation costs a read of `000-critical-rules.md` and a diff of the `critical-rules-XXX` blocks against baseline. Skipping means the movable sections stay in preload, and the token-reduction goal is silently not achieved — the preload burden persists.
- **SC-2:** Verifying the mandate-tiering relocation costs a read of the `approval-gate` skill card and a link-resolution check. Skipping means the relocated content is orphaned or the link is broken, and the orchestrator loses access to the mandate-tiering rules — a defect deferred until the next authorization decision.
- **SC-3:** Verifying the channel-routing relocation costs a read of the `issue-operations-comments` skill card and a link-resolution check. Skipping means the channel-routing rules are lost, and a non-substantive progress update is posted to a GitHub Issue — a defect deferred until the next comment gate.
- **SC-4:** Verifying preload preservation costs a read of `opencode.jsonc` and a grep for the two safety-core blocks. Skipping means the #497 regression recurs — the file is dropped from preload and a future agent merges a PR without authorization.
- **SC-5:** Running the behavioral enforcement test costs minutes of execution time. Skipping means the condensation ships without evidence that the retained safety cores still fire and the Read-links still load — a behavioral defect that reaches production and costs 1000× more to fix.

## Edge Cases

- **Input boundary — movable section absent:** If a movable section is already absent (previously condensed), SC-1's RED assertion on its presence fails and the item is a no-op; the condensation proceeds for the remaining section.
- **State transition — link target missing:** If the `approval-gate` or `issue-operations-comments` skill card is missing when the `Read [Text](path)` link is placed, SC-2/SC-3 link-resolution assertions fail and the relocation is blocked until the target exists (dependency order SC-1 → SC-2/SC-3).
- **Failure mode — broken Read-link:** If a `Read [Text](path)` link resolves to a nonexistent target, the orchestrator loses access to the relocated content. SC-2/SC-3 link-resolution assertions catch this; SC-5 behaviorally verifies the link causes loading.
- **Failure mode — #497 regression:** If `000-critical-rules.md` is dropped from the instructions array, agents may merge PRs or self-authorize. SC-4 preservation assertion catches this; SC-5 behaviorally verifies the retained cores still fire.
- **Concurrency:** This is a documentation/agent-config change with no shared state or transaction; no race condition or resource contention applies.
- **Recovery:** Every SC is a reversible, git-tracked file edit. A failed or partial change is repaired by re-running the corresponding item's GREEN edit; no state machine or rollback path is required.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
