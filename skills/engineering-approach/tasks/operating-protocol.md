# Engineering Approach Operating Protocol

## Entry Criteria

- Implementation or design work is about to begin
- Spec exists and is approved

## Procedure

- [ ] 1. **Understand before solving:** read all relevant code before proposing changes.
- [ ] 2. **Design before implementing:** document approach, consider alternatives, obtain approval.
- [ ] 3. **Verify before complete:** run tests manually, check edge cases, validate success criteria.
- [ ] 4. **No scope creep:** implement ONLY what's in the approved spec.
- [ ] 5. **Pre-implementation verification:** verify API signatures, env vars, config formats against live docs.
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Understanding verified
- Design documented
- Verification complete
- Scope boundaries respected
