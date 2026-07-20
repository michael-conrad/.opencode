## Plan for #1401

### Phase 1: Modify verification-audit.md pre-flight gate

**Objective:** Make Step 0 Check 2 and Step 2 SC-type-aware — only require `artifact_evidence_dir` when the spec has behavioral SCs.

**Changes to `skills/adversarial-audit/tasks/verification-audit.md`:**

1. **Step 0 Check 2** — Replace unconditional ≥2 YAML requirement with conditional check:
   - Load spec SCs first (before Check 2)
   - If any behavioral SCs exist: require `artifact_evidence_dir` with ≥2 YAML files
   - If zero behavioral SCs: skip the artifact check, proceed with codebase inspection

2. **Step 2 (Load Behavioral Evidence)** — Make conditional:
   - If spec has behavioral SCs: current behavior (require evidence)
   - If zero behavioral SCs: skip Step 2 entirely

3. **Entry Criteria** — Update `artifact_evidence_dir` from REQUIRED to conditional

4. **Error Handling** — Update to reflect conditional requirement

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Step 0 Check 2 loads spec SCs before deciding artifact requirement | `string` |
| SC-2 | When spec has zero behavioral SCs, pre-flight gate does not block on missing artifacts | `behavioral` |
| SC-3 | When spec has behavioral SCs, pre-flight gate still requires ≥2 YAML files | `behavioral` |
| SC-4 | Step 2 is skipped when spec has zero behavioral SCs | `string` |
| SC-5 | Entry Criteria documents `artifact_evidence_dir` as conditional | `string` |

### Dependencies

- None — single-file change

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
