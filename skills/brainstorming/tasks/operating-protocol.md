# Brainstorming Operating Protocol

## Entry Criteria

- User has requested exploration, brainstorming, or requirements discussion
- No active spec exists for the topic

## Procedure

- [ ] 1. **One question at a time.** Never present multiple questions.
- [ ] 2. **Dimensions are internal.** Six-dimensional checklist runs in agent's mind, not in output.
- [ ] 3. **Pre-spec inspection mandatory** (code inspection checklist) before proposing approach.
- [ ] 4. **Autonomous structural classification:** classify single vs multi-task without asking.
- [ ] 5. **Terminal state** invokes `spec-creation`.
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Requirements sufficiently explored
- Classification determined (single vs multi-task)
- Ready to invoke spec-creation or next step
