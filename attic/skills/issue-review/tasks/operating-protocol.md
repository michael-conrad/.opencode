# Issue Review Operating Protocol

## Entry Criteria

- Issue review requested (gather, triage, audit, qa, or analyze-and-spec)
- Issue number is known

## Procedure

- [ ] 1. **Gather first:** read body, ALL comments, labels, sub-issues, auth status before classification.
- [ ] 2. **Triage path:** bug report → analyze-and-spec. Spec → audit. Non-bug, non-spec → qa.
- [ ] 3. **Bug discovery ≠ authorization:** findings reported as bug issues; no code edits during analysis.
- [ ] 4. **Fix spec must target root cause, not symptom** per `000-critical-rules.md`.
- [ ] 5. **Audit findings are internal** — posted to chat, not GitHub comments.
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Context gathered
- Review path classified
- Delegated to correct downstream skill
