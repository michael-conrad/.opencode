# Phase 2: Update audit SKILL.md Trigger Dispatch Table

**SCs:** SC-6, SC-7

## Steps

### Step 2.1: Verify audit SKILL.md TDT already documents DiMo chain

The audit SKILL.md TDT (lines 44-73) already documents the DiMo 4-role chain dispatch pattern. Each row dispatches to the DiMo chain with `role_chain: [investigator, validator, evaluator, arbiter]`. The TDT header states: "Each row dispatches to the DiMo 4-role chain (Investigator → Validator → Evaluator → Arbiter)."

**No changes needed** — the TDT already satisfies SC-6.

### Step 2.2: Verify SC-7 with grep

Run grep to confirm no dispatch markers remain in any task card.

## Entry Criteria

- Phase 1 complete (all 19 files remediated)

## Exit Criteria

- SC-6 verified: audit SKILL.md TDT documents DiMo chain
- SC-7 verified: behavioral test confirms sub-agent executes inline
