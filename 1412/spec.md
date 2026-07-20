## Plan for #1385

### Phase 1: Add SC-SEM criteria to spec-audit.md

**Items:**
1. Add 6 SC-SEM criteria to the evaluation criteria table in `skills/adversarial-audit/tasks/spec-audit.md`
2. Add Step 3a: Evaluate Semantic Auditor Criteria for Skill Card Audits
3. Update checklist and completion dependency chain

**Evidence:** `string` — grep for criteria IDs in spec-audit.md

### Phase 2: Update cross-validate.md for severity-based consensus

**Items:**
1. Add `severity` field to findings YAML format in `skills/adversarial-audit/tasks/cross-validate.md`
2. Add severity-based consensus logic: ERROR FAIL blocks pipeline, WARNING FAIL flags but does not block

**Evidence:** `string` — grep for `severity` in cross-validate.md

### Phase 3: Behavioral enforcement tests

**Items:**
1. Create `tests/behaviors/1385-sc1-sem-001-ambiguous-description.sh`
2. Create `tests/behaviors/1385-sc2-sem-002-mandatory-signal.sh`
3. Create `tests/behaviors/1385-sc3-sem-003-table-alignment.sh`
4. Create `tests/behaviors/1385-sc4-sem-004-coverage.sh`
5. Create `tests/behaviors/1385-sc5-sem-005-optional-language.sh`
6. Create `tests/behaviors/1385-sc6-sem-006-subitem-type.sh`
7. Create `tests/behaviors/1385-sc8-all-findings.sh`
8. Create `tests/behaviors/1385-sc9-clean-room.sh`

**Evidence:** `structural` — file existence

### Phase 4: Stack #1411 (flock timeout) onto same branch

**Items:**
1. Add 30s timeout to `flock -x` in `tests/behaviors/helpers.sh`
2. Remove dead `BEHAVIOR_CONCURRENT` docs from `tests/AGENTS.md`

**Evidence:** `string` — grep for `-w 30` in helpers.sh

### Dependencies

- Phase 1 → Phase 2 (cross-validate changes depend on SC-SEM criteria existing)
- Phase 1,2,3 → Phase 4 (independent — can be done in any order)

### PR Strategy

Stacked: single branch `feature/1385-semantic-auditor-criteria`, single PR.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)