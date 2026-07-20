## Phase 6 — Update validation script

**Parent:** #1784

Add a REQ check to `validate_skill_cards.py` that validates complete DISPATCH_GATE subsections. Use the same pattern as existing REQ checks (REQ-1 through REQ-5). The check MUST:
- Verify presence of all 7 canonical subsections
- Allow opt-out marker for skills with no sub-agent dispatch
- Not flag existing 33 working cards

**Success Criteria:**
- SC-DG-6: `validate_skill_cards.py` REQ check catches missing DISPATCH_GATE subsections
- SC-DG-7: Existing 33 working cards not broken by validation change

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)