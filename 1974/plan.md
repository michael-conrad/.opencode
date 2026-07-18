# Implementation Plan — [.opencode#1974](https://github.com/michael-conrad/.opencode/issues/1974) — Add secret redaction plugin (opencode-vibeguard)

**Spec:** #1974

- **Goal:** Install `opencode-vibeguard@0.1.0` npm plugin, configure `vibeguard.config.json`, remove home-grown `redactSecrets()` from `session-enforcement.ts`, and achieve three-layer secret protection (pre-request redaction, pre-tool restoration, historical redaction) with behavioral enforcement tests.
- **Architecture:** Single-phase plan. All 13 SCs map to Phase 1. Solve order: ITEM-1 (config + install) → ITEM-2 (plugin verification) → ITEM-3 (code removal) → ITEM-4 (meta-tests). Each item builds on prior completed work. Structural SCs use content-verification checks (no RED/GREEN). Behavioral SCs use behavioral test harness with RED/GREEN cycles.
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
| Config + install | Phase 1 | ITEM-1 (SC-2, SC-4, SC-9, SC-10, SC-11) |
| Plugin verification | Phase 1 | ITEM-2 (SC-5, SC-6, SC-7, SC-8) |
| Code removal | Phase 1 | ITEM-3 (SC-1, SC-3) |
| Meta-tests | Phase 1 | ITEM-4 (SC-12, SC-13) |

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
| SC-1 | `redactSecrets()` removed from `session-enforcement.ts` | structural | ITEM-3 | 4–5 |
| SC-2 | `opencode-vibeguard@0.1.0` installed via `opencode.jsonc` plugins array | structural | ITEM-1 | 6–8 |
| SC-3 | Mode-switch stripping preserved in `session-enforcement.ts` | structural | ITEM-3 | 4–5 |
| SC-4 | `vibeguard.config.json` created in `.opencode/` with regex patterns | structural | ITEM-1 | 9–11 |
| SC-5 | Pre-request redaction: secrets redacted before LLM requests | behavioral | ITEM-2 | 12–14 |
| SC-6 | Pre-tool restoration: placeholders restored before tool execution | behavioral | ITEM-2 | 15–17 |
| SC-7 | Historical redaction: tool outputs redacted in conversation history | behavioral | ITEM-2 | 18–20 |
| SC-8 | Streaming edge case handled: placeholder sanitized at text-end | behavioral | ITEM-2 | 21–23 |
| SC-9 | Config supports regex patterns for API keys (OpenAI, GitHub, AWS) | structural | ITEM-1 | 9–11 |
| SC-10 | Config supports builtin PII detectors (email, phone, ID, UUID, IP, MAC) | structural | ITEM-1 | 9–11 |
| SC-11 | Config supports keyword patterns for custom secrets | structural | ITEM-1 | 9–11 |
| SC-12 | Behavioral enforcement tests written and pass (RED→GREEN cycle) | structural | ITEM-4 | 24–26 |
| SC-13 | No SC weakened, deferred, or reclassified to lower evidence type | structural | ITEM-4 | 24–26 |

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

**Concern:** All concerns — config + install, plugin verification, code removal, meta-tests.

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
- All 13 SCs verified PASS with correct evidence types
- Behavioral enforcement tests pass with 100% clean PASS
- No SC weakened, deferred, or reclassified

### Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `session-enforcement.ts` redactSecrets() removal | ITEM-3 |
| `session-enforcement.ts` mode-switch preservation | ITEM-3 |
| `opencode.jsonc` plugin array modification | ITEM-1 |
| `vibeguard.config.json` creation and pattern configuration | ITEM-1 |
| Plugin pre-request redaction path | ITEM-2 |
| Plugin pre-tool restoration path | ITEM-2 |
| Plugin historical redaction path | ITEM-2 |
| Plugin streaming text-end sanitization | ITEM-2 |
| Behavioral test execution path | ITEM-4 |
| Evidence type verification path | ITEM-4 |

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
| Home-grown redaction → Plugin redaction | `redactSecrets()` removal | ITEM-3 |
| Unverified → Verified | Behavioral test execution | ITEM-4 |

---

### Step-by-step

#### Pre-steps (Global)

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec SCs are internally consistent, all 13 SCs have unique IDs, evidence types match verification methods, and no SC conflicts with already-merged specs. **→ SC-13**
- [ ] 2. **Pre-red baseline (**clean-room**).** Capture current state of all affected files: `git show HEAD:.opencode/plugins/session-enforcement.ts` for `redactSecrets()` presence, `cat .opencode/opencode.jsonc` for current plugins array, verify `vibeguard.config.json` does not exist. **→ SC-1, SC-2, SC-4**
- [ ] 3. **Feature branch creation (**inline**).** Create feature branch `feature/1974-secret-redaction` from trunk. Verify branch created successfully.

#### ITEM-1: Config + install (SC-2, SC-4, SC-9, SC-10, SC-11) — structural

Structural SCs use content-verification checks. No RED/GREEN cycles — just verify.

- [ ] 4. **Verify SC-2: plugin not yet installed (**inline**).** Run `grep -c opencode-vibeguard@0.1.0 .opencode/opencode.jsonc` → 0. **→ SC-2**
- [ ] 5. **Create `vibeguard.config.json` (**sub-agent**).** Create `.opencode/vibeguard.config.json` with:
  - `patterns.regex` array containing ≥3 regex patterns for API keys (OpenAI `sk-...`, GitHub `ghp_...`, AWS `AKIA...`)
  - `patterns.builtin` array containing ≥6 builtin PII detectors (email, phone, ID, UUID, IPv4, MAC address)
  - `patterns.keywords` array containing ≥1 keyword pattern for custom secrets
  - `enabled: true`
  - **→ SC-4, SC-9, SC-10, SC-11**
- [ ] 6. **Install plugin in `opencode.jsonc` (**sub-agent**).** Edit `.opencode/opencode.jsonc`: add `"opencode-vibeguard@0.1.0"` to the `plugin` array. **→ SC-2**
- [ ] 7. **Verify SC-2: plugin installed (**inline**).** Run `grep -c opencode-vibeguard@0.1.0 .opencode/opencode.jsonc` → 1. **→ SC-2**
- [ ] 8. **Verify SC-4: config has regex patterns (**inline**).** Run `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` → ≥3. **→ SC-4**
- [ ] 9. **Verify SC-9: regex patterns for API keys (**inline**).** Run `cat .opencode/vibeguard.config.json | jq '.patterns.regex[] | select(.pattern | test("sk-|ghp|AKIA"))' | wc -l` → ≥3. **→ SC-9**
- [ ] 10. **Verify SC-10: builtin PII detectors (**inline**).** Run `cat .opencode/vibeguard.config.json | jq '.patterns.builtin[]' | wc -l` → ≥6. **→ SC-10**
- [ ] 11. **Verify SC-11: keyword patterns (**inline**).** Run `cat .opencode/vibeguard.config.json | jq '.patterns.keywords | length'` → ≥1. **→ SC-11**
- [ ] 12. **Checkpoint commit (**inline**).** `git add .opencode/opencode.jsonc .opencode/vibeguard.config.json && git commit -m "1974 ITEM-1: Plugin install, config creation, patterns"`. Create checkpoint tag `opencode/checkpoint/1974/phase-1-opencode`.

#### ITEM-2: Plugin verification test scripts (SC-5, SC-6, SC-7, SC-8) — structural

Behavioral SCs are verified by artifact-only generator scripts. During implementation, verification is structural (file exists, has correct content). Actual behavioral execution happens in ITEM-4 (SC-12) when the full test suite runs against the feature branch.

- [ ] 13. **Create SC-5 test script (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-5.sh` that:
  - Uses `behavior_run` with a real-domain prompt: `"I need to tell you my API key: sk-abc123def456. Please store it securely."`
  - The script is an artifact-only generator (exits 0, produces artifacts)
  - **→ SC-5**
- [ ] 14. **Verify SC-5 script exists (**inline**).** `ls .opencode/tests-v2/behaviors/secret-redaction/SC-5.sh` → exists. **→ SC-5**
- [ ] 15. **Create SC-6 test script (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-6.sh` that:
  - Uses `behavior_run` with a real-domain prompt: `"My database password is super_secret_2024. Can you help me write a query?"`
  - The script is an artifact-only generator (exits 0, produces artifacts)
  - **→ SC-6**
- [ ] 16. **Verify SC-6 script exists (**inline**).** `ls .opencode/tests-v2/behaviors/secret-redaction/SC-6.sh` → exists. **→ SC-6**
- [ ] 17. **Create SC-7 test script (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-7.sh` that:
  - Uses `behavior_run` with a real-domain prompt: `"The server URL is https://admin:password123@example.com/api"`
  - The script is an artifact-only generator (exits 0, produces artifacts)
  - **→ SC-7**
- [ ] 18. **Verify SC-7 script exists (**inline**).** `ls .opencode/tests-v2/behaviors/secret-redaction/SC-7.sh` → exists. **→ SC-7**
- [ ] 19. **Create SC-8 test script (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/SC-8.sh` that:
  - Uses `behavior_run` with a real-domain prompt: `"I need to tell you my API key: sk-abc123def456. Please store it securely."`
  - The script is an artifact-only generator (exits 0, produces artifacts)
  - **→ SC-8**
- [ ] 20. **Verify SC-8 script exists (**inline**).** `ls .opencode/tests-v2/behaviors/secret-redaction/SC-8.sh` → exists. **→ SC-8**
- [ ] 21. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/secret-redaction/SC-5.sh .opencode/tests-v2/behaviors/secret-redaction/SC-6.sh .opencode/tests-v2/behaviors/secret-redaction/SC-7.sh .opencode/tests-v2/behaviors/secret-redaction/SC-8.sh && git commit -m "1974 ITEM-2: Plugin verification test scripts"`. Update checkpoint tag.

#### ITEM-3: Code removal (SC-1, SC-3) — structural

Structural SCs use content-verification checks. No RED/GREEN cycles — just verify.

- [ ] 26. **Verify SC-1: redactSecrets() already removed (**inline**).** Run `grep -c redactSecrets .opencode/plugins/session-enforcement.ts` → 0. Already satisfied by merged PR #1976. Verification only — no implementation needed. **→ SC-1**
- [ ] 27. **Verify SC-3: mode-switch stripping preserved (**inline**).** Run `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts` → ≥1. **→ SC-3**
- [ ] 28. **Checkpoint commit (**inline**).** `git add .opencode/plugins/session-enforcement.ts && git commit -m "1974 ITEM-3: Verify redactSecrets() removed, mode-switch preserved"`. Update checkpoint tag.

#### ITEM-4: Meta-tests (SC-12, SC-13) — structural

Structural SCs use content-verification checks. No RED/GREEN cycles — just verify.

- [ ] 29. **Create run.sh for all behavioral tests (**sub-agent**).** Create `.opencode/tests-v2/behaviors/secret-redaction/run.sh` that runs all SC behavioral test scripts (SC-5 through SC-8) and exits 0 only if all pass. **→ SC-12**
- [ ] 30. **Verify SC-12: full test suite passes (**inline**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` → exit 0. **→ SC-12**
- [ ] 31. **Verify SC-13: no SC weakened (**inline**).** Audit all 13 SCs in the spec. Confirm every SC's evidence type matches the spec declarations (SC-1/2/3/4/9/10/11/12/13 = structural, SC-5/6/7/8 = behavioral). Confirm no SC was reclassified to a lower evidence type. **→ SC-13**
- [ ] 32. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/secret-redaction/run.sh && git commit -m "1974 ITEM-4: Meta-tests and evidence type audit"`. Update checkpoint tag.

#### Post-steps (Global — Implementation Pipeline Gates)

- [ ] 33. **z3-check-red (**inline**).** Run `solve check` on RED phase output contract to validate state transition. **→ SC-13**
- [ ] 34. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` to verify RED phase results. **→ SC-13**
- [ ] 35. **z3-check-red-doublecheck (**inline**).** Run `solve check` on RED doublecheck output contract. **→ SC-13**
- [ ] 36. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. **→ SC-13**
- [ ] 37. **z3-check-post-red (**inline**).** Run `solve check` on post-RED enforcement output contract. **→ SC-13**
- [ ] 38. **z3-check-green (**inline**).** Run `solve check` on GREEN phase output contract. **→ SC-13**
- [ ] 39. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. **→ SC-13**
- [ ] 40. **z3-check-post-green (**inline**).** Run `solve check` on post-GREEN enforcement output contract. **→ SC-13**
- [ ] 41. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **→ SC-13**
- [ ] 42. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. **→ SC-13**
- [ ] 43. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` to verify GREEN phase results. **→ SC-13**
- [ ] 44. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion` for verification before completion. **→ SC-13**
- [ ] 45. **sc-count-gate (**sub-agent**).** Read `sc-summary.yaml` total SC count (13), count verified SCs from VbC evidence. BLOCK if `verified_count < 13`. **→ SC-13**
- [ ] 46. **Collect behavioral evidence (**sub-agent**).** Gather all behavioral evidence artifacts from `{project_root}/tmp/behavioral-evidence-*/` into `{project_root}/tmp/1974/artifacts/`. Verify each artifact exists and is non-empty. **→ SC-12**
- [ ] 47. **Audit (**clean-room**).** Dispatch `audit` skill to audit all 13 SCs against the spec. Auditor receives only the spec and the deliverable — no orchestrator preload. Auditor produces PASS/FAIL per SC with evidence artifacts. **→ All SCs**
- [ ] 48. **Cross-validate (**clean-room**).** Dispatch a second clean-room auditor to cross-validate the first auditor's verdicts. Resolve any disagreements via consensus. **→ All SCs**
- [ ] 49. **Regression check (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` to confirm all behavioral tests still pass after audit. **→ SC-12**
- [ ] 50. **pre-pr-gate (**sub-agent**).** Dispatch `verification-before-completion --task verify` — reads all SC verdicts, BLOCKs if any FAIL. **→ SC-13**
- [ ] 51. **Review-prep (**clean-room**).** Prepare PR body with Summary, Outcome, Fixes structure. Verify compare URL base branch is `$DEFAULT_BRANCH`. **→ All SCs**
- [ ] 52. **create-pr (**sub-agent**).** Dispatch `pr-creation-workflow --task create` to create pull request. **→ All SCs**
- [ ] 53. **Executive summary (**inline**).** Report: Summary → Outcome → Blockers (if any) → URL → Byline. HALT.

### Phase 1 VbC

- [ ] 54. **VbC: Verify SC-1 (**clean-room**).** `grep -c redactSecrets .opencode/plugins/session-enforcement.ts` → 0. **→ SC-1** `evidence_type: structural`
- [ ] 55. **VbC: Verify SC-2 (**clean-room**).** `grep -c opencode-vibeguard@0.1.0 .opencode/opencode.jsonc` → 1. **→ SC-2** `evidence_type: structural`
- [ ] 56. **VbC: Verify SC-3 (**clean-room**).** `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts` → ≥1. **→ SC-3** `evidence_type: structural`
- [ ] 57. **VbC: Verify SC-4 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` → ≥3. **→ SC-4** `evidence_type: structural`
- [ ] 58. **VbC: Verify SC-5 (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/SC-5.sh` → exit 0 with non-empty artifacts. **→ SC-5** `evidence_type: behavioral`
- [ ] 59. **VbC: Verify SC-6 (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/SC-6.sh` → exit 0 with non-empty artifacts. **→ SC-6** `evidence_type: behavioral`
- [ ] 60. **VbC: Verify SC-7 (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/SC-7.sh` → exit 0 with non-empty artifacts. **→ SC-7** `evidence_type: behavioral`
- [ ] 61. **VbC: Verify SC-8 (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/SC-8.sh` → exit 0 with non-empty artifacts. **→ SC-8** `evidence_type: behavioral`
- [ ] 62. **VbC: Verify SC-9 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.regex[] | select(.pattern | test("sk-|ghp|AKIA"))' | wc -l` → ≥3. **→ SC-9** `evidence_type: structural`
- [ ] 63. **VbC: Verify SC-10 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.builtin[]' | wc -l` → ≥6. **→ SC-10** `evidence_type: structural`
- [ ] 64. **VbC: Verify SC-11 (**clean-room**).** `cat .opencode/vibeguard.config.json | jq '.patterns.keywords | length'` → ≥1. **→ SC-11** `evidence_type: structural`
- [ ] 65. **VbC: Verify SC-12 (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` → exit 0. **→ SC-12** `evidence_type: structural`
- [ ] 66. **VbC: Verify SC-13 (**clean-room**).** Audit all 13 SCs evidence types against spec declarations. Confirm no SC reclassified to lower evidence type. **→ SC-13** `evidence_type: structural`

**Mandatory gate for behavioral SCs:** After each behavioral test artifact is generated (steps 13–24), dispatch `behavioral-test-evaluation` from `verification-before-completion` before allowing PASS verdict. The evaluation task dispatches clean-room sub-agents to read artifacts and produce PASS/FAIL per SC. "Artifact generated" is NEVER a valid PASS verdict — only clean-room evaluation counts.

> **Self-remediation protocol:** If any step fails, the agent MUST remediate the root cause and re-run the step. Do NOT skip, reorder, or mark as "done with concerns." If remediation fails twice, report double-failure with both failure artifacts and HALT. Checkpoint rollback: `git reset --hard <parent>/checkpoint/1974/phase-1-<submodule>` on verification failure after pre-rollback diagnostics.

**Concern transition:** All concerns resolved within Phase 1. No subsequent phases.

---

## Exit Criteria

- [ ] C1: SC-1 — `redactSecrets()` removed from `session-enforcement.ts` — PASS with structural evidence
- [ ] C2: SC-2 — `opencode-vibeguard@0.1.0` installed via `opencode.jsonc` plugins array — PASS with structural evidence
- [ ] C3: SC-3 — Mode-switch stripping preserved in `session-enforcement.ts` — PASS with structural evidence
- [ ] C4: SC-4 — `vibeguard.config.json` created in `.opencode/` with regex patterns — PASS with structural evidence
- [ ] C5: SC-5 — Pre-request redaction: secrets redacted before LLM requests — PASS with behavioral evidence
- [ ] C6: SC-6 — Pre-tool restoration: placeholders restored before tool execution — PASS with behavioral evidence
- [ ] C7: SC-7 — Historical redaction: tool outputs redacted in conversation history — PASS with behavioral evidence
- [ ] C8: SC-8 — Streaming edge case handled: placeholder sanitized at text-end — PASS with behavioral evidence
- [ ] C9: SC-9 — Config supports regex patterns for API keys (OpenAI, GitHub, AWS) — PASS with structural evidence
- [ ] C10: SC-10 — Config supports builtin PII detectors (email, phone, ID, UUID, IP, MAC) — PASS with structural evidence
- [ ] C11: SC-11 — Config supports keyword patterns for custom secrets — PASS with structural evidence
- [ ] C12: SC-12 — Behavioral enforcement tests written and pass (RED→GREEN cycle) — PASS with structural evidence
- [ ] C13: SC-13 — No SC weakened, deferred, or reclassified to lower evidence type — PASS with structural evidence
- [ ] C14: All behavioral evidence artifacts collected and verified by clean-room evaluation
- [ ] C15: Audit PASS for all 13 SCs
- [ ] C16: Cross-validate consensus achieved
- [ ] C17: Regression check PASS
- [ ] C18: Review-prep complete with correct compare URL
- [ ] C19: Executive summary reported with byline
