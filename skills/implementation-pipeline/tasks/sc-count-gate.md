# Task: sc-count-gate

## Purpose

Read the spec's `sc-summary.yaml` to get the total SC count, count verified SCs from VbC evidence, and BLOCK if any SC has no verdict. This prevents agents from claiming completion with skipped SCs.

## Entry Criteria

- Spec has been implemented (GREEN phase complete)
- `sc-summary.yaml` exists at `{project_root}/{path}/.issues/{issue-N}/sc-summary.yaml`
- VbC evidence artifacts exist

## Procedure

- [ ] 1. **Read `sc-summary.yaml`** — parse the total SC count from the `sc_count` field or by counting entries in the `scs` list
- [ ] 2. **Read VbC evidence** — count the number of SCs with PASS/FAIL verdicts in the VbC evidence artifacts
- [ ] 3. **Compare counts:**
   - If `verified_count >= total_count`: PASS — all SCs have verdicts
   - If `verified_count < total_count`: BLOCKED — report which SCs have no verdict, HALT
- [ ] 4. **Report result:**
   ```yaml
   status: PASS | BLOCKED
   total_sc_count: <N>
   verified_sc_count: <N>
   missing_sc_verdicts:
     - <SC-ID-1>
     - <SC-ID-2>
   ```

## Exit Criteria

- All SCs have verdicts (PASS or FAIL) — no SC is skipped
- If any SC has no verdict, the gate BLOCKs and reports the missing SCs

## Cross-References

- `spec-creation/tasks/create.md` — produces `sc-summary.yaml`
- `verification-before-completion/tasks/verify.md` — produces SC verdicts
- Load [critical-rules-sc-lobotomy](guidelines/000-critical-rules.md) — SC skip prohibition
