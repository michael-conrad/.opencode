# Phase 1: Strip dispatch markers from 19 task cards

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-7

## Steps

### Step 1.1: `closure-verification.md` — Remove DiMo chain flow section

Replace the DiMo Chain Flow section and Purpose line with self-contained inline steps. Add entry/exit criteria.

### Step 1.2: `closure-verification/investigator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Investigator` section. The file already has entry/exit criteria and inline procedure.

### Step 1.3: `closure-verification/validator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Validator` section. The file already has inline procedure.

### Step 1.4: `closure-verification/evaluator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Evaluator` section. The file already has inline procedure.

### Step 1.5: `coherence-extraction.md` — Remove DiMo chain flow section

Replace the DiMo Chain Flow section and Purpose line with self-contained inline steps. Add entry/exit criteria.

### Step 1.6: `coherence-extraction/investigator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Investigator` section.

### Step 1.7: `coherence-extraction/validator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Validator` section.

### Step 1.8: `coherence-extraction/evaluator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Evaluator` section.

### Step 1.9: `spec-summary.md` — Remove DiMo chain flow section

Replace the DiMo Chain Flow section and Purpose line with self-contained inline steps. Add entry/exit criteria.

### Step 1.10: `spec-summary/investigator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Investigator` section.

### Step 1.11: `spec-summary/validator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Validator` section.

### Step 1.12: `spec-summary/evaluator.md` — Remove DiMo Role section

Remove the `## DiMo Role: Evaluator` section.

### Step 1.13: `resolve-models.md` — Remove DiMo Arbiter role reference

Remove the `> **DiMo Role: Arbiter (reference).**` blockquote. The file already has inline procedure.

### Step 1.14: `cross-validate.md` — Remove DiMo Arbiter role references

Remove the `> **DiMo Role: Sole Arbiter (Arbiter).**` blockquote and the "This file is the sole Arbiter" header. The file already has entry/exit criteria and inline procedure.

### Step 1.15: `spec-audit-evaluator.md` — Remove DiMo Role section

Remove the `> **DiMo Role: Evaluator.**` blockquote. The file already has entry/exit criteria and inline procedure.

### Step 1.16: `spec-audit-investigator.md` — Remove DiMo Role section

Remove the `> **DiMo Role: Investigator.**` blockquote. The file already has entry/exit criteria and inline procedure.

### Step 1.17: `spec-audit-validator.md` — Remove DiMo Role section

Remove the `> **DiMo Role: Validator.**` blockquote. The file already has entry/exit criteria and inline procedure.

### Step 1.18: `content-audit-evaluator.md` — Remove DiMo Role section

Remove the `> **DiMo Role: Evaluator.**` blockquote. The file already has entry/exit criteria and inline procedure.

### Step 1.19: `behavioral-sc-evaluator.md` — Remove DiMo Role reference (if file exists)

If the file exists, remove the DiMo Role reference. If not, skip.

### Step 1.20: Verify with grep — all dispatch markers removed

Run grep for all prohibited patterns across `tasks/*.md`:
- `DiMo.*Role` or `DiMo.*chain`
- `(**orchestrator**)`, `(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`
- `Never task()`, `orchestrator dispatches`

All must return 0 matches.

## Entry Criteria

- All 19 files exist and have been read
- Dispatch marker patterns identified per file

## Exit Criteria

- All 19 files have dispatch markers removed
- Each remediated file has entry criteria and exit criteria sections
- grep verification passes for all prohibited patterns
- SC-1, SC-2, SC-3, SC-4, SC-5 verified
