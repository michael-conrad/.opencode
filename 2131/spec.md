---
remote_issue: 2131
remote_url: https://github.com/michael-conrad/.opencode/issues/2131
labels: [spec]
---

## Problem

`080-code-standards.md` is ~820 lines / ~51KB. It contains project-specific rules (parsing pipeline, ConfigurationManager) that don't apply across projects, testing procedure that belongs in the `test-driven-development` skill card, and sections duplicated in 000 (Test Integrity Mandate).

## Proposed Solution

### Generalize (project-specific → universal):

| Section | Before | After |
|---|---|---|
| Parsing Logic Changes (lines 20-25) | References `src/commons/parsing/`, `0100_ingest_xml.ipynb` | "Changes to data processing pipelines that affect extracted metadata require a full pipeline rerun" |
| Libraries & Packages (lines 60-70) | References NLTK, `ConfigurationManager`, `project-config.ini`, `210-scripting.md` | "Use domain-appropriate libraries for specialized tasks. Use project-provided abstractions for data file paths." |

### Move to skill card:

| Section | Destination |
|---|---|
| Enforcement Test Mandate (lines 418-575) | `test-driven-development` skill card |

### Remove (duplicated in 000):

| Section | Lines |
|---|---|
| Behavioral RED/GREEN as Primary Enforcement Gate | 576-606 (restates Enforcement Test Mandate) |
| Test Integrity Mandate | 608-718 (in 000) |

### Keep (universal, generalized):

- Scope, Typing, Design Principles, Modern Python, Print Statements, Linting & Tool Selection, Numbering, AI Co-Authored Attribution, Provenance Headers, Cross-Reference Standards, YAML Standard, Triple Co-Application, Parameter Naming Convention

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Parsing Logic Changes generalized (no project-specific paths) | string | grep for absence of 'src/commons/parsing' |
| SC-2 | Libraries & Packages generalized (no project-specific names) | string | grep for absence of 'ConfigurationManager' |
| SC-3 | Enforcement Test Mandate moved to test-driven-development skill card | string | grep for 'Enforcement Test Mandate' in test-driven-development/SKILL.md |
| SC-4 | Behavioral RED/GREEN section removed | string | grep for absence of 'Behavioral RED/GREEN as Primary Enforcement Gate' |
| SC-5 | Test Integrity Mandate section removed | string | grep for absence of 'Test Integrity Mandate' |
| SC-6 | All keep sections remain | string | grep for each section header |

## Implementation Plan

### Phase 1: Generalize Parsing Logic Changes and Libraries & Packages sections
### Phase 2: Move Enforcement Test Mandate to test-driven-development skill card
### Phase 3: Remove Behavioral RED/GREEN and Test Integrity Mandate sections
### Phase 4: Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/080-code-standards.md` — compacted
- `.opencode/skills/test-driven-development/SKILL.md` — receives Enforcement Test Mandate

## Risks

- **Content loss**: Removed sections must be verified to exist in 000. Mitigation: SC-4, SC-5 verify removal is safe.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the Test Integrity Mandate must remain in 000.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
