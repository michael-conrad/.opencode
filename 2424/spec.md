> **Full spec and artifacts: [`.opencode/.issues/2424/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2424)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2424/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Remediate executing-plans SKILL.md — missing sub-agent dispatch text and validator conformance defects

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The skill card at `.opencode/skills/executing-plans/SKILL.md` is the only non-conforming skill card in the deck. Its Workflows section has 2 dispatch entries missing the `You are a sub-agent.` role-identification prefix that every other dispatch entry in the deck carries, and the validator (`validate_skill_cards.py`) flags the card on REQ-2, REQ-3, REQ-6, and CONDENSATION-001. |
| 2 | **Root Cause / Motivation** | The card's dispatch prompt strings begin directly with `Follow the instructions in [...]` and lack the `You are a sub-agent.` prefix. Because `task()` does not auto-load task cards, the sub-agent must receive the role-identification prefix so it reads the task card independently. The card also carries a hardcoded agent name in its byline (REQ-2), lacks the `## Worktree Mode` section (REQ-3), uses checkbox-format workflow steps (REQ-6), and uses path-restatement dispatch link text (CONDENSATION-001). This breaks the DISPATCH_GATE conformance baseline. |
| 3 | **Approach Chosen** | Edit `.opencode/skills/executing-plans/SKILL.md` to align its Workflows dispatch entries with the deck's conforming pattern: prepend `You are a sub-agent.` to both dispatch prompt strings, convert the Workflows section to numbered format (REQ-6), add the `## Worktree Mode` section (REQ-3), replace the hardcoded agent name with the placeholder convention (REQ-2), and rewrite the dispatch link text to purpose condensation (CONDENSATION-001). Re-validate against `validate_skill_cards.py` until the card passes all checks. |
| 4 | **Alternatives Considered & Why Discarded** | **Leave the card non-conforming** — discarded because the card would continue to break the DISPATCH_GATE conformance baseline and route sub-agents without the role-identification prefix, producing defective dispatch behavior. **Modify the validator to exempt the card** — discarded because the validator is explicitly out of scope (REQ-J) and the card should conform to the standard, not the standard to the card. |
| 5 | **Key Design Decisions** | **Dispatch prompt prefix is inside the quoted prompt string** — the `You are a sub-agent.` prefix must be inside the quoted prompt passed to the sub-agent, forming the canonical template `concat("You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context...>")`. **Link text is a purpose condensation, not a path restatement** — the href/path stays the same so sub-agent discovery still resolves; only the label text changes. **Task cards and validator are untouched** — behavior of `read-plan.md`/`dispatch-phase.md` and the validator are explicitly out of scope. |
| 6 | **User Intent / Original Prompt** | The spec was created to remediate the executing-plans SKILL.md card so it conforms to the current skill-card standards and passes the validator. |

## 2. Not Included

- **Changes to the `executing-plans` task files (`read-plan.md`, `dispatch-phase.md`) behavior** — task behavior is explicitly out of scope (REQ-H); the task purpose statements serve only as condensation sources.
- **Any change to other skill cards in the deck** — other cards' violations (including SC-LINT-001 description-pattern warnings) are out of scope (REQ-I).
- **Any change to the validator (`validate_skill_cards.py`) itself** — the validator is a read-only reference for the gate (REQ-J).
- **Change to the executing-plans description field** — it already conforms (no SC-LINT-001 on description); not listed for change (REQ-K).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `read-plan` dispatch entry prompt text SHALL begin with the `You are a sub-agent.` prefix inside the quoted prompt string, immediately before `Follow the instructions in`. | string | grep the read-plan Prompt sub-bullet for the `You are a sub-agent.` prefix; visual diff against the conforming spec-creation pattern |
| SC-2 | The `dispatch-phase` dispatch entry prompt text SHALL begin with the `You are a sub-agent.` prefix inside the quoted prompt string, immediately before `Follow the instructions in`. | string | grep the dispatch-phase Prompt sub-bullet for the `You are a sub-agent.` prefix; visual diff against the conforming spec-creation pattern |
| SC-3 | The byline SHALL use the placeholder form `Co-authored with AI: <AgentName> (<ModelId>)` instead of the hardcoded `OpenCode (deepseek-v4-flash)`. | string | grep the byline for `<AgentName> (<ModelId>)`; assert the hardcoded `OpenCode (deepseek-v4-flash)` is absent |
| SC-4 | The card SHALL include a `## Worktree Mode` section using the deck's canonical direct-branch wording. | string | grep for the `## Worktree Mode` heading; visual diff against the conforming spec-creation pattern |
| SC-5 | The Workflows section SHALL use the numbered `N. **` format without the `- [ ] ` checkbox prefix. | string | grep the Workflows section for the `- [ ] N. **` checkbox prefix; assert it is absent |
| SC-6 | The `read-plan` dispatch link text SHALL be a purpose condensation (`inventory plan phases`) that differs from the path stem and does not contain `tasks/` or end in `.md`. | string | grep the read-plan dispatch link label; assert it equals the purpose condensation and differs from the path stem |
| SC-7 | The `dispatch-phase` dispatch link text SHALL be a purpose condensation (`dispatch one plan phase`) that differs from the path stem and does not contain `tasks/` or end in `.md`. | string | grep the dispatch-phase dispatch link label; assert it equals the purpose condensation and differs from the path stem |
| SC-8 | The card SHALL pass the full validator suite with zero violations for skill `executing-plans`. | behavioral | Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`; assert the `executing-plans` skill_name has an empty violations list |

## 4. Requirements

- R-1. The `read-plan` dispatch entry prompt text SHALL begin with the `You are a sub-agent.` prefix inside the quoted prompt string.
- R-2. The `dispatch-phase` dispatch entry prompt text SHALL begin with the `You are a sub-agent.` prefix inside the quoted prompt string.
- R-3. The byline SHALL use the placeholder form `Co-authored with AI: <AgentName> (<ModelId>)` instead of the hardcoded `OpenCode (deepseek-v4-flash)`.
- R-4. The card SHALL include a `## Worktree Mode` section using the deck's canonical direct-branch wording.
- R-5. The Workflows section SHALL use the numbered `N. **` format without the `- [ ] ` checkbox prefix.
- R-6. The `read-plan` dispatch link text SHALL be a purpose condensation (`inventory plan phases`) that differs from the path stem.
- R-7. The `dispatch-phase` dispatch link text SHALL be a purpose condensation (`dispatch one plan phase`) that differs from the path stem.
- R-8. The card SHALL pass the full validator suite with zero violations for skill `executing-plans`.
- R-9. The `executing-plans` task files (`read-plan.md`, `dispatch-phase.md`) SHALL NOT be modified.
- R-10. No other skill card in the deck SHALL be modified.
- R-11. The validator (`validate_skill_cards.py`) SHALL NOT be modified.

## 5. Items

### Item 1 (SC-1): Add `You are a sub-agent.` prefix to read-plan dispatch prompt

- RED: grep the read-plan Prompt sub-bullet; assert the `You are a sub-agent.` prefix is absent
- GREEN: prepend `You are a sub-agent.` to the read-plan dispatch prompt string inside the quote
- verify: grep for `You are a sub-agent` in the read-plan prompt; visual diff vs conforming spec-creation pattern
- commit: the read-plan Prompt sub-bullet change

### Item 2 (SC-2): Add `You are a sub-agent.` prefix to dispatch-phase dispatch prompt

- RED: grep the dispatch-phase Prompt sub-bullet; assert the `You are a sub-agent.` prefix is absent
- GREEN: prepend `You are a sub-agent.` to the dispatch-phase dispatch prompt string inside the quote
- verify: grep `You are a sub-agent` in the dispatch-phase prompt
- commit: the dispatch-phase Prompt sub-bullet change

### Item 3 (SC-3): Resolve REQ-2 — replace hardcoded agent name in byline

- RED: run `validate_skill_cards.py --json`; assert the byline placeholder violation is present
- GREEN: replace `OpenCode (deepseek-v4-flash)` with `<AgentName> (<ModelId>)` in the byline
- verify: grep the byline for `<AgentName> (<ModelId>)`; assert the hardcoded name is absent
- commit: the byline change

### Item 4 (SC-4): Resolve REQ-3 — add missing `## Worktree Mode` section

- RED: run `validate_skill_cards.py --json`; assert the worktree-mode violation is present
- GREEN: insert the `## Worktree Mode` section with canonical direct-branch wording
- verify: grep for the `## Worktree Mode` heading; visual diff vs conforming spec-creation pattern
- commit: the Worktree Mode section addition

### Item 5 (SC-5): Resolve REQ-6 — convert Workflows steps to numbered format

- RED: run `validate_skill_cards.py --json`; assert the workflows-steps violation is present
- GREEN: convert `- [ ] N. **` checkbox headers to `N. **` numbered format, preserving sub-bullets
- verify: grep the Workflows section for the `- [ ] N. **` checkbox prefix; assert it is absent
- commit: the Workflows section format change

### Item 6 (SC-6): Resolve CONDENSATION-001 — rewrite read-plan dispatch link text to purpose condensation

- RED: run `validate_skill_cards.py --json`; assert the CONDENSATION-001 violation for read-plan is present
- GREEN: rewrite the read-plan dispatch link text to `inventory plan phases`
- verify: grep the read-plan dispatch link label; assert it equals `inventory plan phases` and differs from the path stem
- commit: the read-plan link text change

### Item 7 (SC-7): Resolve CONDENSATION-001 — rewrite dispatch-phase dispatch link text to purpose condensation

- RED: run `validate_skill_cards.py --json`; assert the CONDENSATION-001 violation for dispatch-phase is present
- GREEN: rewrite the dispatch-phase dispatch link text to `dispatch one plan phase`
- verify: grep the dispatch-phase dispatch link label; assert it equals `dispatch one plan phase` and differs from the path stem
- commit: the dispatch-phase link text change

### Item 8 (SC-8): Full validator conformance gate — executing-plans card passes all checks

- RED: run `validate_skill_cards.py --json`; assert the executing-plans violations list is non-empty
- GREEN: (no code change — gate verifies items 1-7 collectively)
- verify: run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`; grep executing-plans violations list == empty
- commit: (no commit — gate only)
- dependency: depends on items 1-7

## 6. Dependencies

- **Reference:** `.opencode/reference/skill-card-schema.md` — defines the frontmatter binary constraints and the ATTRIBUTION_EXEMPT placeholder regex. **Relationship:** must be read before implementation to confirm the byline placeholder form. **Status:** satisfied.
- **Reference:** `.opencode/reference/skill-card-description-standards.md` — defines the description field semantic router and the canonical dispatch template. **Relationship:** must be read before implementation to confirm the dispatch prompt shape. **Status:** satisfied.
- **Reference:** `.opencode/skills/spec-creation/SKILL.md` — the deck's conforming reference card establishing the dispatch prompt pattern. **Relationship:** must be read before implementation as the conformance reference. **Status:** satisfied.
- **Reference:** `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` — the read-only validator used for the conformance gate. **Relationship:** must be run to verify conformance; must not be modified. **Status:** satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 2 |
| R-4 | SC-4 | Phase 2 |
| R-5 | SC-5 | Phase 2 |
| R-6 | SC-6 | Phase 3 |
| R-7 | SC-7 | Phase 3 |
| R-8 | SC-8 | Phase 4 (gate) |
| R-9 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | All |
| R-10 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | All |
| R-11 | SC-8 | Phase 4 (gate) |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| executing-plans SKILL.md | code | `.opencode/skills/executing-plans/SKILL.md` | read tool (62 lines) |
| spec-creation SKILL.md (conforming reference) | code | `.opencode/skills/spec-creation/SKILL.md` | read tool |
| skill-card-schema.md | doc | `.opencode/reference/skill-card-schema.md` | read tool |
| skill-card-description-standards.md | doc | `.opencode/reference/skill-card-description-standards.md` | read tool |
| validate_skill_cards.py | code | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | validator execution |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the read-plan dispatch prompt carries the `You are a sub-agent.` prefix costs one grep search. Skipping means the read-plan dispatch-routing defect ships — the sub-agent is dispatched without the role-identification prefix and fails to read the task card independently, surfacing as a behavioral failure at the first read-plan dispatch.
- **SC-2:** Verifying the dispatch-phase dispatch prompt carries the `You are a sub-agent.` prefix costs one grep search. Skipping means the dispatch-phase dispatch-routing defect ships — the sub-agent is dispatched without the role-identification prefix and fails to read the task card independently, surfacing as a behavioral failure at the first dispatch-phase dispatch.
- **SC-3:** Verifying the byline uses the placeholder form costs one grep search. Skipping means the hardcoded agent name persists, and the REQ-2 violation is only caught at the next validator run — a death-spiral start where a string PASS masks a conformance defect.
- **SC-4:** Verifying the `## Worktree Mode` section exists costs one grep search. Skipping means the missing-section defect ships, and the REQ-3 violation is only caught at the next validator run.
- **SC-5:** Verifying the Workflows section uses numbered format costs one grep search. Skipping means the checkbox-format defect ships, and the REQ-6 violation is only caught at the next validator run.
- **SC-6:** Verifying the read-plan dispatch link text is a purpose condensation costs one grep search. Skipping means the path-restatement link text persists, and the CONDENSATION-001 violation is only caught at the next validator run.
- **SC-7:** Verifying the dispatch-phase dispatch link text is a purpose condensation costs one grep search. Skipping means the path-restatement link text persists, and the CONDENSATION-001 violation is only caught at the next validator run.
- **SC-8:** Running the full validator suite costs minutes of execution time. Skipping means the conformance defects (REQ-2/3/6, CONDENSATION-001) ship unchanged and the card remains the deck's only non-conforming card, breaking the DISPATCH_GATE baseline and failing the next skill-creator audit.

## 11. Edge Cases

- **Input boundaries:** The `You are a sub-agent.` prefix must be inserted inside the quoted prompt string, immediately before `Follow the instructions in`. Inserting it outside the quote or after `Follow` produces a malformed dispatch prompt. **Expected behavior:** the prefix SHALL be inside the quote, immediately before `Follow the instructions in`. **Resolution:** verify by grep + visual diff against the conforming spec-creation pattern.
- **State transitions:** The card transitions from `non_conformant` → `partial` (after phase 1 or phase 2) → `conformant` (all fixes applied) → `validated` (gate passes). A regression (edit reverts a fix) returns the card to `non_conformant`. **Expected behavior:** each phase's edits are confined to disjoint regions of SKILL.md so diffs are revert-isolated. **Resolution:** if the validator reports a new violation class (e.g., workflows-sub-bullets broken by REQ-6 renumbering), return to the failing rule, fix, and re-validate.
- **Failure modes:** If the validator still reports an executing-plans violation after remediation, the card is in `gate_failed` state. **Expected behavior:** diagnose the specific rule id and re-apply the fix. **Resolution:** return to `conformant` and re-run the gate.
- **Concurrency:** All phases edit the same single file (executing-plans/SKILL.md). Non-overlap must be preserved to keep each phase's diff isolated. **Expected behavior:** edits touch disjoint regions (Prompt sub-bullets, byline/section/headers, link labels). **Resolution:** keep edits confined to disjoint regions per phase.
- **Recovery:** If a phase's edit is reverted or malformed, the card returns to `non_conformant`. **Expected behavior:** re-apply the fix and re-validate. **Resolution:** the validator gate catches any regression before completion.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-31 | Decomposed compound SC-1/SC-2/SC-3 into 8 atomic SCs (one per verification target); fixed SC-to-item mapping to exactly one item per SC; corrected SC-8 evidence type to `behavioral`; resolved CONDENSATION-001 overlap so it appears only in SC-6/SC-7 (with SC-8 as the aggregate gate). | Validation findings: compound SCs, SC-to-item mapping violation, EVIDENCE_TYPE_MISMATCH on SC-2, CONDENSATION-001 double-mapping. | spec-creation validation gate |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
