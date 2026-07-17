---
title: Remove git config watchdog and all git calls from session-enforcement.ts — keep only session-init injection and mode-switch stripping
status: draft
created: 2026-07-17
license: MIT
provenance: AI-generated
issue: 1975
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** APPROVED (plan auto-approved via `for_pr` scope)
**CREATED:** 2026-07-17

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Git config watchdog completely removed | 1 | 1.1 |
| SC-2 | No direct git CLI calls | 1 | 1.1 |
| SC-3 | Git hook installation logic removed | 1 | 1.1 |
| SC-4 | Secret redaction code removed | 1 | 1.1 |
| SC-5 | Guidelines index injection removed | 1 | 1.1 |
| SC-6 | Skill index injection removed | 1 | 1.1 |
| SC-7 | Frontmatter validation removed | 1 | 1.1 |
| SC-8 | Sub-agent tracking removed | 1 | 1.1 |
| SC-9 | Session triggers removed | 1 | 1.1 |
| SC-10 | Plugin diagnostics removed | 1 | 1.1 |
| SC-11 | Session-init injection preserved | 1 | 1.1 |
| SC-12 | Mode-switch stripping preserved | 1 | 1.1 |
| SC-13 | Named export maintained | 1 | 1.1 |
| SC-14 | No new dependencies added | 1 | 1.1 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (file replacement only; HEAD version preserved in git)
- Rollback plan: `git checkout HEAD -- plugins/session-enforcement.ts` restores the original
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/plugins/session-enforcement.ts` | ✅ | Working dir exists, 74 lines |
| 1.1 | `git -C .opencode show HEAD:plugins/session-enforcement.ts` | ✅ | HEAD version is 1147 lines |
| 1.1 | `@opencode-ai/plugin` | ✅ | Already imported in working dir file |
| 1.1 | `child_process` (execSync) | ✅ | Already imported in working dir file |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| HEAD has git config watchdog | `git -C .opencode show HEAD:plugins/session-enforcement.ts` | ✅ |
| Working dir has minimal rewrite | `cat .opencode/plugins/session-enforcement.ts` | ✅ |
| No git CLI calls in working dir | `grep -r "execSync.*git\|gitPath\|resolveGitPath" .opencode/plugins/session-enforcement.ts` | ✅ |
| Named export present | `grep -r "export const SessionEnforcementPlugin" .opencode/plugins/session-enforcement.ts` | ✅ |
| Session-init call preserved | `grep -r "runSessionInit\|session-init" .opencode/plugins/session-enforcement.ts` | ✅ |
| Mode-switch stripping preserved | `grep -r "isModeSwitchSynthetic\|mode-switch" .opencode/plugins/session-enforcement.ts` | ✅ |

---

## Phase 1: Replace session-enforcement.ts with minimal rewrite

### Phase 1 Plan

Apply the working directory minimal rewrite (~74 lines) as the committed version, replacing the HEAD version (~1147 lines).

### Steps

#### Step 1.1: Stage and commit the minimal rewrite

- **Action:** Stage the current working file and commit with message: `feat(session-enforcement): strip to minimal — session-init injection + mode-switch stripping only`
- **Files affected:** `.opencode/plugins/session-enforcement.ts`
- **Rationale:** Working directory already contains the correct minimal version. No code changes needed — just commit.

### Phase 1 Exit Criteria

| SC ID | Verification Method | Evidence Type |
|-------|-------------------|---------------|
| SC-1 | `grep -r "gitConfigBaseline\|captureGitConfigBaseline\|buildGitConfigMutationBlock\|SECURITY_RELEVANT_KEY_PATTERNS" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-2 | `grep -r "execSync.*git\|gitPath\|resolveGitPath\|GIT_FALLBACK_PATHS" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-3 | `grep -r "ensureHooksInstalled\|hooksSourceDir\|hooksTargetDir" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-4 | `grep -r "redactSecrets\|SECRET_PATTERNS" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-5 | `grep -r "buildGuidelinesIndex\|INDEX.md" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-6 | `grep -r "buildSkillIndex\|loadSkillDescriptions\|extractTriggerPatterns" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-7 | `grep -r "extractFrontmatter\|buildFrontmatterWarning\|frontmatterErrors" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-8 | `grep -r "subAgentSessions\|injectedFirstTurnSessions\|sessionParentCache\|session\.created" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-9 | `grep -r "runSessionContextTriggers\|session_context_triggers\|SESSION_TRIGGERS" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-10 | `grep -r "writeDiagnostic\|collectDiagnostics\|buildDiagnosticBlock\|DIAGNOSTICS_PATH" .opencode/plugins/session-enforcement.ts` — no matches | `string` |
| SC-11 | `grep -r "runSessionInit\|session-init" .opencode/plugins/session-enforcement.ts` — matches found | `behavioral` |
| SC-12 | `grep -r "isModeSwitchSynthetic\|mode-switch\|Plan Mode" .opencode/plugins/session-enforcement.ts` — matches found | `behavioral` |
| SC-13 | `grep -r "export const SessionEnforcementPlugin" .opencode/plugins/session-enforcement.ts` — match found | `string` |
| SC-14 | `grep -r "import\|require" .opencode/plugins/session-enforcement.ts` — only `@opencode-ai/plugin` and `child_process` | `string` |

**Cross-cutting SCs (SC-11, SC-12, SC-13, SC-14):** Verified in Phase 1, applies to all phases.

---

## Implementation Gate Mapping

Every implementation pipeline gate from `implementation-pipeline/SKILL.md` Trigger Dispatch Table is covered:

| Gate | Coverage in This Plan |
|------|-----------------------|
| pre-work (git-workflow --task pre-work) | Step 1.1 — create branch and commit |
| implementation-pipeline (dispatch stages) | Step 1.1 — single implementation action |
| verification-before-completion | Phase 1 exit criteria — all 14 SCs verified |
| finishing-a-development-branch --task checklist | Post-implementation: verify commit, push, PR readiness |
| review-prep (git-workflow --task review-prep) | Post-implementation: PR preparation |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
