# Implementation Plan — [.opencode#1974](https://github.com/michael-conrad/.opencode/issues/1974) — Add secret redaction plugin (opencode-vibeguard)

**Spec:** #1974

- **Goal:** Install `opencode-vibeguard@0.1.0` npm plugin, configure `vibeguard.config.json`, remove home-grown `redactSecrets()` from `session-enforcement.ts`, and achieve three-layer secret protection (pre-request redaction, pre-tool restoration, historical redaction) with behavioral enforcement tests.
- **Architecture:** Single-phase plan. All 13 SCs map to Phase 1. Solve order: ITEM-2 (code removal) → ITEM-1 (config + install) → ITEM-3 (plugin verification) → ITEM-4 (behavioral tests) → ITEM-5 (anti-lobotomization). Each item follows RED → GREEN → doublecheck → commit cycle.
- **Files:**
  - `.opencode/plugins/session-enforcement.ts` — remove `redactSecrets()`, preserve mode-switch stripping
  - `.opencode/opencode.jsonc` — add `opencode-vibeguard@0.1.0` to plugins array
  - `.opencode/vibeguard.config.json` — create with regex patterns, keywords, builtin PII detectors
  - `.opencode/tests-v2/behaviors/secret-redaction/` — behavioral enforcement test files
- **Dispatch:** `implementation-pipeline` skill via `task()` for each RED/GREEN sub-agent dispatch.

## Blast Radius

| File | Impact | Change Type |
|------|--------|-------------|
| `.opencode/plugins/session-enforcement.ts` | Remove `redactSecrets()` function, preserve mode-switch stripping | Modification |
| `.opencode/opencode.jsonc` | Add plugin entry to plugins array | Modification |
| `.opencode/vibeguard.config.json` | New config file with regex, keywords, builtin PII | Creation |
| `.opencode/tests-v2/behaviors/secret-redaction/` | New behavioral test files (SC-1 through SC-13) | Creation |

## Concern Map Reference

| Concern | Phase | Items |
|---------|-------|-------|
| Code removal | Phase 1 | ITEM-2 (SC-1, SC-3) |
| Config + install | Phase 1 | ITEM-1 (SC-2, SC-4, SC-9, SC-10, SC-11) |
| Plugin verification | Phase 1 | ITEM-3 (SC-5, SC-6, SC-7, SC-8) |
| Behavioral tests | Phase 1 | ITEM-4 (SC-12) |
| Anti-lobotomization | Phase 1 | ITEM-5 (SC-13) |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute steps sequentially. Do NOT skip ahead, batch steps, or parallelize. Each step must complete and be verified before the next step begins. If a step fails, stop and remediate before proceeding.

### Step Status

Each step MUST report its status after execution: `DONE`, `BLOCKED`, or `FAIL`. Status is reported in the work state file at `{project_root}/tmp/1974/work.yaml`. A `BLOCKED` or `FAIL` status halts the pipeline until remediated.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Secret redaction plugin | All concerns | SC-1 through SC-13 | None | 1–79 | implementation-pipeline |

## SC-to-Step Traceability Table

| SC ID | Criterion | Evidence Type | Item | Steps |
|-------|-----------|---------------|------|-------|
| SC-1 | `redactSecrets()` removed from `session-enforcement.ts` | behavioral | ITEM-2 | 4–8 |
| SC-2 | `opencode-vibeguard@0.1.0` installed via `opencode.jsonc` plugins array | behavioral | ITEM-1 | 9–11 |
| SC-3 | Mode-switch stripping preserved in `session-enforcement.ts` | behavioral | ITEM-2 | 4–8 |
| SC-4 | `vibeguard.config.json` created in `.opencode/` with regex patterns | behavioral | ITEM-1 | 12–14 |
| SC-5 | Pre-request redaction: secrets redacted before LLM requests | behavioral | ITEM-3 | 25–27 |
| SC-6 | Pre-tool restoration: placeholders restored before tool execution | behavioral | ITEM-3 | 28–30 |
| SC-7 | Historical redaction: tool outputs redacted in conversation history | behavioral | ITEM-3 | 31–33 |
| SC-8 | Streaming edge case handled: placeholder sanitized at text-end | behavioral | ITEM-3 | 34–36 |
| SC-9 | Config supports regex patterns for API keys (OpenAI, GitHub, AWS) | behavioral | ITEM-1 | 15–17 |
| SC-10 | Config supports builtin PII detectors (email, phone, ID, UUID, IP, MAC) | behavioral | ITEM-1 | 18–20 |
| SC-11 | Config supports keyword patterns for custom secrets | behavioral | ITEM-1 | 21–23 |
| SC-12 | Behavioral enforcement tests written and pass (RED→GREEN cycle) | behavioral | ITEM-4 | 38–41 |
| SC-13 | No SC weakened, deferred, or reclassified to lower evidence type | behavioral | ITEM-5 | 42–45 |

## Safety/Rollback Considerations

| Scenario | Mitigation | Rollback Action |
|----------|------------|-----------------|
| Plugin causes issues at startup | Plugin pinned to exact version 0.1.0; becomes no-op if config missing or `enabled=false` | Remove plugin from `opencode.jsonc`, restore `redactSecrets()` from git, delete `vibeguard.config.json` |
| Streaming placeholder visible | vibeguard handles via text-end sanitization per docs; brief flash acceptable | N/A (cosmetic, no data exposure) |
| Behavioral test timeout | Increase `BEHAVIOR_TIMEOUT`; inspect stdout/stderr logs; diagnose root cause | Re-run after remediation; never lobotomize test |
| Checkpoint rollback | `git reset --hard <parent>/checkpoint/1974/phase-1-<submodule>` on verification failure | Pre-rollback diagnostics (`git status`, `git diff --stat`) reported to chat before reset |

## Feasibility Verification

| Artifact | Status | Evidence |
|----------|--------|----------|
| `.opencode/plugins/session-enforcement.ts` | ✅ Exists | Verified via `ls` |
| `.opencode/opencode.jsonc` | ✅ Exists | Verified via `ls` |
| `opencode-vibeguard@0.1.0` npm package | ✅ Exists | Verified via GitHub repo |
| Bun runtime | ✅ Available | Verified via environment |
| Behavioral test directory | ✅ Will be created | `.opencode/tests-v2/behaviors/secret-redaction/` |

## Evidence/Provenance

| Claim | Source | Verification Method |
|-------|--------|---------------------|
| `redactSecrets()` had 4 patterns, now removed | Git history | `git log -p -- .opencode/plugins/session-enforcement.ts` |
| Plugin provides three-layer protection | Plugin README | GitHub repo documentation |
| Config supports regex, keywords, builtin PII | `vibeguard.config.json.example` | Direct source search |
| Plugin becomes no-op if config missing | Plugin README | Documentation URLs |
| Streaming placeholder sanitized at text-end | Plugin README | Documentation URLs |

---

# Phase 1 — Secret Redaction Plugin

**Concern:** All concerns — code removal, plugin verification, config + install, behavioral tests, anti-lobotomization.

**Files:**
- `.opencode/plugins/session-enforcement.ts`
- `.opencode/opencode.jsonc`
- `.opencode/vibeguard.config.json`
- `.opencode/tests-v2/behaviors/secret-redaction/`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13

**Dependencies:** None

**Entry conditions:**
- Spec approved (`.opencode/.issues/1974/spec.md` exists and is complete)
- Solve step completed with SAT + SOLVED status
- Feature branch created from trunk

**Exit conditions:**
- All 13 SCs verified PASS with behavioral evidence
- Behavioral enforcement tests pass with 100% clean PASS
- No SC weakened, deferred, or reclassified

### Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `session-enforcement.ts` redactSecrets() removal | ITEM-2 |
| `session-enforcement.ts` mode-switch preservation | ITEM-2 |
| `opencode.jsonc` plugin array modification | ITEM-1 |
| `vibeguard.config.json` creation and pattern configuration | ITEM-1 |
| Plugin pre-request redaction path | ITEM-3 |
| Plugin pre-tool restoration path | ITEM-3 |
| Plugin historical redaction path | ITEM-3 |
| Plugin streaming text-end sanitization | ITEM-3 |
| Behavioral test execution path | ITEM-4 |
| Evidence type verification path | ITEM-5 |

### Cross-Cutting SCs

| SC ID | Applies To | Rationale |
|-------|-----------|-----------|
| SC-12 | All items | Every item's GREEN phase must have a corresponding behavioral test |
| SC-13 | All items | No SC may be weakened during any item's implementation |

### Interface Boundaries

| Interface | Boundary | Phase Handling |
|-----------|----------|---------------|
| `session-enforcement.ts` exports | Plugin hooks API | Mode-switch stripping preserved; `redactSecrets()` removed |
| `opencode.jsonc` plugins array | Plugin registration | Single entry added |
| `vibeguard.config.json` | Plugin configuration | Self-contained in `.opencode/` |

### State Transitions

| Transition | Triggered By | Phase Handling |
|------------|-------------|---------------|
| No plugin → Plugin installed | `opencode.jsonc` modification | ITEM-1 |
| Home-grown redaction → Plugin redaction | `redactSecrets()` removal | ITEM-2 |
| Unverified → Verified | Behavioral test execution | ITEM-4 |

---

### Step-by-step

#### Pre-steps (Global)

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec SCs are internally consistent, all 13 SCs have unique IDs, evidence types match verification methods, and no SC conflicts with already-merged specs. **→ SC-13**
- [ ] 2. **Pre-red baseline (**clean-room**).** Capture current state of all affected files: `git show HEAD:.opencode/plugins/session-enforcement.ts` for `redactSecrets()` presence, `cat .opencode/opencode.jsonc` for current plugins array, verify `vibeguard.config.json` does not exist. **→ SC-1, SC-2, SC-4**
- [ ] 3. **Feature branch creation (**inline**).** Create feature branch `feature/1974-secret-redaction` from trunk. Verify branch created successfully.

#### ITEM-2: Code removal (SC-1, SC-3)

- [ ] 4. **Verify SC-1: Confirm redactSecrets() already removed (**inline**).** Run `grep -c redactSecrets .opencode/plugins/session-enforcement.ts` → 0. Already satisfied by merged PR #1976. No RED phase needed — verification only. **→ SC-1**
- [ ] 5. **RED: Write behavioral test for SC-3 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-3.sh` that verifies `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts` returns ≥1. Test MUST FAIL (RED) because mode-switch may not be preserved. **→ SC-3**
- [ ] 6. **GREEN: Preserve mode-switch stripping (**sub-agent**).** Verify `isModeSwitchSynthetic` and all mode-switch stripping logic are preserved in `session-enforcement.ts`. Verify with `grep -c "isModeSwitchSynthetic"` → ≥1. **→ SC-3**
- [ ] 7. **GREEN doublecheck (**inline**).** Re-run SC-3 behavioral test. MUST PASS. If fails, remediate and re-run. **→ SC-3**
- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/plugins/session-enforcement.ts .opencode/tests-v2/behaviors/secret-redaction/SC-3.sh && git commit -m "1974 ITEM-2: Verify redactSecrets() removed, preserve mode-switch stripping"`. Create checkpoint tag `opencode/checkpoint/1974/phase-1-opencode`.

#### ITEM-1: Config + install (SC-2, SC-4, SC-9, SC-10, SC-11)

- [ ] 9. **RED: Write behavioral test for SC-2 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh` that verifies `cat .opencode/opencode.jsonc | jq -r '.plugin[]' | grep opencode-vibeguard@0.1.0`. Test MUST FAIL (RED) because plugin not yet in config. **→ SC-2**
- [ ] 10. **GREEN: Install plugin in `opencode.jsonc` (**sub-agent**).** Edit `.opencode/opencode.jsonc`: add `"opencode-vibeguard@0.1.0"` to the `plugin` array. Verify with `cat .opencode/opencode.jsonc | jq -r '.plugin[]' | grep opencode-vibeguard@0.1.0`. **→ SC-2**
- [ ] 11. **GREEN doublecheck (**inline**).** Re-run SC-2 behavioral test. MUST PASS. **→ SC-2**
- [ ] 12. **RED: Write behavioral test for SC-4 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-4.sh` that verifies `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` ≥ 3. Test MUST FAIL (RED) because config does not exist. **→ SC-4**
- [ ] 13. **GREEN: Create `vibeguard.config.json` (**sub-agent**).** Create `.opencode/vibeguard.config.json` with `patterns.regex` array containing ≥3 regex patterns. Verify with `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` ≥ 3. **→ SC-4**
- [ ] 14. **GREEN doublecheck (**inline**).** Re-run SC-4 behavioral test. MUST PASS. **→ SC-4**
- [ ] 15. **RED: Write behavioral test for SC-9 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-9.sh` that verifies `cat .opencode/vibeguard.config.json | jq '.patterns.regex[] | select(.pattern | test("sk-|ghp|AKIA"))' | wc -l` ≥ 3. Test MUST FAIL (RED). **→ SC-9**
- [ ] 16. **GREEN: Add regex patterns for API keys (**sub-agent**).** Update `.opencode/vibeguard.config.json` with regex patterns for OpenAI `sk-...`, GitHub `ghp_...`, AWS `AKIA...` formats. Verify with SC-9 test. **→ SC-9**
- [ ] 17. **GREEN doublecheck (**inline**).** Re-run SC-9 behavioral test. MUST PASS. **→ SC-9**
- [ ] 18. **RED: Write behavioral test for SC-10 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-10.sh` that verifies `cat .opencode/vibeguard.config.json | jq '.patterns.builtin[]' | wc -l` ≥ 6. Test MUST FAIL (RED). **→ SC-10**
- [ ] 19. **GREEN: Add builtin PII detectors (**sub-agent**).** Update `.opencode/vibeguard.config.json` with builtin PII detectors for email, phone, ID, UUID, IPv4, MAC address. Verify with SC-10 test. **→ SC-10**
- [ ] 20. **GREEN doublecheck (**inline**).** Re-run SC-10 behavioral test. MUST PASS. **→ SC-10**
- [ ] 21. **RED: Write behavioral test for SC-11 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-11.sh` that verifies `cat .opencode/vibeguard.config.json | jq '.patterns.keywords | length'` ≥ 1. Test MUST FAIL (RED). **→ SC-11**
- [ ] 22. **GREEN: Add keyword patterns (**sub-agent**).** Update `.opencode/vibeguard.config.json` with keyword patterns for custom secrets. Verify with SC-11 test. **→ SC-11**
- [ ] 23. **GREEN doublecheck (**inline**).** Re-run SC-11 behavioral test. MUST PASS. **→ SC-11**
- [ ] 24. **Checkpoint commit (**inline**).** `git add .opencode/opencode.jsonc .opencode/vibeguard.config.json .opencode/tests-v2/behaviors/secret-redaction/SC-2.sh .opencode/tests-v2/behaviors/secret-redaction/SC-4.sh .opencode/tests-v2/behaviors/secret-redaction/SC-9.sh .opencode/tests-v2/behaviors/secret-redaction/SC-10.sh .opencode/tests-v2/behaviors/secret-redaction/SC-11.sh && git commit -m "1974 ITEM-1: Plugin install, config creation, patterns"`. Update checkpoint tag.

#### ITEM-3: Plugin verification (SC-5, SC-6, SC-7, SC-8)

- [ ] 25. **RED: Write behavioral test for SC-5 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-5.sh` that runs `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test" 2>&1 | grep -c "replace count"` and expects >0. Test MUST FAIL (RED) because plugin not yet configured. **→ SC-5**
- [ ] 26. **GREEN: Verify pre-request redaction (**sub-agent**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test secret=mykey" 2>&1` and confirm "replace count" > 0 in output. **→ SC-5**
- [ ] 27. **GREEN doublecheck (**inline**).** Re-run SC-5 behavioral test. MUST PASS. **→ SC-5**
- [ ] 28. **RED: Write behavioral test for SC-6 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-6.sh` that runs `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "bash echo \$SECRET" 2>&1 | grep -c "restore"` and expects >0. Test MUST FAIL (RED). **→ SC-6**
- [ ] 29. **GREEN: Verify pre-tool restoration (**sub-agent**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "bash echo test" 2>&1` and confirm "restore" appears in output. **→ SC-6**
- [ ] 30. **GREEN doublecheck (**inline**).** Re-run SC-6 behavioral test. MUST PASS. **→ SC-6**
- [ ] 31. **RED: Write behavioral test for SC-7 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-7.sh` that runs `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test secret" 2>&1 | grep -c "historical"` and expects >0. Test MUST FAIL (RED). **→ SC-7**
- [ ] 32. **GREEN: Verify historical redaction (**sub-agent**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test secret" 2>&1` and confirm "historical" appears in output. **→ SC-7**
- [ ] 33. **GREEN doublecheck (**inline**).** Re-run SC-7 behavioral test. MUST PASS. **→ SC-7**
- [ ] 34. **RED: Write behavioral test for SC-8 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-8.sh` that runs `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "stream test" 2>&1 | grep -c "text-end"` and expects >0. Test MUST FAIL (RED). **→ SC-8**
- [ ] 35. **GREEN: Verify streaming edge case (**sub-agent**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "stream test" 2>&1` and confirm "text-end" appears in output. **→ SC-8**
- [ ] 36. **GREEN doublecheck (**inline**).** Re-run SC-8 behavioral test. MUST PASS. **→ SC-8**
- [ ] 37. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/secret-redaction/SC-5.sh .opencode/tests-v2/behaviors/secret-redaction/SC-6.sh .opencode/tests-v2/behaviors/secret-redaction/SC-7.sh .opencode/tests-v2/behaviors/secret-redaction/SC-8.sh && git commit -m "1974 ITEM-3: Plugin verification behavioral tests"`. Update checkpoint tag.

#### ITEM-4: Behavioral tests (SC-12)

- [ ] 38. **RED: Write behavioral test for SC-12 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-12.sh` that runs the full test suite `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` and expects PASS. Test MUST FAIL (RED) because not all tests pass yet. **→ SC-12**
- [ ] 39. **GREEN: Make all behavioral tests pass (**sub-agent**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh`. For each failing test, diagnose, remediate, and re-run until all pass. **→ SC-12**
- [ ] 40. **GREEN doublecheck (**inline**).** Re-run SC-12 behavioral test. MUST PASS with 100% clean PASS. **→ SC-12**
- [ ] 41. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/secret-redaction/SC-12.sh .opencode/tests-v2/behaviors/secret-redaction/run.sh && git commit -m "1974 ITEM-4: Behavioral enforcement tests"`. Update checkpoint tag.

#### ITEM-5: Anti-lobotomization (SC-13)

- [ ] 42. **RED: Write behavioral test for SC-13 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-13.sh` that verifies `grep -r "structural\|string" .issues/1974/sc-summary.yaml` returns 0 for behavioral SCs. Test MUST FAIL (RED) if any SC was weakened. **→ SC-13**
- [ ] 43. **GREEN: Verify no SC weakening (**sub-agent**).** Audit all 13 SCs in the spec. Confirm every SC with `evidence_type: behavioral` has a behavioral enforcement test. Confirm no SC was reclassified to `structural` or `string`. Fix any violations. **→ SC-13**
- [ ] 44. **GREEN doublecheck (**inline**).** Re-run SC-13 behavioral test. MUST PASS. **→ SC-13**
- [ ] 45. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/secret-redaction/SC-13.sh && git commit -m "1974 ITEM-5: Anti-lobotomization verification"`. Update checkpoint tag.

#### Post-steps (Global — Implementation Pipeline Gates)

- [ ] 46. **z3-check-red (**inline**).** Run `solve check` on RED phase output contract to validate state transition. **→ SC-13**
- [ ] 47. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` to verify RED phase results. **→ SC-13**
- [ ] 48. **z3-check-red-doublecheck (**inline**).** Run `solve check` on RED doublecheck output contract. **→ SC-13**
- [ ] 49. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. **→ SC-13**
- [ ] 50. **z3-check-post-red (**inline**).** Run `solve check` on post-RED enforcement output contract. **→ SC-13**
- [ ] 51. **z3-check-green (**inline**).** Run `solve check` on GREEN phase output contract. **→ SC-13**
- [ ] 52. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. **→ SC-13**
- [ ] 53. **z3-check-post-green (**inline**).** Run `solve check` on post-GREEN enforcement output contract. **→ SC-13**
- [ ] 54. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **→ SC-13**
- [ ] 55. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. **→ SC-13**
- [ ] 56. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` to verify GREEN phase results. **→ SC-13**
- [ ] 57. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion` for verification before completion. **→ SC-13**
- [ ] 58. **sc-count-gate (**sub-agent**).** Read `sc-summary.yaml` total SC count (13), count verified SCs from VbC evidence. BLOCK if `verified_count < 13`. **→ SC-13**
- [ ] 59. **Collect behavioral evidence (**sub-agent**).** Gather all behavioral evidence artifacts from `{project_root}/tmp/behavioral-evidence-*/` into `{project_root}/tmp/1974/artifacts/`. Verify each artifact exists and is non-empty. **→ SC-12**
- [ ] 60. **Audit (**clean-room**).** Dispatch `audit` skill to audit all 13 SCs against the spec. Auditor receives only the spec and the deliverable — no orchestrator preload. Auditor produces PASS/FAIL per SC with evidence artifacts. **→ All SCs**
- [ ] 61. **Cross-validate (**clean-room**).** Dispatch a second clean-room auditor to cross-validate the first auditor's verdicts. Resolve any disagreements via consensus. **→ All SCs**
- [ ] 62. **Regression check (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` to confirm all behavioral tests still pass after audit. **→ SC-12**
- [ ] 63. **pre-pr-gate (**sub-agent**).** Dispatch `verification-before-completion --task verify` — reads all SC verdicts, BLOCKs if any FAIL. **→ SC-13**
- [ ] 64. **Review-prep (**clean-room**).** Prepare PR body with Summary, Outcome, Fixes structure. Verify compare URL base branch is `$DEFAULT_BRANCH`. **→ All SCs**
- [ ] 65. **create-pr (**sub-agent**).** Dispatch `pr-creation-workflow --task create` to create pull request. **→ All SCs**
- [ ] 66. **Executive summary (**inline**).** Report: Summary → Outcome → Blockers (if any) → URL → Byline. HALT.

### Phase 1 VbC

- [ ] 67. **VbC: Verify SC-1 (**clean-room**).** `grep -c redactSecrets .opencode/plugins/session-enforcement.ts` → 0. **→ SC-1** `evidence_type: behavioral`
- [ ] 68. **VbC: Verify SC-2 (**clean-room**).** `cat .opencode/opencode.jsonc | jq -r '.plugin[]' | grep opencode-vibeguard@0.1.0` → match found. **→ SC-2** `evidence_type: behavioral`
- [ ] 69. **VbC: Verify SC-3 (**clean-room**).** `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts` → ≥1. **→ SC-3** `evidence_type: behavioral`
- [ ] 70. **VbC: Verify SC-4 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` → ≥3. **→ SC-4** `evidence_type: behavioral`
- [ ] 71. **VbC: Verify SC-5 (**clean-room**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test" 2>&1 | grep -c "replace count"` → >0. **→ SC-5** `evidence_type: behavioral`
- [ ] 72. **VbC: Verify SC-6 (**clean-room**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "bash echo test" 2>&1 | grep -c "restore"` → >0. **→ SC-6** `evidence_type: behavioral`
- [ ] 73. **VbC: Verify SC-7 (**clean-room**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test secret" 2>&1 | grep -c "historical"` → >0. **→ SC-7** `evidence_type: behavioral`
- [ ] 74. **VbC: Verify SC-8 (**clean-room**).** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "stream test" 2>&1 | grep -c "text-end"` → >0. **→ SC-8** `evidence_type: behavioral`
- [ ] 75. **VbC: Verify SC-9 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.regex[] | select(.pattern | test("sk-|ghp|AKIA"))' | wc -l` → ≥3. **→ SC-9** `evidence_type: behavioral`
- [ ] 76. **VbC: Verify SC-10 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.builtin[]' | wc -l` → ≥6. **→ SC-10** `evidence_type: behavioral`
- [ ] 77. **VbC: Verify SC-11 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.keywords | length'` → ≥1. **→ SC-11** `evidence_type: behavioral`
- [ ] 78. **VbC: Verify SC-12 (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` → PASS. **→ SC-12** `evidence_type: behavioral`
- [ ] 79. **VbC: Verify SC-13 (**clean-room**).** `grep -r "structural\|string" .issues/1974/sc-summary.yaml` → 0 for behavioral SCs. **→ SC-13** `evidence_type: behavioral`

**Mandatory gate for behavioral SCs:** After each behavioral test artifact is generated (steps 52–64), dispatch `behavioral-test-evaluation` from `verification-before-completion` before allowing PASS verdict. The evaluation task dispatches clean-room sub-agents to read artifacts and produce PASS/FAIL per SC. "Artifact generated" is NEVER a valid PASS verdict — only clean-room evaluation counts.

> **Self-remediation protocol:** If any step fails, the agent MUST remediate the root cause and re-run the step. Do NOT skip, reorder, or mark as "done with concerns." If remediation fails twice, report double-failure with both failure artifacts and HALT. Checkpoint rollback: `git reset --hard <parent>/checkpoint/1974/phase-1-<submodule>` on verification failure after pre-rollback diagnostics.

**Concern transition:** All concerns resolved within Phase 1. No subsequent phases.

---

## Exit Criteria

- [ ] C1: SC-1 — `redactSecrets()` removed from `session-enforcement.ts` — PASS with behavioral evidence
- [ ] C2: SC-2 — `opencode-vibeguard@0.1.0` installed via `opencode.jsonc` plugins array — PASS with behavioral evidence
- [ ] C3: SC-3 — Mode-switch stripping preserved in `session-enforcement.ts` — PASS with behavioral evidence
- [ ] C4: SC-4 — `vibeguard.config.json` created in `.opencode/` with regex patterns — PASS with behavioral evidence
- [ ] C5: SC-5 — Pre-request redaction: secrets redacted before LLM requests — PASS with behavioral evidence
- [ ] C6: SC-6 — Pre-tool restoration: placeholders restored before tool execution — PASS with behavioral evidence
- [ ] C7: SC-7 — Historical redaction: tool outputs redacted in conversation history — PASS with behavioral evidence
- [ ] C8: SC-8 — Streaming edge case handled: placeholder sanitized at text-end — PASS with behavioral evidence
- [ ] C9: SC-9 — Config supports regex patterns for API keys (OpenAI, GitHub, AWS) — PASS with behavioral evidence
- [ ] C10: SC-10 — Config supports builtin PII detectors (email, phone, ID, UUID, IP, MAC) — PASS with behavioral evidence
- [ ] C11: SC-11 — Config supports keyword patterns for custom secrets — PASS with behavioral evidence
- [ ] C12: SC-12 — Behavioral enforcement tests written and pass (RED→GREEN cycle) — PASS with behavioral evidence
- [ ] C13: SC-13 — No SC weakened, deferred, or reclassified to lower evidence type — PASS with behavioral evidence
- [ ] C14: All behavioral evidence artifacts collected and verified by clean-room evaluation
- [ ] C15: Audit PASS for all 13 SCs
- [ ] C16: Cross-validate consensus achieved
- [ ] C17: Regression check PASS
- [ ] C18: Review-prep complete with correct compare URL
- [ ] C19: Executive summary reported with byline
