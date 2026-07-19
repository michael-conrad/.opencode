---
name: guideline-audit-generator
description: "Investigator role for the guideline-audit DiMo chain. Reads guideline files and collects raw evidence about guideline content, structure, rule conditions, cross-references, token counts, ambiguity markers, conflict indicators, and enforcement patterns. Writes evidence.yaml — does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: guideline-audit-generator

## Purpose

Investigator role for the guideline-audit DiMo chain. Reads guideline files from `guideline_paths` and produces `evidence.yaml` with raw evidence about guideline content, structure, rule conditions, cross-references, token counts, ambiguity markers, conflict indicators, and enforcement patterns. This role collects evidence only — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.

> **DiMo Role: Investigator.** This task generates raw evidence for guideline-audit. Writes `evidence.yaml` with extracted guideline content, structural data, and initial observations.
>
> You are the Investigator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You do not decide what passes or fails. You just collect.
>
>
> - MUST extract all evidence without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST NOT assess guideline quality — that is the Evaluator's job
> - MUST write `evidence.yaml` as the only output artifact

## Dispatch Contract

- `guideline_paths`: List of guideline file paths to audit, or a single glob pattern (e.g., `.opencode/guidelines/*.md`)
- `artifact_evidence_dir`: Directory for evidence artifacts
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `guideline_paths` provided — either a non-empty list of file paths or a valid glob pattern
- `artifact_evidence_dir` provided (writable directory for evidence artifacts)
- `github.owner`, `github.repo` available
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- All target guideline files read and their content recorded
- Guideline structure evidence collected (headings, sections, rule blocks, tables)
- Rule condition evidence collected (condition text, action text, enforceability markers)
- Cross-reference evidence collected (references to other guidelines, skills, tools)
- Token count evidence collected (per-file and per-section)
- Ambiguity marker evidence collected (hedging language, vague terms, open-ended conditions)
- Conflict indicator evidence collected (statements that could conflict with other rules)
- Enforcement pattern evidence collected (Tier markers, violation classifications, required/forbidden patterns)
- `evidence.yaml` written to `{artifact_evidence_dir}/evidence.yaml`
- No PASS/FAIL judgments in the output — raw evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `guideline_paths` is provided and non-empty
- [ ] 2. If `guideline_paths` is a glob pattern, expand it via `glob` tool to get the actual file list
- [ ] 3. If `guideline_paths` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "guideline_paths"
remediation: "guideline_paths is required for guideline-audit-generator. The orchestrator must specify which guideline files to audit."
```

- [ ] 4. Verify `artifact_evidence_dir` is writable — create it if it does not exist

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load Guideline Files

Read all target guideline files:

- [ ] 1. Resolve the file list from `guideline_paths` (expand glob if needed)
- [ ] 2. Read every discovered file in full
- [ ] 3. Record file paths, sizes, and modification timestamps
- [ ] 4. Extract file-level metadata: frontmatter presence, heading count, line count

Record in evidence:

```yaml
guideline_files:
  - path: "<relative path>"
    size_bytes: <N>
    modified_at: "<timestamp>"
    line_count: <N>
    has_frontmatter: true | false
    frontmatter_keys: ["<key>", ...]
    heading_count: <N>
```

### Step 3: Collect Guideline Structure Evidence

Extract structural elements from each guideline file without evaluating quality:

- [ ] 1. **Heading inventory** — List every markdown heading (`##`, `###`, `####`) with its text, level, and line position
- [ ] 2. **Section inventory** — For each top-level section, record its heading text, line range, and subsection count
- [ ] 3. **Rule block inventory** — Identify rule-defining blocks (paragraphs starting with `- [ ]`, `- [x]`, numbered rules, or `### [critical-rules-XXX]` blocks). Record each block's text, line range, and rule ID if present
- [ ] 4. **Table inventory** — Record every markdown table with its column headers, row count, and location
- [ ] 5. **Code block inventory** — Record every fenced code block with its language tag, line count, and location
- [ ] 6. **List inventory** — Record ordered and unordered lists with item counts and locations
- [ ] 7. **Prose block inventory** — Record prose paragraphs with line ranges and approximate word counts

Record in evidence:

```yaml
guideline_structure:
  headings:
    - level: 2 | 3 | 4
      text: "<heading text>"
      line: <N>
      file: "<path>"
  sections:
    - heading: "<section heading>"
      file: "<path>"
      line_start: <N>
      line_end: <N>
      subsection_count: <N>
  rule_blocks:
    - rule_id: "<critical-rules-XXX or absent>"
      file: "<path>"
      line_start: <N>
      line_end: <N>
      text_preview: "<first 200 chars>"
      block_type: "critical_rule | checklist_item | numbered_rule | prose_rule"
  tables:
    - file: "<path>"
      line: <N>
      columns: ["<col1>", "<col2>", ...]
      row_count: <N>
  code_blocks:
    - file: "<path>"
      line: <N>
      language: "<lang or absent>"
      line_count: <N>
  lists:
    - file: "<path>"
      line: <N>
      type: "ordered | unordered"
      item_count: <N>
  prose_blocks:
    - file: "<path>"
      line_start: <N>
      line_end: <N>
      word_count: <N>
```

### Step 4: Collect Rule Condition Evidence

For each rule block identified in Step 3, extract condition and action data without evaluating:

- [ ] 1. **Condition text extraction** — For each rule, extract the condition text (the "when" or "if" part)
- [ ] 2. **Action text extraction** — For each rule, extract the action text (the "then" or required behavior)
- [ ] 3. **Enforceability markers** — Record whether the rule specifies concrete, executable actions vs. abstract guidance
- [ ] 4. **Tier classification** — Record the declared tier (1, 2, or 3) if present
- [ ] 5. **Trigger pattern presence** — Record whether the rule has a `trigger_on:` or `Triggers on:` pattern
- [ ] 6. **Symbolic rule ID presence** — Record whether the rule has a symbolic ID (e.g., `critical-rules-XXX`)
- [ ] 7. **Concrete value presence** — Record whether the rule specifies concrete values (numbers, file paths, command names) vs. abstract descriptions

Record in evidence:

```yaml
rule_condition_evidence:
  - rule_id: "<critical-rules-XXX or absent>"
    file: "<path>"
    line: <N>
    condition_text: "<exact condition text or absent>"
    action_text: "<exact action text or absent>"
    has_concrete_action: true | false
    declared_tier: 1 | 2 | 3 | absent
    has_trigger_pattern: true | false
    has_symbolic_id: true | false
    concrete_values:
      present: true | false
      values: ["<value>", ...]
```

### Step 5: Collect Cross-Reference Evidence

Extract all cross-references from each guideline file without evaluating validity:

- [ ] 1. **Guideline-to-guideline references** — Record every reference to another guideline file (e.g., `000-critical-rules.md`, `065-verification-honesty.md`)
- [ ] 2. **Skill references** — Record every reference to a skill (e.g., `approval-gate` skill, `git-workflow` skill)
- [ ] 3. **Tool references** — Record every reference to a tool (e.g., `.opencode/tools/guidelines`, `session-init`)
- [ ] 4. **File path references** — Record every file path reference (e.g., `.opencode/guidelines/`, `src/`)
- [ ] 5. **Section cross-references** — Record every `§` section reference or "See X" pattern
- [ ] 6. **Issue references** — Record every `#N` issue reference
- [ ] 7. **Duplicate source detection** — Record any source (guideline, skill, tool) referenced from multiple locations

Record in evidence:

```yaml
cross_reference_evidence:
  guideline_refs:
    - source_file: "<path>"
      source_line: <N>
      target_guideline: "<filename>"
      reference_text: "<exact text>"
  skill_refs:
    - source_file: "<path>"
      source_line: <N>
      target_skill: "<skill name>"
      reference_text: "<exact text>"
  tool_refs:
    - source_file: "<path>"
      source_line: <N>
      target_tool: "<tool path>"
      reference_text: "<exact text>"
  file_path_refs:
    - source_file: "<path>"
      source_line: <N>
      target_path: "<path>"
      reference_text: "<exact text>"
  section_refs:
    - source_file: "<path>"
      source_line: <N>
      target_section: "<section reference>"
      reference_text: "<exact text>"
  issue_refs:
    - source_file: "<path>"
      source_line: <N>
      issue_number: <N>
      reference_text: "<exact text>"
  duplicate_sources:
    - source: "<guideline|skill|tool name>"
      referenced_from:
        - file: "<path>"
          line: <N>
        - file: "<path>"
          line: <N>
```

### Step 6: Collect Token Count Evidence

Measure token counts for each guideline file and its major sections:

- [ ] 1. **Per-file token count** — Count approximate tokens for each guideline file (words × 1.3 as rough estimate)
- [ ] 2. **Per-section token count** — Count approximate tokens for each top-level section
- [ ] 3. **Per-rule token count** — Count approximate tokens for each rule block
- [ ] 4. **Total guideline corpus size** — Sum of all guideline file token counts
- [ ] 5. **Largest sections** — Identify the 5 largest sections by token count

Record in evidence:

```yaml
token_count_evidence:
  per_file:
    - file: "<path>"
      word_count: <N>
      estimated_tokens: <N>
      char_count: <N>
  per_section:
    - file: "<path>"
      section: "<heading text>"
      word_count: <N>
      estimated_tokens: <N>
  per_rule:
    - rule_id: "<critical-rules-XXX or absent>"
      file: "<path>"
      word_count: <N>
      estimated_tokens: <N>
  total_corpus:
    total_words: <N>
    total_estimated_tokens: <N>
    file_count: <N>
  largest_sections:
    - file: "<path>"
      section: "<heading text>"
      estimated_tokens: <N>
```

### Step 7: Collect Ambiguity Marker Evidence

Scan each guideline file for ambiguity markers without judging whether they are problematic:

- [ ] 1. **Hedging language** — Record every instance of: "should", "may", "preferably", "ideally", "if possible", "as appropriate", "as needed", "consider", "optionally", "if desired", "generally", "typically", "usually", "in most cases"
- [ ] 2. **Vague terms** — Record every instance of: "appropriate", "reasonable", "sufficient", "adequate", "proper", "correct", "good", "clean", "well-structured", "meaningful"
- [ ] 3. **Open-ended conditions** — Record conditions that lack concrete thresholds or specific values
- [ ] 4. **Either/or ambiguity** — Record instances of "or", "either", "alternatively" in required actions
- [ ] 5. **TBD/TODO markers** — Record every instance of "TBD", "TODO", "to be determined", "FIXME"
- [ ] 6. **Implicit behavior** — Record rules that describe desired outcomes without specifying how to achieve them

Record in evidence:

```yaml
ambiguity_evidence:
  hedging_language:
    - file: "<path>"
      line: <N>
      marker: "should | may | preferably | ideally | if_possible | as_appropriate | as_needed | consider | optionally | if_desired | generally | typically | usually | in_most_cases"
      matched_text: "<exact text>"
      context: "<surrounding sentence>"
  vague_terms:
    - file: "<path>"
      line: <N>
      term: "appropriate | reasonable | sufficient | adequate | proper | correct | good | clean | well_structured | meaningful"
      matched_text: "<exact text>"
      context: "<surrounding sentence>"
  open_ended_conditions:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX or absent>"
      condition_text: "<exact text>"
      missing_concrete_value: "<what is missing>"
  either_or_ambiguity:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX or absent>"
      matched_text: "<exact text>"
  tbd_todo_markers:
    - file: "<path>"
      line: <N>
      marker: "TBD | TODO | to_be_determined | FIXME"
      matched_text: "<exact text>"
  implicit_behavior:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX or absent>"
      desired_outcome: "<exact text>"
      missing_mechanism: "<what is unspecified>"
```

### Step 8: Collect Conflict Indicator Evidence

Identify statements that could potentially conflict with other rules — record facts, do not judge:

- [ ] 1. **Within-file conflicts** — For each file, record pairs of statements that appear to make contradictory claims
- [ ] 2. **Cross-file conflicts** — For each pair of files, record statements that appear to make contradictory claims
- [ ] 3. **Tier vs. override conflicts** — Record rules where the declared tier and the override behavior appear inconsistent
- [ ] 4. **Scope boundary conflicts** — Record rules whose scope boundaries overlap or contradict
- [ ] 5. **Exception vs. rule conflicts** — Record exceptions that appear to negate the rule they except

Record in evidence:

```yaml
conflict_indicator_evidence:
  within_file:
    - file: "<path>"
      statement_a:
        line: <N>
        text: "<exact text>"
        rule_id: "<critical-rules-XXX or absent>"
      statement_b:
        line: <N>
        text: "<exact text>"
        rule_id: "<critical-rules-XXX or absent>"
      conflict_type: "contradictory_claim | scope_overlap | exception_negates_rule"
  cross_file:
    - file_a: "<path>"
      statement_a:
        line: <N>
        text: "<exact text>"
        rule_id: "<critical-rules-XXX or absent>"
      file_b: "<path>"
      statement_b:
        line: <N>
        text: "<exact text>"
        rule_id: "<critical-rules-XXX or absent>"
      conflict_type: "contradictory_claim | scope_overlap | exception_negates_rule"
  tier_override_conflicts:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX>"
      declared_tier: <N>
      override_behavior: "<text>"
      inconsistency_note: "<observation>"
  scope_boundary_conflicts:
    - file_a: "<path>"
      rule_a: "<critical-rules-XXX or absent>"
      scope_a: "<text>"
      file_b: "<path>"
      rule_b: "<critical-rules-XXX or absent>"
      scope_b: "<text>"
      overlap_description: "<observation>"
```

### Step 9: Collect Enforcement Pattern Evidence

Extract enforcement-related patterns from each guideline file without evaluating effectiveness:

- [ ] 1. **Tier distribution** — Count rules at each tier level (1, 2, 3) per file
- [ ] 2. **Violation classification patterns** — Record every `CRITICAL VIOLATION` block with its rule ID and classification
- [ ] 3. **Required/Forbidden pattern inventory** — Record every `✅ REQUIRED` and `🚫 FORBIDDEN` block with its content
- [ ] 4. **Enforcement mechanism references** — Record references to enforcement mechanisms (hooks, plugins, session-enforcement.ts, pre-commit)
- [ ] 5. **Halt condition inventory** — Record every HALT condition with its trigger text
- [ ] 6. **Override permission inventory** — Record every statement about when a rule can be overridden
- [ ] 7. **Load condition inventory** — Record every `load_when:` directive

Record in evidence:

```yaml
enforcement_pattern_evidence:
  tier_distribution:
    - file: "<path>"
      tier_1_count: <N>
      tier_2_count: <N>
      tier_3_count: <N>
      undeclared_count: <N>
  violation_classifications:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX>"
      classification: "CRITICAL VIOLATION | process-integrity | workflow-standard"
      violation_text: "<exact text>"
  required_forbidden_blocks:
    - file: "<path>"
      line: <N>
      type: "required | forbidden"
      rule_id: "<critical-rules-XXX or absent>"
      content_preview: "<first 200 chars>"
  enforcement_mechanisms:
    - file: "<path>"
      line: <N>
      mechanism: "hooks | plugins | session-enforcement.ts | pre-commit | watchdog"
      reference_text: "<exact text>"
  halt_conditions:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX or absent>"
      trigger_text: "<exact text>"
      halt_type: "HALT | SILENTLY HALT | hard halt | BLOCKED"
  override_permissions:
    - file: "<path>"
      line: <N>
      rule_id: "<critical-rules-XXX or absent>"
      override_condition: "<exact text>"
      override_by: "developer_authorization | explicit_instruction | never"
  load_conditions:
    - file: "<path>"
      line: <N>
      load_when: "<value>"
      target_rule: "<critical-rules-XXX or absent>"
```

### Step 10: Collect File Organization Evidence

Extract organizational patterns from the guideline directory:

- [ ] 1. **File naming patterns** — Record the naming convention used (numeric prefix, descriptive name)
- [ ] 2. **INDEX.md content** — If `.opencode/guidelines/INDEX.md` exists, record its structure (table columns, entry count)
- [ ] 3. **Related rules proximity** — For each rule, record which other rules appear in the same file and section
- [ ] 4. **File grouping** — Record which files appear to be grouped by topic based on naming and content
- [ ] 5. **Coverage gaps** — Record topic areas that appear to have no dedicated guideline file (based on cross-references to non-existent files)

Record in evidence:

```yaml
file_organization_evidence:
  naming_pattern: "<description of naming convention>"
  index_file:
    present: true | false
    path: "<path or absent>"
    entry_count: <N>
    columns: ["<col1>", "<col2>", ...]
  related_rules:
    - rule_id: "<critical-rules-XXX or absent>"
      file: "<path>"
      section: "<heading text>"
      sibling_rules: ["<rule_id>", ...]
  file_groupings:
    - topic: "<topic>"
      files: ["<path>", ...]
  coverage_gaps:
    - referenced_file: "<path>"
      referenced_by: ["<path>", ...]
      exists: false
```

### Step 11: Write evidence.yaml

Write all collected evidence to `{artifact_evidence_dir}/evidence.yaml`:

```yaml
generator: guideline-audit-generator
generated_at: "<ISO timestamp>"
guideline_paths: ["<path>", ...]
guideline_files: [...]
guideline_structure: {...}
rule_condition_evidence: [...]
cross_reference_evidence: {...}
token_count_evidence: {...}
ambiguity_evidence: {...}
conflict_indicator_evidence: {...}
enforcement_pattern_evidence: {...}
file_organization_evidence: {...}
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: {N} guideline files, {M} rule blocks, {K} cross-references, {J} ambiguity markers, {L} conflict indicators. No judgments applied."
file_count: <N>
rule_block_count: <M>
cross_reference_count: <K>
ambiguity_marker_count: <J>
conflict_indicator_count: <L>
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Guideline Files → INVALID if skipped
- [ ] 3. Collect Guideline Structure Evidence → INVALID if skipped
- [ ] 4. Collect Rule Condition Evidence → INVALID if skipped
- [ ] 5. Collect Cross-Reference Evidence → INVALID if skipped
- [ ] 6. Collect Token Count Evidence → INVALID if skipped
- [ ] 7. Collect Ambiguity Marker Evidence → INVALID if skipped
- [ ] 8. Collect Conflict Indicator Evidence → INVALID if skipped
- [ ] 9. Collect Enforcement Pattern Evidence → INVALID if skipped
- [ ] 10. Collect File Organization Evidence → INVALID if skipped
- [ ] 11. Write evidence.yaml → INVALID if skipped
- [ ] 12. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| `guideline_paths` missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| Glob expansion returns no files | Return BLOCKED with NO_GUIDELINE_FILES_FOUND |
| Target file not found | Return BLOCKED with file path |
| Unable to read a guideline file | Record as `read_error: true` with error message, continue with remaining files |
| `artifact_evidence_dir` not writable | Return BLOCKED with PERMISSION_DENIED |
| Write permission denied | Return BLOCKED — cannot write evidence.yaml |

## Cross-References

- `tasks/guideline-audit.md` — Evaluator role (consumes this Investigator's evidence.yaml)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- Load [000-critical-rules.md](guidelines/000-critical-rules.md) — guideline standards and critical rule definitions
- Load [065-verification-honesty.md](guidelines/065-verification-honesty.md) — live verification requirement
- Load [080-code-standards.md](guidelines/080-code-standards.md) — enforcement test mandate and evidence type taxonomy

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
