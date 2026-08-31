> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2424/

## Problem

The skill card at `.opencode/skills/executing-plans/SKILL.md` is the only non-conforming skill card in the deck. Its Workflows section has 2 dispatch entries missing the "You are a sub-agent." role-identification text that every other dispatch entry in the deck carries, and the validator (`validate_skill_cards.py`) flags the card on REQ-2, REQ-3, REQ-6, and CONDENSATION-001. This defect breaks the DISPATCH_GATE conformance baseline — the card must carry the same role-identification prefix and conform to the current skill-card standards so it routes sub-agents correctly and passes validation.

## Scope

- Add the "You are a sub-agent." prefix to the `read-plan` dispatch entry text in the Workflows section
- Add the "You are a sub-agent." prefix to the `dispatch-phase` dispatch entry text in the Workflows section
- Remediate the validator conformance defects flagged on the card: REQ-2 (hardcoded agent name `OpenCode` in the byline, line 62), REQ-3 (missing `Worktree Mode` section), REQ-6 (Workflows section uses `- [ ] N. **` checkbox format instead of `N. **` numbered format), CONDENSATION-001 ×2 (dispatch link text is a path restatement, not a purpose condensation)
- Make the card conform to the current skill-card standards

**Out of scope:**
- Changes to the `executing-plans` task files (`read-plan.md`, `dispatch-phase.md`) behavior
- Any change to other skill cards in the deck
- Any change to the validator (`validate_skill_cards.py`) itself

## Approach

Edit `.opencode/skills/executing-plans/SKILL.md` to align its Workflows section dispatch entries with the deck's conforming pattern: prepend `"You are a sub-agent."` to both dispatch prompt strings, convert the Workflows section formatting from `- [ ] N. **` checkbox format to the `N. **` numbered format (REQ-6), add the missing `Worktree Mode` section (REQ-3), replace the hardcoded `OpenCode` agent name with the required placeholder convention (REQ-2), and rewrite the dispatch link text from path restatement to purpose condensation (CONDENSATION-001). The card is then re-validated against `validate_skill_cards.py` until it passes all checks and matches the conforming reference cards in the deck.

## Impact

- **Risk:** Subtle behavioral change in dispatch routing — mitigated by running the validator (`validate_skill_cards.py`) to confirm all checks pass and reviewing against a conforming reference card.
- **Risk:** Incomplete conformance (e.g., fixing REQ-6 but missing REQ-3) — mitigated by SC2 requiring the full validator suite to pass before completion.
- **Key dependency:** The current skill-card standards reference documents (`skill-card-schema.md`, `skill-card-description-standards.md`) define the conformance target.
- **Call to action:** Approve this spec to authorize remediation of the executing-plans SKILL.md card.

---
🤖 OpenCode (deepseek-v4-flash) created
