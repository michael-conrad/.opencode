# Verification Enforcement Operating Protocol

## Entry Criteria

- Content generation that makes factual claims is about to begin
- Section evidence table or claim list available

## Procedure

- [ ] 1. **Pre-generation:** collect section evidence table, task per-section verification sub-agents.
- [ ] 2. **Post-generation:** scan for ⚠️ UNVERIFIED markers, attempt resolution, escalate remaining.
- [ ] 3. **Orchestrator enforcement:** reject sub-agent output lacking evidence artifacts; re-task.
- [ ] 4. **Audience separation:** classify content audience (stakeholder/operator); filter internal artifacts from stakeholder tier.
- [ ] 5. **All factual claims require live-source verification.**
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Pre-generation evidence collected
- Post-generation scan completed
- Unverified markers resolved or escalated
