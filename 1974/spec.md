---
title: Add secret redaction plugin (opencode-vibeguard) for mandatory secret redaction
status: complete
created: 2026-07-16
license: MIT
provenance: AI-generated
issue: 1974
authors:
  - OpenCode (opencode/nemotron-3-ultra-free)
---

**STATUS:** COMPLETE
**CREATED:** 2026-07-16

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The previous `session-enforcement.ts` had a home-grown `redactSecrets()` function with only 4 regex patterns (TOKEN=, KEY=, SECRET=, PASSWORD=) that has since been removed. This is insufficient for mandatory secret redaction across all LLM requests and tool outputs. A robust, configurable solution is required.

**Root Cause Analysis:** The prior `redactSecrets()` implementation in `session-enforcement.ts` used a hardcoded set of 4 regex patterns that only matched simple `KEY=value` patterns. It did not cover:
- API keys with specific formats (OpenAI `sk-...`, GitHub `ghp_...`, AWS `AKIA...`)
- PII data (emails, phone numbers, IDs, UUIDs, IPv4, MAC addresses)
- Configurable pattern extensibility
- Historical redaction of tool outputs in conversation history
- Streaming edge case handling (placeholder briefly visible during text-delta)

The home-grown solution was a minimal stopgap that could not scale to comprehensive secret protection requirements.

## Goals

- Install `opencode-vibeguard@0.1.0` npm plugin (150★, MIT license) via `opencode.jsonc` plugins array
- Configure `vibeguard.config.json` in `.opencode/` directory (self-contained, versioned with project)
- Remove home-grown `redactSecrets()` function from `session-enforcement.ts`
- Keep mode-switch stripping in `session-enforcement.ts` (separate concern, mandatory)
- Achieve three-layer secret protection: pre-request redaction, pre-tool restoration, historical redaction

## Non-Goals

- Modifying opencode core (plugin is external npm package)
- Changing vibeguard's internal behavior (config-driven)
- Other secret management approaches (e.g., HashiCorp Vault, AWS Secrets Manager)
- Modifying the plugin's source code

## Constraints and Scope

**In Scope:**
- Install `opencode-vibeguard@0.1.0` npm plugin via `opencode.jsonc`
- Configure `vibeguard.config.json` in `.opencode/` directory
- Remove `redactSecrets()` from `session-enforcement.ts`
- Preserve mode-switch stripping logic in `session-enforcement.ts`

**Out of Scope:**
- Modifying opencode core
- Changing vibeguard's internal behavior
- Other secret management approaches

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Extend home-grown `redactSecrets()` with more patterns | Maintenance burden; no streaming support; no historical redaction; no pre-tool restoration |
| Use `@ai-sdk` middleware for redaction | Only covers LLM requests; no tool output redaction; no historical redaction |
| HashiCorp Vault integration | Overkill for secret redaction in LLM context; external dependency; complex setup |
| AWS Secrets Manager | Cloud-specific; not designed for real-time LLM stream redaction |

## Safety Considerations

**Rollback Plan:** If plugin causes issues:
1. Remove `"opencode-vibeguard@0.1.0"` from `opencode.jsonc` plugins array
2. Restore `redactSecrets()` function in `session-enforcement.ts` from git history
3. Delete `.opencode/vibeguard.config.json`

**Safeguards:**
- Plugin pinned to exact version `0.1.0`
- Configuration self-contained in `.opencode/`
- Plugin becomes no-op if config file missing or `enabled=false` (per plugin docs)
- Debug logging available via `OPENCODE_VIBEGUARD_DEBUG=1` or config `debug: true` (does not print plaintext secrets)

## Evidence/Provenance

Every factual claim in this spec is backed by a tool-call artifact:

| Claim | Source Category | Tool Call / Evidence |
|-------|----------------|---------------------|
| Prior `session-enforcement.ts` had `redactSecrets()` with 4 patterns (now removed) | Direct source search | `git log -p -- .opencode/plugins/session-enforcement.ts` shows `redactSecrets()` was removed in prior commit |
| `opencode-vibeguard@0.1.0` exists on npm, MIT license, 150★ | Documentation URLs | Verified via GitHub repo `inkdust2021/opencode-vibeguard` - 150 stars, MIT license |
| Plugin provides three-layer protection (pre-request, pre-tool, historical) | Direct source search | README: "Pre-request redaction", "Pre-tool restoration", "Historical redaction" |
| Configuration in `vibeguard.config.json` with regex, keywords, builtin PII | Direct source search | `vibeguard.config.json.example` shows `patterns.keywords`, `patterns.regex`, `patterns.builtin` |
| Installation via `opencode.jsonc` plugins array | Documentation URLs | README: `"plugin": ["opencode-vibeguard@0.1.0"]` |
| opencode auto-installs npm plugins via Bun at startup | Documentation URLs | README: "OpenCode will auto-install it on first use", "cached in `~/.cache/opencode/node_modules/`" |
| Streaming placeholder briefly appears but sanitized | Documentation URLs | README Known limitations: "During streaming (text-delta) the placeholder may briefly appear; it will be restored at text-end" |
| Plugin becomes no-op if config missing or `enabled=false` | Documentation URLs | README Safety note: "the plugin becomes a no-op if the config file is missing or enabled=false" |

## SC-to-Root-Cause Traceability Table

| SC ID | Root Cause Element |
|-------|-------------------|
| SC-1 | Home-grown `redactSecrets()` only has 4 hardcoded patterns |
| SC-2 | No plugin-based secret redaction infrastructure |
| SC-3 | Mode-switch stripping at risk of collateral removal |
| SC-4 | No config-driven secret redaction patterns |
| SC-5 | No pre-request redaction for LLM requests |
| SC-6 | No pre-tool restoration for tool execution |
| SC-7 | No PII detection (email, phone, ID, UUID, IP, MAC) |
| SC-8 | No streaming edge case handling (placeholder visible during text-delta) |
| SC-9 | No regex patterns for API key formats (OpenAI sk-, GitHub ghp_, AWS AKIA) |
| SC-10 | No builtin PII detectors for common PII formats |
| SC-11 | No keyword-based pattern matching for custom secrets |
| SC-12 | No behavioral enforcement tests to verify plugin behavior |
| SC-13 | Risk of SC weakening or reclassification to evade implementation |

## Feasibility Assessment

All referenced files and artifacts exist:
- `.opencode/plugins/session-enforcement.ts` — exists, will be modified
- `.opencode/opencode.jsonc` — exists, will be modified
- `.opencode/vibeguard.config.json` — will be created
- `opencode-vibeguard@0.1.0` npm package — verified exists
- Bun runtime — available in environment

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|---------------|-------------------------|---------------|------------------|------------------|----------------|--------------|-----------|---------------|
| SC-1 | Home-grown `redactSecrets()` confirmed removed from `session-enforcement.ts` (already removed by PR #1976) | structural | `grep -c redactSecrets .opencode/plugins/session-enforcement.ts` → 0 | Pre-satisfied by PR #1976 — verification only, no implementation needed | pre-commit | .issues/1974/artifacts/redact-removed.log | Root cause: home-grown function | Phase 1 | pre-commit | sequential | redaction-removal | pre-work | .opencode/tests-v2/behaviors/secret-redaction/SC-1.sh | Phase 1 |
| SC-2 | `opencode-vibeguard@0.1.0` installed via `opencode.jsonc` plugins array | structural | `grep -c "opencode-vibeguard@0.1.0" .opencode/opencode.jsonc` → 1 | Add to plugins array | pre-commit | .issues/1974/artifacts/config-valid.log | Install plugin | Phase 1 | pre-commit | sequential | plugin-install | pre-work | .opencode/tests-v2/behaviors/secret-redaction/SC-2.sh | Phase 1 |
| SC-3 | Mode-switch stripping preserved in `session-enforcement.ts` | structural | `grep -c "isModeSwitchSynthetic" .opencode/plugins/session-enforcement.ts` → ≥1 | Restore from git | RED | .issues/1974/artifacts/mode-switch-preserved.log | Separate concern, mandatory | Phase 1 | red-green | sequential | mode-switch | RED | .opencode/tests-v2/behaviors/secret-redaction/SC-3.sh | Phase 1 |
| SC-4 | `vibeguard.config.json` created in `.opencode/` with regex patterns | structural | `cat .opencode/vibeguard.config.json | jq '.patterns.regex | length'` → ≥3 | Create config file | RED | .issues/1974/artifacts/regex-patterns.log | Config-driven patterns | Phase 1 | red-green | sequential | config-patterns | RED | .opencode/tests-v2/behaviors/secret-redaction/SC-4.sh | Phase 1 |
| SC-5 | Pre-request redaction: secrets redacted before LLM requests | behavioral | `behavior_run` with real-domain prompt in isolated test home; clean-room sub-agent evaluates artifacts for redaction evidence | Debug plugin | GREEN | .issues/1974/artifacts/pre-request.log | Three-layer protection | Phase 1 | red-green | sequential | pre-request | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-5.sh | Phase 1 |
| SC-6 | Pre-tool restoration: placeholders restored before tool execution | behavioral | `behavior_run` with real-domain prompt in isolated test home; clean-room sub-agent evaluates artifacts for restoration evidence | Debug plugin | GREEN | .issues/1974/artifacts/pre-tool.log | Three-layer protection | Phase 1 | red-green | sequential | pre-tool | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-6.sh | Phase 1 |
| SC-7 | Historical redaction: tool outputs redacted in conversation history | behavioral | `behavior_run` with real-domain prompt in isolated test home; clean-room sub-agent evaluates artifacts for historical redaction evidence | Debug plugin | GREEN | .issues/1974/artifacts/historical.log | Three-layer protection | Phase 1 | red-green | sequential | historical | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-7.sh | Phase 1 |
| SC-8 | Streaming edge case handled: placeholder briefly visible but sanitized at text-end | behavioral | `behavior_run` with real-domain prompt in isolated test home; clean-room sub-agent evaluates artifacts for streaming edge case handling | Debug plugin | GREEN | .issues/1974/artifacts/streaming.log | Streaming handling | Phase 1 | red-green | sequential | streaming | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-8.sh | Phase 1 |
| SC-9 | Config supports regex patterns for API keys (OpenAI, GitHub, AWS) | structural | `cat .opencode/vibeguard.config.json | jq '.patterns.regex[] | select(.pattern | test("sk-|ghp|AKIA"))' | wc -l` → ≥3 | Update config | GREEN | .issues/1974/artifacts/regex-patterns.log | Config patterns | Phase 1 | red-green | sequential | regex-patterns | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-9.sh | Phase 1 |
| SC-10 | Config supports builtin PII detectors (email, phone, ID, UUID, IP, MAC) | structural | `cat .opencode/vibeguard.config.json | jq '.patterns.builtin[]' | wc -l` → ≥6 | Update config | GREEN | .issues/1974/artifacts/builtin-pii.log | Config patterns | Phase 1 | red-green | sequential | builtin-pii | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-10.sh | Phase 1 |
| SC-11 | Config supports keyword patterns for custom secrets | structural | `cat .opencode/vibeguard.config.json | jq '.patterns.keywords | length'` → ≥1 | Update config | GREEN | .issues/1974/artifacts/keywords.log | Config patterns | Phase 1 | red-green | sequential | keywords | GREEN | .opencode/tests-v2/behaviors/secret-redaction/SC-11.sh | Phase 1 |
| SC-12 | Behavioral enforcement tests written and pass (RED→GREEN cycle) | structural | `bash .opencode/tests-v2/behaviors/secret-redaction/run.sh` → exit 0 | Write tests | post-implementation | .issues/1974/artifacts/test-pass.log | Test Integrity Mandate | Phase 1 | post-implementation | sequential | behavioral-tests | verification-before-completion | .opencode/tests-v2/behaviors/secret-redaction/run.sh | Phase 1 |
| SC-13 | No SC weakened, deferred, or reclassified to lower evidence type | structural | Audit of all SC evidence types against spec declarations — verify no behavioral SC downgraded to structural/string | Fix evidence types | post-implementation | .issues/1974/artifacts/evidence-type.log | Test Integrity Mandate | Phase 1 | post-implementation | sequential | anti-lobotomization | verification-before-completion | .opencode/tests-v2/behaviors/secret-redaction/SC-13.sh | Phase 1 |

**Behavioral test assertions for rule-changing SCs:** Success criteria that change agent behavior (guideline rules, skill enforcement, critical violations) MUST include a behavioral test assertion describing the RED state (agent behavior without the rule) and GREEN state (agent behavior with the rule), not just a content-verification grep command. Content-verification commands are SECONDARY for rule-changing SCs; behavioral assertions are PRIMARY.

**Semantic intent field:** Each success criterion includes a brief prose annotation explaining WHY the exact criterion value matters and what semantic distinction it represents.

**Cost-frame mandate in SCs:** Each success criterion carries a short cost-frame reformation statement: a skipped runtime equals a defect undiscovered. The death spiral / break dynamics are formalized in the Verification Honesty guideline — behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Plugin compatibility with opencode version | Medium | High | Pin to 0.1.0, test in isolation |
| Streaming placeholder visibility | Low | Medium | vibeguard handles this; brief flash acceptable per docs |
| Config maintenance | Low | Low | Self-contained in .opencode/, versioned with project |

**Edge Cases:**
- Streaming text-delta: placeholder may briefly appear but sanitized at text-end
- Missing config file: plugin becomes no-op (safety feature)
- Debug mode enabled: logs replace counts but never plaintext secrets

## Implementation Approach

For the reader's understanding (not prescribing HOW):

1. **Pre-work:** Verify git state, create feature branch, sync submodules
2. **Config creation:** Create `.opencode/vibeguard.config.json` with regex patterns, keywords, builtin PII detectors
3. **Plugin installation:** Confirm `opencode-vibeguard@0.1.0` in `opencode.jsonc` plugins array
4. **Code removal:** Remove `redactSecrets()` function from `session-enforcement.ts`, preserve mode-switch stripping
5. **Behavioral tests:** Write RED tests that fail without the plugin, then GREEN tests that pass with it
6. **Verification:** Run verification-before-completion, finishing checklist, review-prep

After this spec is approved, invoke `writing-plans` to create `.issues/1974/plan.md` before implementation begins.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Anti-Merge Gate

Before finalizing the spec, verify that no SC conflicts with already-merged specs. Check merged PRs for related functionality. If a merged spec has SCs that conflict with this spec's SCs, flag the conflict and HALT. Do NOT proceed with conflicting SCs.

## Doc-Source-Currency Check

All documentation sources referenced in this spec are current as of 2026-07-16:
- `opencode-vibeguard` README (GitHub) — last updated 5 months ago, version 0.1.0 current
- `vibeguard.config.json.example` — current with plugin version 0.1.0
- No stale sources detected

## SC-ID Traceability Check

| SC ID | Unique | Maps to Requirement | Verification Method Defined |
|-------|--------|---------------------|----------------------------|
| SC-1 | ✅ | Home-grown removal | ✅ |
| SC-2 | ✅ | Plugin install | ✅ |
| SC-3 | ✅ | Mode-switch preserve | ✅ |
| SC-4 | ✅ | Config creation | ✅ |
| SC-5 | ✅ | Pre-request redaction | ✅ |
| SC-6 | ✅ | Pre-tool restoration | ✅ |
| SC-7 | ✅ | Historical redaction | ✅ |
| SC-8 | ✅ | Streaming edge case | ✅ |
| SC-9 | ✅ | Regex patterns | ✅ |
| SC-10 | ✅ | Builtin PII | ✅ |
| SC-11 | ✅ | Keywords | ✅ |
| SC-12 | ✅ | Behavioral tests | ✅ |
| SC-13 | ✅ | Anti-lobotomization | ✅ |

All SCs pass traceability check.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [.opencode#1960](https://github.com/michael-conrad/.opencode/issues/1960) | RELATED | Plugin skills and hooks infrastructure |
| [.opencode#1961](https://github.com/michael-conrad/.opencode/issues/1961) | RELATED | Plugin skills and hooks infrastructure |
| [.opencode#1964](https://github.com/michael-conrad/.opencode/issues/1964) | RELATED | Plugin skills and hooks infrastructure |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Local docs | `.opencode/plugins/session-enforcement.ts` (git history) | Understand existing redactSecrets() |
| Direct source search | `git show HEAD:.opencode/plugins/session-enforcement.ts` | Verify 4-pattern redactSecrets() |
| Documentation URLs | https://github.com/inkdust2021/opencode-vibeguard | Verify plugin features, config, installation |
| Documentation URLs | https://www.npmjs.com/package/opencode-vibeguard | Verify package version, license, stars |
| Live verification | `vibeguard.config.json.example` from repo | Verify config structure |

---

🤖 Co-authored with AI: OpenCode (opencode/nemotron-3-ultra-free)