# Phase 1: Update change-control task

**Phase:** 1 of 1
**Concern:** Add mandatory re-audit step and update exit criteria
**SCs:** SC-1, SC-2, SC-3, SC-4

## Steps

### Step 1: RED — Write enforcement test for SC-1 (exit criteria)

Write a content-verification test that verifies `change-control.md` exit criteria includes "All prior audit FAILs resolved to PASS" when revision was audit-triggered. Test must FAIL before the change is made.

**Dispatch:** `test-driven-development --task red`
**SC:** SC-1
**Evidence type:** string

### Step 2: GREEN — Add exit criterion (SC-1)

Add "All prior audit FAILs resolved to PASS" to the exit criteria section of `change-control.md`, conditional on audit-triggered revision.

**Dispatch:** `test-driven-development --task green`
**SC:** SC-1
**Evidence type:** string

### Step 3: RED/GREEN — Insert mandatory re-audit step (SC-2, SC-3)

Insert a mandatory re-audit step between Step 3 (Impact Analysis) and Step 4 (HALT) that:
- Dispatches `audit --task spec-audit` when revision was audit-triggered
- Confirms all prior FAILs are now PASS
- Is conditional — only required when revision was triggered by spec-audit FAILs

**Dispatch:** `test-driven-development --task red` then `test-driven-development --task green`
**SCs:** SC-2, SC-3
**Evidence type:** string

### Step 4: RED/GREEN — Behavioral anti-lobotomization test (SC-4)

Write and run a behavioral enforcement test that verifies no SC lobotomization occurred during implementation. Test must PASS.

**Dispatch:** `test-driven-development --task red` then `test-driven-development --task green`
**SC:** SC-4
**Evidence type:** behavioral

## Phase Completion

- [ ] All 4 SCs verified PASS
- [ ] change-control.md updated
- [ ] Behavioral anti-lobotomization test passes
- [ ] All changes committed

## Concern Transition

This is the final phase. After completion, proceed to `verification-before-completion` then `finishing-a-development-branch`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
