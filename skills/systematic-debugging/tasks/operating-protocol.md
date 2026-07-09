# Systematic Debugging Operating Protocol

## Entry Criteria

- Bug, error, or unexpected behavior encountered
- Bug description and affected file paths known

## Procedure

- [ ] 1. **Read-only during diagnosis:** no code changes until root cause identified.
- [ ] 2. **Bug discovery ≠ authorization:** new bugs reported as issues, not fixed inline.
- [ ] 3. **Hypothesis must be verified** against live evidence before proceeding.
- [ ] 4. **Fix targets root cause, not symptoms.**
- [ ] 5. **Fix requires authorization** per `approval-gate`.
- [ ] 6. **No scope creep:** fix only what diagnosis identified.
- [ ] 7. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Root cause identified
- Minimal fix applied (with authorization)
- Fix verified
