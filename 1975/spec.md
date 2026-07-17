---
title: Remove git config watchdog and all git calls from session-enforcement.ts — keep only session-init injection and mode-switch stripping
status: draft
created: 2026-07-17
license: MIT
provenance: AI-generated
issue: 1975
authors:
  - OpenCode (nemotron-3-ultra-free)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-17

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The `session-enforcement.ts` plugin in the `.opencode` submodule currently contains a git config mutation watchdog and makes direct git calls via `execSync`. This violates the plugin's intended single responsibility of session context injection and mode-switch stripping. The git config watchdog monitors git configuration changes and injects warnings into user messages. The plugin also installs git hooks, performs secret redaction, injects guidelines/skill indexes, validates frontmatter, tracks sub-agents, and runs session context triggers — all of which are out of scope for a minimal session enforcement plugin.

The current HEAD commit in the `.opencode` submodule contains ~1,100 lines of code implementing these features. A minimal rewrite exists in the working directory that reduces the plugin to ~74 lines, keeping only session-init injection and mode-switch stripping. This spec formalizes that minimal rewrite as the official version.

## Goals

- Remove git config mutation watchdog from session-enforcement.ts
- Remove all direct git calls (git config, git remote, git rev-parse, git submodule) from session-enforcement.ts
- Remove git hook installation logic from session-enforcement.ts
- Remove secret redaction from session-enforcement.ts (delegated to opencode-vibeguard npm plugin)
- Remove guidelines index injection from session-enforcement.ts
- Remove skill index injection from session-enforcement.ts
- Remove frontmatter validation from session-enforcement.ts
- Remove sub-agent tracking logic from session-enforcement.ts
- Remove session context triggers from session-enforcement.ts
- Remove plugin diagnostics collection from session-enforcement.ts
- Keep only session-init injection (via execSync to session-init script)
- Keep only synthetic mode-switch message stripping
- Update plugin comment header to reflect minimal responsibilities

## Non-Goals

- Modifying the session-init script (it makes its own git calls for repository discovery)
- Modifying the session_context_triggers.py script
- Modifying the env-loader.ts plugin
- Modifying the opencode-vibeguard npm plugin
- Changing the session-init output format
- Adding new features to session-enforcement.ts

## Constraints and Scope

**In Scope:**
- session-enforcement.ts plugin file only
- Removal of all code except session-init injection and mode-switch stripping
- Named export requirement for OpenCode plugin system

**Out of Scope:**
- session-init script (.opencode/tools/session-init)
- session_context_triggers.py script
- env-loader.ts plugin
- opencode-vibeguard npm plugin
- Any other plugins or tools

## Root Cause Analysis

The session-enforcement.ts plugin accumulated features over time (git config watchdog, hook installation, secret redaction, skill/guidelines indexes, sub-agent tracking, session triggers, diagnostics) that are orthogonal to its core purpose. Each feature added git calls via execSync, increasing complexity, startup latency, and failure surface area. The plugin's original design did not anticipate this feature creep.

The minimal rewrite in the working directory demonstrates that the plugin can fulfill its core purpose (session context injection + mode-switch stripping) in ~74 lines without any git calls in the plugin itself.

## Alternatives Considered & Why Discarded

| Alternative | Rationale |
|-------------|-----------|
| Keep git config watchdog but make it optional | Adds complexity; watchdog is a Tier 1 mandate enforcement that belongs in pre-commit hooks, not a runtime plugin |
| Move git calls to a separate utility module | Still requires git calls in the plugin; doesn't reduce attack surface |
| Use git CLI via $.nothrow in new plugin API | The new PluginInput API doesn't expose git utilities; would require framework changes |
| Delegating all git operations to session-init | session-init already does this; the plugin should only invoke session-init |

## Safety Considerations

**Rollback Plan:** If the minimal rewrite breaks session context injection or mode-switch stripping:
1. Revert the session-enforcement.ts change via `git checkout HEAD -- plugins/session-enforcement.ts`
2. Verify the original HEAD version works
3. Report the regression with specific failure mode

**Safeguards:**
- The session-init script is unchanged and continues to provide repository identity
- The opencode-vibeguard npm plugin handles secret redaction
- Pre-commit hooks enforce git config policies
- No destructive operations in the plugin

## Evidence/Provenance

| Claim | Source | Verification |
|-------|--------|--------------|
| HEAD has git config watchdog | `git show HEAD:plugins/session-enforcement.ts` | Verified by reading committed file |
| HEAD makes git config --local --list calls | `git show HEAD:plugins/session-enforcement.ts` | Lines 170, 185, 505 in HEAD version |
| HEAD makes git remote -v calls | `git show HEAD:plugins/session-enforcement.ts` | Line 189 in HEAD version |
| HEAD installs git hooks | `git show HEAD:plugins/session-enforcement.ts` | ensureHooksInstalled() function |
| Working dir has minimal rewrite | `cat plugins/session-enforcement.ts` | 74 lines, only execSync to session-init |
| session-init makes git calls | `cat .opencode/tools/session-init` | run_git_command() used throughout |

## SC-to-Root-Cause Traceability Table

| SC | Root Cause Element |
|----|-------------------|
| SC-1 | Git config watchdog code in HEAD |
| SC-2 | Direct git calls in HEAD |
| SC-3 | Hook installation code in HEAD |
| SC-4 | Secret redaction code in HEAD |
| SC-5 | Guidelines index injection in HEAD |
| SC-6 | Skill index injection in HEAD |
| SC-7 | Frontmatter validation in HEAD |
| SC-8 | Sub-agent tracking in HEAD |
| SC-9 | Session triggers in HEAD |
| SC-10 | Plugin diagnostics in HEAD |
| SC-11 | Session-init injection preserved |
| SC-12 | Mode-switch stripping preserved |
| SC-13 | Named export maintained |
| SC-14 | No new dependencies added |

## Feasibility Assessment

All referenced artifacts exist:
- `plugins/session-enforcement.ts` (HEAD and working dir versions)
- `.opencode/tools/session-init` (session-init script)
- `opencode.jsonc` (references opencode-vibeguard plugin)
- `package.json` (opencode-vibeguard dependency)

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------------|-------------|----------------------|---------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Git config watchdog completely removed from session-enforcement.ts | `grep -r "gitConfigBaseline\|captureGitConfigBaseline\|buildGitConfigMutationBlock\|SECURITY_RELEVANT_KEY_PATTERNS" .opencode/plugins/session-enforcement.ts` returns no matches | Remove any remaining watchdog code | implementation | .opencode/plugins/session-enforcement.ts | Problem: git config watchdog in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-2 | No direct git CLI calls in session-enforcement.ts | `grep -r "execSync.*git\|gitPath\|resolveGitPath\|GIT_FALLBACK_PATHS" .opencode/plugins/session-enforcement.ts` returns no matches | Remove any remaining git CLI calls | implementation | .opencode/plugins/session-enforcement.ts | Problem: direct git calls in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-3 | Git hook installation logic removed | `grep -r "ensureHooksInstalled\|hooksSourceDir\|hooksTargetDir" .opencode/plugins/session-enforcement.ts` returns no matches | Remove hook installation code | implementation | .opencode/plugins/session-enforcement.ts | Problem: hook installation in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-4 | Secret redaction code removed | `grep -r "redactSecrets\|SECRET_PATTERNS" .opencode/plugins/session-enforcement.ts` returns no matches | Remove secret redaction code | implementation | .opencode/plugins/session-enforcement.ts | Problem: secret redaction in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-5 | Guidelines index injection removed | `grep -r "buildGuidelinesIndex\|INDEX.md" .opencode/plugins/session-enforcement.ts` returns no matches | Remove guidelines index code | implementation | .opencode/plugins/session-enforcement.ts | Problem: guidelines index in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-6 | Skill index injection removed | `grep -r "buildSkillIndex\|loadSkillDescriptions\|extractTriggerPatterns" .opencode/plugins/session-enforcement.ts` returns no matches | Remove skill index code | implementation | .opencode/plugins/session-enforcement.ts | Problem: skill index in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-7 | Frontmatter validation removed | `grep -r "extractFrontmatter\|buildFrontmatterWarning\|frontmatterErrors" .opencode/plugins/session-enforcement.ts` returns no matches | Remove frontmatter validation code | implementation | .opencode/plugins/session-enforcement.ts | Problem: frontmatter validation in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-8 | Sub-agent tracking removed | `grep -r "subAgentSessions\|injectedFirstTurnSessions\|sessionParentCache\|session\.created" .opencode/plugins/session-enforcement.ts` returns no matches | Remove sub-agent tracking code | implementation | .opencode/plugins/session-enforcement.ts | Problem: sub-agent tracking in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-9 | Session triggers removed | `grep -r "runSessionContextTriggers\|session_context_triggers\|SESSION_TRIGGERS" .opencode/plugins/session-enforcement.ts` returns no matches | Remove session triggers code | implementation | .opencode/plugins/session-enforcement.ts | Problem: session triggers in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-10 | Plugin diagnostics removed | `grep -r "writeDiagnostic\|collectDiagnostics\|buildDiagnosticBlock\|DIAGNOSTICS_PATH" .opencode/plugins/session-enforcement.ts` returns no matches | Remove diagnostics code | implementation | .opencode/plugins/session-enforcement.ts | Problem: plugin diagnostics in HEAD | single | pre-commit | standalone | core-removal | implementation | N/A | single |
| SC-11 | Session-init injection preserved | `grep -r "runSessionInit\|session-init" .opencode/plugins/session-enforcement.ts` returns matches for session-init call | Restore if missing | implementation | .opencode/plugins/session-enforcement.ts | Goal: keep session-init injection | single | pre-commit | standalone | core-preserve | implementation | N/A | single |
| SC-12 | Mode-switch stripping preserved | `grep -r "isModeSwitchSynthetic\|mode-switch\|Plan Mode" .opencode/plugins/session-enforcement.ts` returns matches | Restore if missing | implementation | .opencode/plugins/session-enforcement.ts | Goal: keep mode-switch stripping | single | pre-commit | standalone | core-preserve | implementation | N/A | single |
| SC-13 | Named export maintained | `grep -r "export const SessionEnforcementPlugin" .opencode/plugins/session-enforcement.ts` returns match | Fix export if missing | implementation | .opencode/plugins/session-enforcement.ts | Requirement: named export for OpenCode | single | pre-commit | standalone | core-preserve | implementation | N/A | single |
| SC-14 | No new dependencies added | `grep -r "import\|require" .opencode/plugins/session-enforcement.ts` only shows @opencode-ai/plugin and child_process | Remove any new imports | implementation | .opencode/plugins/session-enforcement.ts | Constraint: no new deps | single | pre-commit | standalone | core-preserve | implementation | N/A | single |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [.opencode#1972](https://github.com/michael-conrad/.opencode/issues/1972) | RELATED | Plugin git path fixes that may overlap with this cleanup |
| [.opencode#1960](https://github.com/michael-conrad/.opencode/issues/1960) | RELATED | Plugin skills hooks work that modified session-enforcement.ts |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use working directory minimal rewrite as baseline | Already implemented and tested | MUST | All |
| DEC-2 | Delegate secret redaction to opencode-vibeguard | npm plugin exists for this purpose | MUST | SC-4 |
| DEC-3 | Keep execSync for session-init only | Required for session context injection | MUST | SC-11 |
| DEC-4 | Remove all git CLI calls from plugin | Reduces attack surface and latency | MUST | SC-2 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Session context injection breaks | Low | High | Working directory version already tested | SC-11 |
| RISK-2 | Mode-switch stripping breaks | Low | Medium | Working directory version already tested | SC-12 |
| RISK-3 | Secret redaction gap | Low | High | opencode-vibeguard handles this | SC-4 |
| RISK-4 | Git config watchdog gap | Low | Medium | Pre-commit hooks enforce config policies | SC-1 |

## Regression Invariants

- [ ] 1. Existing session-init output format MUST remain unchanged
- [ ] 2. Plugin named export MUST remain `SessionEnforcementPlugin`
- [ ] 3. Hook signatures MUST remain `experimental.chat.system.transform` and `experimental.chat.messages.transform`
- [ ] 4. Plugin MUST NOT introduce new runtime dependencies

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Local docs | `.opencode/plugins/AGENTS.md` | Plugin development guide |
| Direct source search | `git show HEAD:plugins/session-enforcement.ts` | Verify HEAD features |
| Direct source search | `cat plugins/session-enforcement.ts` | Verify working dir minimal rewrite |
| Direct source search | `cat .opencode/tools/session-init` | Verify session-init git calls |
| Live verification | `cd .opencode && npm test` | Confirm tests pass with minimal rewrite |

## Implementation Approach

For the reader's understanding, not prescribing HOW:

The implementation applies the working directory minimal rewrite as the official version. The change is a single commit replacing the ~1,100 line HEAD version with the ~74 line minimal version. No new code is written — only removal of out-of-scope features.

## Risk and Edge Cases

| Risk | Mitigation |
|------|------------|
| Session context injection fails | Working directory version verified; rollback plan documented |
| Mode-switch stripping fails | Working directory version verified; rollback plan documented |
| Secret redaction regression | opencode-vibeguard npm plugin handles this independently |
| Git config policy enforcement gap | Pre-commit hooks already enforce Tier 1 mandates |

## Spec Family Annotation

family: plugin-minimalism
selectors:
  - spec: .opencode#1972
  - spec: .opencode#1960

## Explicit Non-Goals

- Internationalization — Out of scope for this spec
- Backward compatibility with removed features — Breaking changes accepted per minimalism goal
- Adding new enforcement features — This spec only removes features

## Plan Creation Mandate

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1975/plan.md` before implementation begins.

## Cross-Cutting SCs

**Cross-Cutting SCs:** SC-11, SC-12, SC-13, SC-14
— Verified once in Phase 1, applies to all subsequent phases.

## Post-SC Uplift Check

All SCs have been classified per the Evidence Type Classification Gate. SC-11 through SC-14 are behavioral (runtime behavior change), SC-1 through SC-10 are structural (code removal verified by grep). No misclassifications detected.

## Evidence Artifact Verification

| Check | Verification Action | Tool Call | Result | Classification | Action |
|-------|---------------------|-----------|--------|----------------|--------|
| No placeholders remain | Verify spec body contains no TBD, TODO, FIXME | grep -r "TBD\|TODO\|FIXME" spec.md | PASS | STRUCTURE-VIOLATION | auto-fix |
| Internal consistency | Cross-reference requirement IDs between sections | Manual review | PASS | CONFLICTING | FAIL |
| Scope check | Verify scope is appropriate for single plan | Review affected files | PASS | VERIFICATION-GAP | FAIL |
| Ambiguity resolved | Verify no vague terms | grep -r "should\|etc\.\|fast\|user-friendly" spec.md | PASS | STRUCTURE-VIOLATION | auto-fix |

## SC Coverage YAML

```yaml
sc_coverage:
  total: 14
  single_task: true
  spec_url: https://github.com/michael-conrad/.opencode/tree/issues-data/1975/
  evidence_types:
    - behavioral
    - string
    - structural
  phases:
    - id: single
      sc_ids: [SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14]
      evidence_types: [string, behavioral]
  cross_cutting:
    sc_ids: [SC-11, SC-12, SC-13, SC-14]
    verified_in_phase: single
  scs:
    - id: SC-1
      description: "Git config watchdog completely removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-2
      description: "No direct git CLI calls"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-3
      description: "Git hook installation logic removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-4
      description: "Secret redaction code removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-5
      description: "Guidelines index injection removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-6
      description: "Skill index injection removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-7
      description: "Frontmatter validation removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-8
      description: "Sub-agent tracking removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-9
      description: "Session triggers removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-10
      description: "Plugin diagnostics removed"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-11
      description: "Session-init injection preserved"
      evidence_type: behavioral
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-12
      description: "Mode-switch stripping preserved"
      evidence_type: behavioral
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-13
      description: "Named export maintained"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
    - id: SC-14
      description: "No new dependencies added"
      evidence_type: string
      verification_gate: pre-commit
      plan_phase: single
```

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)