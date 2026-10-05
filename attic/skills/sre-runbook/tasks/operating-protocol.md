# SRE Runbook Operating Protocol

## Entry Criteria

- Runbook generation requested (one-off-config, periodic-procedure, troubleshooting, incident-response)
- Environment context and domain context available

## Procedure

- [ ] 1. **Environment context mandatory:** interface preference, tools, OS version before any instruction.
- [ ] 2. **Domain context mandatory:** infrastructure type, service name. Prompt if missing.
- [ ] 3. **Runbook type taxonomy:** `one-off-config` (steps-only, no YAML), `periodic-procedure` (steps-only, cadence stamp), `troubleshooting` (dual-output with YAML blocks), `incident-response` (dual-output with YAML blocks).
- [ ] 4. **Single-path rule:** one method per operation. No alternatives.
- [ ] 5. **Real-values rule:** actual hostnames/IPs/domains. No placeholders.
- [ ] 6. **Live-verification:** every CLI/GUI/API claim verified against live docs before inclusion. All sources fail → HALT with VERIFICATION-GAP.
- [ ] 7. **Exact-match verification:** row-by-row comparison template. No "functionally equivalent" soft-passes.
- [ ] 8. **DNS-specific validation:** RFC 1034 compliance (CNAME at apex invalid), provider-specific reference data.
- [ ] 9. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Runbook generated with correct type template
- All CLI/API claims live-verified
- Real values used (no placeholders)
