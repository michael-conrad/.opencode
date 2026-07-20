## Phase 4 of #1672 — Update SKILL.md and Dispatch Logic

**Depends on:** Phase 1, 2, 3
**SCs:** SC-5

### Steps
1. Update `adversarial-audit/SKILL.md` to reference DiMo architecture
2. Remove `resolve-models` from dispatch routing
3. Update dispatch contract documentation (remove `audit_phase`, reduce to 2 fields)
4. Verify no `audit_phase` references in dispatch contracts (SC-5)

### Verification
- SC-5: No `audit_phase` references in dispatch contracts

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)