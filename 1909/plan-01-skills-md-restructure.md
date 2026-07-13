# Phase 01 — SKILL.md Restructure

**Concern:** Rewrite audit skill description and dispatch tables to route through DiMo 4-role chain

**Files:**
- `.opencode/skills/audit/SKILL.md` — rewrite description, Trigger Dispatch Table, Invocation section, DiMo section
- `.opencode/skills/audit/tasks/completion.md` — remove Path Provider role claim
- `.opencode/skills/audit/tasks/cross-validate.md` — clarify as sole Path Provider

**SCs:** SC-1, SC-2, SC-7

**Dependencies:** None

**Entry conditions:** Feature branch created, spec approved

**Exit conditions:** SKILL.md rewritten, completion.md and cross-validate.md role claims resolved

## Code Path Coverage

- `audit/SKILL.md` — primary dispatch entry point
- `audit/tasks/completion.md` — role claim removal
- `audit/tasks/cross-validate.md` — role claim clarification

## Cross-Cutting SCs

- DiMo 4-role chain dispatch (affects all phases)
- Agent-intent description language (Phase 1 only)
- Path Provider role ambiguity (Phases 1 and 3)

## Interface Boundaries

- `audit/SKILL.md` Trigger Dispatch Table — breaking change, all consumers affected
- `audit/tasks/completion.md` — backward compatible (only role claim removed)
- `audit/tasks/cross-validate.md` — backward compatible (role claim clarified)

## State Transitions

- SKILL.md: monolithic dispatch → DiMo 4-role chain dispatch
- Description: user-utterance matching → agent-intent language
- DiMo section: documentation only → authoritative dispatch instruction

## Steps

- [ ] 1. **Read current SKILL.md (**inline**).** Read `.opencode/skills/audit/SKILL.md` to understand current structure. **→ SC-1, SC-2, SC-7**

- [ ] 2. **Rewrite description (**sub-agent**).** `task(..., prompt: "Rewrite the audit skill description in .opencode/skills/audit/SKILL.md to use agent-intent language per #1899. Replace the 'User phrases:' pattern with 'Dispatch when the agent needs...' language. The description must describe what the agent intends to do, not what the user says.")` **→ SC-1**

- [ ] 3. **Verify description (**inline**).** `grep -c 'User phrases:' .opencode/skills/audit/SKILL.md` — must return 0. **→ SC-1**

- [ ] 4. **Restructure Trigger Dispatch Table (**sub-agent**).** `task(..., prompt: "Restructure the Trigger Dispatch Table in .opencode/skills/audit/SKILL.md to route to the DiMo 4-role workflow instead of individual monolithic task files. Each row must dispatch to the DiMo chain, not to a single task file. Remove rows that dispatch to old monolithic task names (spec-audit, verification-audit, plan-fidelity, concern-separation, coherence-maintenance, guideline-audit, drift-detection, content-audit, test-quality-audit).")` **→ SC-2**

- [ ] 5. **Verify Trigger Dispatch Table (**inline**).** `grep -E '(spec-audit|verification-audit|plan-fidelity|concern-separation|coherence-maintenance|guideline-audit|drift-detection|content-audit|test-quality-audit)' .opencode/skills/audit/SKILL.md` — must return 0 matches in the Trigger Dispatch Table section. **→ SC-2**

- [ ] 6. **Make DiMo section authoritative (**sub-agent**).** `task(..., prompt: "Make the DiMo Role Chain Dispatch section in .opencode/skills/audit/SKILL.md the authoritative dispatch instruction. Remove the old Invocation table that dispatches to monolithic task files. The DiMo section must be the only dispatch instruction in the file.")` **→ SC-7**

- [ ] 7. **Verify DiMo section (**inline**).** `grep -c 'DiMo Role Chain Dispatch' .opencode/skills/audit/SKILL.md` — must return >= 1. `grep -c 'execute spec-audit task from audit' .opencode/skills/audit/SKILL.md` — must return 0. **→ SC-7**

- [ ] 8. **Remove Path Provider claim from completion.md (**sub-agent**).** `task(..., prompt: "Read .opencode/skills/audit/tasks/completion.md. Remove any claim of the Path Provider (Judger) role from the file. The file's procedure content must remain unchanged — only remove the role claim.")` **→ SC-9**

- [ ] 9. **Verify completion.md (**inline**).** `grep -c 'Path Provider' .opencode/skills/audit/tasks/completion.md` — must return 0. **→ SC-9**

- [ ] 10. **Clarify cross-validate.md as sole Path Provider (**sub-agent**).** `task(..., prompt: "Read .opencode/skills/audit/tasks/cross-validate.md. Ensure it is clearly identified as the sole Path Provider (Judger) role. Remove any ambiguity about which file owns this role. The file's procedure content must remain unchanged.")` **→ SC-9**

- [ ] 11. **Verify cross-validate.md (**inline**).** `grep -c 'Path Provider' .opencode/skills/audit/tasks/cross-validate.md` — must return >= 1. **→ SC-9**

- [ ] 12. **Checkpoint commit (**inline**).** `git add .opencode/skills/audit/SKILL.md .opencode/skills/audit/tasks/completion.md .opencode/skills/audit/tasks/cross-validate.md && git commit -m "Phase 1: Restructure audit SKILL.md for DiMo 4-role chain dispatch"` **→ SC-1, SC-2, SC-7, SC-9**

#### Phase 1 VbC

- [ ] 12. **VbC (**clean-room**).** Verify SC-1 (description uses agent-intent language), SC-2 (Trigger Dispatch Table routes to DiMo), SC-7 (DiMo section authoritative), SC-9 (Path Provider role resolved). **→ SC-1, SC-2, SC-7, SC-9**

**Concern transition:** Leaving SKILL.md dispatch restructure → entering role-specific task file creation. Phase 2 depends on Phase 1 SKILL.md rewrite.
