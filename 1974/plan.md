---
title: Implementation Plan — Add secret redaction plugin (opencode-vibeguard)
status: draft
created: 2026-07-17
issue: 1974
license: MIT
provenance: AI-generated
---

**STATUS:** DRAFT
**CREATED:** 2026-07-17
**AUTHORIZATION SCOPE:** for_plan
**HALT AT:** plan_created

## Overview

Single-phase implementation plan for issue #1974: Replace home-grown `redactSecrets()` with `opencode-vibeguard@0.1.0` npm plugin. Phase 1 covers all 13 success criteria: plugin installation, config creation, code removal, mode-switch preservation, and behavioral testing.

## Phase Table

| Phase | Description | SCs | Precondition | Steps |
|-------|-------------|-----|-------------|-------|
| 1 | Install plugin, create config, remove redactSecrets(), preserve mode-switch, write behavioral tests | SC-1 through SC-13 | Approved spec, feature branch created, submodules synced | 1.1–1.13 |

## Phase 1 — Plugin Installation, Config, Code Removal, and Testing

### SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Home-grown `redactSecrets()` removed from `session-enforcement.ts` | 1 | 1.1 |
| SC-2 | `opencode-vibeguard@0.1.0` installed via `opencode.jsonc` plugins array | 1 | 1.2 |
| SC-3 | Mode-switch stripping preserved in `session-enforcement.ts` | 1 | 1.3 |
| SC-4 | `vibeguard.config.json` created in `.opencode/` with regex patterns | 1 | 1.4 |
| SC-5 | Pre-request redaction: secrets redacted before LLM requests | 1 | 1.5 |
| SC-6 | Pre-tool restoration: placeholders restored before tool execution | 1 | 1.5 |
| SC-7 | Historical redaction: tool outputs redacted in conversation history | 1 | 1.5 |
| SC-8 | Streaming edge case handled: placeholder sanitized at text-end | 1 | 1.5 |
| SC-9 | Config supports regex patterns for API keys (OpenAI, GitHub, AWS) | 1 | 1.4 |
| SC-10 | Config supports builtin PII detectors (email, phone, ID, UUID, IP, MAC) | 1 | 1.4 |
| SC-11 | Config supports keyword patterns for custom secrets | 1 | 1.4 |
| SC-12 | Behavioral enforcement tests written and pass (RED→GREEN cycle) | 1 | 1.6, 1.7 |
| SC-13 | No SC weakened, deferred, or reclassified to lower evidence type | 1 | 1.8 |

### Steps

#### Step 1.1 — Verify redactSecrets() removal and remove if present (RED)
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Run `grep -c redactSecrets .opencode/plugins/session-enforcement.ts`. If count > 0, remove the function body and all references. If count == 0, confirm removal is already complete.
- **Verification:** `grep -c redactSecrets .opencode/plugins/session-enforcement.ts` → 0
- **Rollback:** `git checkout .opencode/plugins/session-enforcement.ts` to restore from git
- **Evidence type:** behavioral
- **SC:** SC-1

#### Step 1.2 — Add opencode-vibeguard@0.1.0 to opencode.jsonc plugins array (GREEN)
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Read `.opencode/opencode.jsonc`, add `"opencode-vibeguard@0.1.0"` to the `plugin` array. If no `plugin` key exists, create it.
- **Verification:** `cat .opencode/opencode.jsonc | jq -r '.plugin[]' | grep opencode-vibeguard@0.1.0` → match found
- **Rollback:** Remove the entry from the plugin array
- **Evidence type:** behavioral
- **SC:** SC-2

#### Step 1.3 — Verify mode-switch stripping preserved (RED)
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Run `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts`. If count ≥ 1, confirm preservation. If count == 0, restore from git history.
- **Verification:** `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts` → ≥ 1
- **Rollback:** `git checkout .opencode/plugins/session-enforcement.ts` to restore
- **Evidence type:** behavioral
- **SC:** SC-3

#### Step 1.4 — Create vibeguard.config.json with regex, keywords, and builtin PII (GREEN)
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Create `.opencode/vibeguard.config.json` with:
  - `patterns.regex`: ≥3 patterns for API keys (OpenAI `sk-...`, GitHub `ghp_...`, AWS `AKIA...`)
  - `patterns.builtin`: ≥6 detectors (email, phone, ID, UUID, IPv4, MAC)
  - `patterns.keywords`: ≥1 keyword pattern for custom secrets
  - `enabled: true`
  - `debug: false` (configurable via env var)
- **Verification:**
  - `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` → ≥ 3
  - `cat .opencode/vibeguard.config.json | jq '.patterns.builtin[]' | wc -l` → ≥ 6
  - `cat .opencode/vibeguard.config.json | jq '.patterns.keywords | length'` → ≥ 1
- **Rollback:** Delete `.opencode/vibeguard.config.json`
- **Evidence type:** behavioral
- **SC:** SC-4, SC-9, SC-10, SC-11

#### Step 1.5 — Verify plugin provides three-layer protection and streaming handling (GREEN)
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Run `OPENCODE_VIBEGUARD_DEBUG=1 opencode run "test"` and verify:
  - Pre-request redaction: stderr contains "replace count" → SC-5
  - Pre-tool restoration: stderr contains "restore" → SC-6
  - Historical redaction: stderr contains "historical" → SC-7
  - Streaming handling: stderr contains "text-end" → SC-8
- **Verification:** Each SC has its own behavioral test script at `.opencode/tests-v2/behaviors/secret-redaction/SC-{N}.sh`
- **Rollback:** N/A — verification only, no destructive operations
- **Evidence type:** behavioral
- **SC:** SC-5, SC-6, SC-7, SC-8

#### Step 1.6 — Write behavioral enforcement tests (RED phase)
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Create behavioral test scripts in `.opencode/tests-v2/behaviors/secret-redaction/`:
  - `SC-1.sh` through `SC-11.sh`: One test per SC verifying the agent behavior
  - `SC-12.sh`: Verify behavioral tests exist and run
  - `SC-13.sh`: Verify no SC weakening
  - `run.sh`: Orchestrator that runs all SC tests
  - Each test uses `behavior_run` from `helpers.sh` and `assert_semantic` for behavioral assertions
  - Each test includes `# SC-N:` comment prefix linking to spec SC
- **Verification:** Each test script exists and is non-empty
- **Rollback:** `rm -rf .opencode/tests-v2/behaviors/secret-redaction/`
- **Evidence type:** behavioral
- **SC:** SC-12

#### Step 1.7 — Run behavioral tests and verify GREEN phase
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Run `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` → PASS
- **Verification:** All SC behavioral tests pass with 100% clean PASS
- **Rollback:** N/A — test execution only
- **Evidence type:** behavioral
- **SC:** SC-12

#### Step 1.8 — Anti-lobotomization verification
- **Dispatch:** `sub-agent` via `implementation-pipeline`
- **Action:** Verify no SC was weakened, deferred, or reclassified to lower evidence type. Check `sc-summary.yaml` for evidence type consistency.
- **Verification:** `grep -r "structural\|string" .issues/1974/sc-summary.yaml` → 0 for behavioral SCs
- **Rollback:** N/A — verification only
- **Evidence type:** behavioral
- **SC:** SC-13

### Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: Removal of `redactSecrets()` function (Step 1.1), file creation (Step 1.4), file creation (Step 1.6)
- Rollback plan: Each destructive step has its own rollback defined above. Full rollback: `git checkout .` to restore all files to pre-phase state
- Data loss risk: low — all changes are to tracked files; git history preserves originals

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/plugins/session-enforcement.ts` | ✅ | File exists in repo |
| 1.2 | `.opencode/opencode.jsonc` | ✅ | File exists in repo |
| 1.3 | `.opencode/plugins/session-enforcement.ts` `isModeSwitchSynthetic` | ✅ | Symbol exists in file |
| 1.4 | `opencode-vibeguard@0.1.0` npm package | ✅ | Verified via GitHub repo |
| 1.5 | `opencode run` CLI | ✅ | Available in environment |
| 1.6 | `.opencode/tests-v2/behaviors/helpers.sh` | ✅ | File exists |
| 1.7 | `bash` test runner | ✅ | Available in environment |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `redactSecrets()` was removed | `git log -p -- .opencode/plugins/session-enforcement.ts` | ✅ |
| `isModeSwitchSynthetic` exists | `grep -c isModeSwitchSynthetic .opencode/plugins/session-enforcement.ts` | ✅ |
| `opencode-vibeguard@0.1.0` exists on npm | GitHub repo: inkdust2021/opencode-vibeguard | ✅ |
| Plugin provides three-layer protection | README: "Pre-request redaction", "Pre-tool restoration", "Historical redaction" | ✅ |
| Config format supports regex/keywords/builtin | `vibeguard.config.json.example` | ✅ |
| opencode auto-installs npm plugins via Bun | README: auto-install on first use | ✅ |

### Implementation Pipeline Gate Steps

The following mandatory gates from the implementation-pipeline SKILL.md Trigger Dispatch Table are enumerated in this plan:

| Gate | Phase | Step(s) | Skill/Task Reference |
|------|-------|---------|---------------------|
| pre-work | 1 | Pre-step | `git-workflow --task pre-work` |
| RED | 1 | 1.1, 1.3 | `test-driven-development --task red` |
| GREEN | 1 | 1.2, 1.4, 1.5 | `test-driven-development --task green` |
| verification-before-completion | 1 | Post-step | `verification-before-completion --task verify` |
| finishing-checklist | 1 | Post-step | `finishing-a-development-branch --task checklist` |
| review-prep | 1 | Post-step | `git-workflow --task review-prep` |
| audit | 1 | Post-step | `audit --task spec-audit` |

### Phase Exit Criteria for Behavioral SCs

For each behavioral SC (SC-1 through SC-13), the exit criteria include:

1. **Artifact generation:** Run `behavior_run` to produce `stdout.log`, `stderr.log`, `session.yaml`
2. **Clean-room evaluation:** Dispatch `behavioral-test-evaluation` from `verification-before-completion` to read artifacts and produce PASS/FAIL per SC
3. **PASS verdict:** Only after clean-room evaluation returns PASS for all behavioral SCs

Each SC carries `evidence_type: behavioral` annotation in the SC table.

### VbC Gate for Behavioral SCs

After artifact generation in the verification-before-completion gate, the agent MUST dispatch `behavioral-test-evaluation` before allowing a PASS verdict. This is a mandatory gate — not optional.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
