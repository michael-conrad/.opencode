# Correspondence Operating Protocol

## Entry Criteria

- Drafting request received (email, stakeholder update, or external communication)
- Audience tier identified or defaulted to stakeholder

## Procedure

- [ ] 1. **Verification gate before drafting** (`verification-enforcement --task verify`).
- [ ] 2. **Multipart/alternative mandatory** for email output.
- [ ] 3. **Audience separation:** stakeholder tier MUST NOT include internal artifacts (runbook paths, step numbers, internal IPs, file paths, CLI commands).
- [ ] 4. **Audience classification before drafting.** Default to stakeholder tier when unclear.
- [ ] 5. **Revisit after self-review** (`verification-enforcement --task revisit`).
- [ ] 6. **AI byline mandatory** in all correspondence.
- [ ] 7. **Content-type propagation:** match source email format (inspect Content-Type header).
- [ ] 8. **Attribution verification:** no role-proximity inference — only evidence-backed attribution.
- [ ] 9. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Verification gate completed
- Multipart/alternative format enforced (for email)
- Audience separation verified
- AI byline included
