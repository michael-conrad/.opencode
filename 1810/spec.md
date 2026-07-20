## Phase 7 — Behavioral enforcement tests

**Parent:** #1784

Create behavioral tests that verify:
1. SC-ROUTING-1: After `skill("approval-gate")`, orchestrator has no procedure text
2. SC-ROUTING-2: After `skill("approval-gate")`, orchestrator has dispatch table + canonical strings
3. SC-ROUTING-3: Orchestrator dispatches sub-agents via `task()` rather than inline work
4. SC-DG-6: `validate_skill_cards.py` REQ check catches missing DISPATCH_GATE subsections
5. SC-DG-7: Existing 33 working cards not broken by validation change

**Success Criteria:**
- SC-ROUTING-1 through SC-ROUTING-3: behavioral PASS
- SC-DG-6, SC-DG-7: behavioral PASS

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)