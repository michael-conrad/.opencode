---
id: 582
title: "Contract Format Standardization — YAML for All LLM-Consumed Content"
status: DRAFT
author: michael-conrad
created: 2026-05-15
updated: 2026-07-11
license: MIT
provenance: AI-generated
interdependent:
  - .opencode#1208 (Skillcard routing overhaul — sequencing: #582 must run AFTER #1208 Workstream A)
  - .opencode#1222 (Enforcement-Gated Contract Schema — shared YAML contract format concern)
  - .opencode#936 (Deterministic consensus gate — SC-8 requires YAML result contract)
supersedes:
  - .opencode#1420 (closed — YAML mandate rule; #582 is the implementation)
---

# SPEC: Contract Format Standardization — YAML for All LLM-Consumed Content

## Problem

`.opencode/` contains a systemic mix of ` ```json ` code fences, prose-embedded JSON templates, and references to "structured JSON verdicts" across skill task files, SKILL.md files, agent cards, and related documentation. The principle was already established — anything the LLM reads, parses, or is instructed to generate should be YAML — but was never audited or remediated.

This is a correctness issue, not a style preference. Independent benchmarks (improvingagents.com, 2025) show YAML delivers 11–18 percentage points better comprehension accuracy over JSON for nested data presented to LLMs, with ~30% fewer tokens. This aligns with opencode.ai's own design language: SKILL.md uses YAML frontmatter, agent cards use YAML frontmatter, `opencode.json` is JSON only because it's machine-level configuration.

The YAML mandate was codified in `080-code-standards.md` §YAML Standard for LLM-to-LLM Data Transfers (issue #1420, closed). This spec is the comprehensive implementation of that rule.

## Current State

As of 2026-07-11, the codebase has:
- **18 files** with ` ```json ` blocks remaining (down from ~25+ originally)
- **88 files** already using ` ```yaml ` blocks
- **0 guideline files** with ` ```json ` blocks (already clean)
- No branch or PR exists for this issue

## Principle

**YAML for everything an LLM reads, parses, or is instructed to generate. JSON only for tool-to-tool file I/O, CLI output, and external tool configuration.**

## Contract Format Specification

| Element | Format | Example |
|---|---|---|
| Outer boundary | ` ```yaml ` code fence | ` ```yaml ` |
| Multi-record inside a single fence | `---` separator between records | `---\nstatus: PASS\n---\nstatus: FAIL` |
| Prose contract description | YAML-style, not JSON brace syntax | `status: DONE, evidence: path to file` |
| Existing yaml+symbolic blocks | Unchanged | ` ```yaml+symbolic ` |
| Tool I/O, CLI output, file persistence | JSON (unchanged) | excluded from migration |

## Scope

Every owned file in `.opencode/` — skill task files (`tasks/*.md`), SKILL.md files, agent cards (`agents/auditor-*.md`), guidelines, prompts, and any other file containing LLM-consumed structured content — must be checked and remediated where JSON is used as an instruction template, output template, or contract format.

### Excluded

- Tool I/O files written to disk by one tool and read by another (coherence baselines, capability snapshots, provenance logs)
- External CLI output formats (gitbucket-api)
- Script `--json` flags for programmatic consumption
- `yaml+symbolic` rule blocks (already YAML)
- Vendor dependencies (`.node/`, `node_modules/`, `.tools/`)

## Files Affected

The scope is systemic — the implementing agent must discover all affected files autonomously. Known categories include but are not limited to:

- Skill task files with ` ```json ` result contract templates (18 files identified: verification, research, multimodal-dispatch, TDD, issue-operations, git-workflow, playwright-cli)
- Agent cards with ` ```json ` clean-room output blocks (7 auditor-*.md files)
- Task files with prose instructions telling a sub-agent to "return a JSON with..."
- SKILL.md overviews referencing "structured JSON verdicts" or similar language
- Any guideline or rule referencing JSON in the context of LLM-consumed output
- `.opencode/README.md`

The implementing agent searches for and determines on a file-by-file basis what needs updating.

## Interdependencies

| Issue | Relationship | Action Required |
|---|---|---|
| `.opencode#1208` | **Sequencing dependency** — #1208 Workstream A modifies YAML frontmatter in all 39 SKILL.md files. #582 converts ` ```json `→` ```yaml ` in the same files. | #582 MUST run AFTER #1208 Workstream A to avoid merge conflicts. Mark this dependency in both issues. |
| `.opencode#1222` | **Shared concern** — #1222 defines standardized YAML contract schema. #582 ensures all ` ```json ` blocks are converted. | #582's migrated YAML blocks should conform to #1222's schema where applicable. No sequencing dependency. |
| `.opencode#936` | **Shared concern** — SC-8 requires cross-validate to return YAML result contract. #582 handles this conversion. | #582's Phase 1 covers the cross-validate.md conversion. No sequencing dependency. |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | Every ` ```json ` code fence that serves as an LLM-consumed contract template has been converted to ` ```yaml ` with semantically equivalent YAML content. | `string + behavioral` | Full content scan — zero ` ```json ` blocks in owned `.opencode/` files outside the excluded categories. Behavioral: run `rg '```json' .opencode/ --include '*.md'` and confirm count is 0 for non-excluded files. |
| SC-2 | Every prose-embedded contract instruction (e.g., "Return a JSON with fields: status, evidence..." or "Result: { status, files_changed }") has been converted to YAML prose. | `string + semantic` | Read-through audit — zero prose instructions telling an LLM to produce JSON output. Semantic: sub-agent reads sampled files and confirms no JSON-output instructions remain. |
| SC-3 | Every SKILL.md overview, guideline reference, or rule that references "JSON verdicts" or "structured JSON" has been updated to "YAML verdicts" or "structured YAML" where the referenced output is LLM-consumed. | `string` | `grep` — zero "JSON verdict" or "structured JSON" in owned files. |
| SC-4 | All 7 auditor agent cards have clean-room output blocks in ` ```yaml `. | `string` | Read each `auditor-*.md` — zero ` ```json ` in output instructions. |
| SC-5 | Multi-record verdicts use `---` separators inside a single ` ```yaml ` fence, not separate fences per record. | `string + semantic` | Sampled audit — adversarial-audit task files show `---` inside a single fence for multi-record examples. |
| SC-6 | Excluded files (tool I/O, CLI output, script flags) remain unchanged. | `structural` | Diff check — no changes to coherence-extraction.md baseline structure, probe.md CapabilitySnapshot, gitbucket-api references, provenance log records, `validate_skill_cards.py --json` references. |
| SC-7 | All migrated ` ```yaml ` blocks contain semantically equivalent data to the original ` ```json `. No fields lost, values changed, or structural information dropped. | `semantic` | Representative sample comparison — cross-validate.md, verify.md, TDD phase-4.md, one auditor card: YAML matches JSON original field-for-field. Sub-agent reads both versions and confirms equivalence. |
| SC-8 | All existing enforcement tests and behavioral tests pass after migration. | `behavioral` | `bash .opencode/tests/test-enforcement.sh && bash .opencode/tests/behaviors/run-all.sh` — zero failures. |
| SC-9 | **Zero-tolerance for lobotomized tests.** No SC may be removed, weakened, deferred, or blocked to evade implementation. Any attempt to bypass an SC (skip, defer, mark as "blocked", weaken evidence type) marks ALL SCs as FAIL. The PR must be immediately rejected and trashed as defective and unusable. | `behavioral` | Clean-room audit of implementation verifies all 8 SCs (SC-1 through SC-8) are addressed with full behavioral/string/semantic evidence. Any missing or weakened SC → ALL SCs FAIL. |
| SC-10 | All SCs must achieve 100% clean PASS. No "PASS with caveats", "functionally equivalent", "PASS with concerns", or any partial-PASS verdict is accepted. A single FAIL on any SC means the entire implementation is rejected. | `behavioral` | Post-implementation audit produces binary PASS/FAIL per SC. Any FAIL → full rejection. |

## Phases

### Phase 1: Code-Fenced JSON → YAML

Every ` ```json ` block that is an LLM-consumed contract template. One-to-one fence type replacement plus structural migration from JSON syntax to YAML syntax — braces and commas become indentation, quoted keys become unquoted, trailing commas removed, array brackets become dash lists.

**Files (18 identified):** verification tasks (verify, verify-single), research tasks (research), multimodal-dispatch tasks (dispatch, dispatch-multi, resolve, probe), TDD tasks (red, green, refactor, phase-0, phase-4), issue-operations tasks (body-edit, platforms/local/body-edit, platforms/local/tag-gate), git-workflow tasks (provenance/trunk-push-provenance), playwright-cli references (storage-state), 7 auditor agent cards, README.md.

### Phase 2: Prose-Embedded JSON Instructions

Every inline instruction in task files telling a sub-agent to format output as JSON. These are prose patterns like "Return a JSON object with fields: status, evidence..." or inline `{status, evidence, files_changed}` notation used as templates. Convert to equivalent YAML prose: "Return status, evidence, files_changed fields in YAML format."

**Concern:** These are scattered across many task files and require reading comprehension to distinguish "describing JSON output of an external tool" from "instructing an LLM to produce JSON."

### Phase 3: Rule and Reference Updates

SKILL.md files and guidelines that reference "JSON" in the context of contract output. For example, adversarial-audit/SKILL.md says "collects structured JSON verdicts" — this is a rule an LLM reads that tells it what format to produce.

**Files:** adversarial-audit/SKILL.md (overview, symbolic rules), any guideline mentioning JSON verdict format.

### Phase 4: Verification Pass

- Run content-verification tests: `bash .opencode/tests/test-enforcement.sh`
- Run behavioral tests: `bash .opencode/tests/behaviors/run-all.sh`
- Spot-check representative sample: verify excluded files untouched, verify migrated blocks semantically equivalent
- Run clean-room audit to verify all SCs (SC-1 through SC-10) pass with 100% clean PASS
- Close the issue only when all SCs pass

## Edge Cases

- **Multi-record verdict examples** — auditor returning N criterion evaluations. Use `---` separators inside a single ` ```yaml ` fence to keep them in one block without losing individual record boundaries.
- **Mixed JSON/YAML in a single file** — some files may contain both LLM-consumed JSON (migrate) and tool-I/O JSON (exclude). The implementing agent must distinguish per block.
- **` ```jsonc ` blocks** (opencode.json config examples) — excluded; they illustrate JSON config files, not LLM contracts.
- **yaml+symbolic rule titles referencing JSON** — update the rule title text to say "YAML" but leave the `yaml+symbolic` block structure and schema unchanged.
- **Prose describing a tool's JSON output** — left as-is; the prose is documenting a CLI tool, not instructing an LLM to produce JSON.
- **Ambiguous prose contracts** — patterns like `Result: { status: DONE, evidence: "..." }` are JSON-adjacent (braces, commas) but use YAML-style `key: value`. Resolve to unambiguous YAML: `status: DONE\nevidence: "..."`.
- **#1208 sequencing** — if #1208 Workstream A has not been completed, the implementing agent MUST NOT modify SKILL.md files that #1208 will touch. Coordinate with #1208's implementation first.

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| JSON→YAML conversion loses structural information in edge cases | Low | Medium | SC-7 requires post-migration spot-check on representative files |
| Excluded files accidentally modified | Low | Medium | SC-6 verification; implementing agent checks file contents before modifying |
| Prose-embedded JSON ambiguous with tool-describing JSON | Medium | Low | Phase 2 requires reading comprehension — the implementing agent reads context before converting |
| Enforcement test references to "JSON" updated but test expects old text | Medium | Medium | SC-8 requires running full enforcement suite post-migration; failing tests indicate missed references |
| Multi-record YAML inside ` ```yaml ` with `---` separators confuses LLM parsing | Low | Low | This is the same multi-doc YAML pattern used by the YAML spec itself; well-established |
| Merge conflict with #1208 on SKILL.md files | Medium | High | Sequencing dependency: #582 must run AFTER #1208 Workstream A. Marked in both issues. |
| SC lobotomization (weakening SCs to pass) | Low | Critical | SC-9 explicitly prohibits this. Any attempt marks ALL SCs as FAIL and rejects the PR. |

## Change Control

- Single-PR boundary. All phases ship together — partial delivery leaves a worse state than the current mixed format.
- Spec revision only: content or edge case clarification. SC definitions and the core principle (YAML for LLM-consumed content) are frozen.
- Post-implementation: run `audit --task spec-audit` against this spec to verify spec fidelity.
- SC-9 and SC-10 are non-waivable. No authorization, scope, or developer instruction can override them.
- Sequencing dependency on `.opencode#1208`: this issue MUST NOT be implemented until #1208 Workstream A is complete.

## References

- `080-code-standards.md` §YAML Standard for LLM-to-LLM Data Transfers — the mandate this spec implements
- `.opencode#1420` (closed) — original issue that added the YAML mandate rule
- `.opencode#1208` — Skillcard routing overhaul (sequencing dependency)
- `.opencode#1222` — Enforcement-Gated Contract Schema (shared YAML contract format concern)
- `.opencode#936` — Deterministic consensus gate (SC-8 requires YAML result contract)
- improvingagents.com (2025) — YAML vs JSON comprehension benchmarks for LLMs
