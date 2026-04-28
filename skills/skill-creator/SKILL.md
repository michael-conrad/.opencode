---
name: skill-creator
description: Use when creating a new skill, updating an existing skill, or validating skill cards. Triggers on: new skill, update skill, create skill, skill template, skill structure, SKILL.md, validate skill cards, review skills, skill card review.
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
type: technique
---

# Skill Creator

## Overview

Creating skills IS Test-Driven Development applied to process documentation. Write test cases (pressure scenarios with subagents), watch them fail (baseline behavior), write the skill (documentation), watch tests pass (agents comply), and refactor (close loopholes). If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

**Source attribution:** TDD methodology, CSO principles, rationalization resistance tables, red flags lists, skill type taxonomy, bulletproofing patterns, and anti-patterns adapted from [obra/superpowers `writing-skills`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `init` | Create new skill from template using init_skill.py | ≈200 |
| `package` | Package skill into distributable zip | ≈150 |
| `validate` | Agent-driven semantic review of all skill cards (script sensor + intelligent corrections, conflict/ambiguity detection) | ≈100 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `init` | When creating new skill from template | Skill name, output directory, github.owner, github.repo | Implementation context, agent memory | NO |
| `package` | When packaging skill into distributable zip | Skill folder path, output directory | Implementation context, agent memory | NO |
| `validate` | When agent-driven semantic review of skill cards is needed | Skill folder paths, validation scope | Implementation context, agent memory | NO |

## Invocation

- `/skill skill-creator` - Overview and skill creation process
- `/skill skill-creator --task validate` - Agent-driven semantic review of all skill cards (script sensor + intelligent corrections, conflict/ambiguity detection)
- `./.opencode/skills/skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>` - Initialize new skill
- `./.opencode/skills/skill-creator/scripts/package_skill.py <skill-folder> [output-dir]` - Package skill
- `./.opencode/skills/skill-creator/scripts/quick_validate.py <skill-folder>` - Quick single-skill frontmatter check
- `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` - Mechanical REQ-1/2/3 validation across all skills (sensor only)
- `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json` - Mechanical validation with JSON output for programmatic consumption

## Skill Type Taxonomy

| Type | Description | Follow Rigidity | Test Approach |
|------|-------------|-----------------|---------------|
| **Discipline-enforcing** | Rules followed exactly (TDD, debugging) | Follow exactly | Pressure scenarios with combined stresses |
| **Technique** | Concrete method with steps | Follow steps, adapt details | Application scenarios, edge cases |
| **Pattern** | Way of thinking about problems | Apply principles flexibly | Recognition + application scenarios |
| **Reference** | Lookup tables, API docs, command guides | Find and apply | Retrieval + application scenarios |

## Behavioral Test Plan

When creating a new skill, you MUST include a behavioral test plan described in prose:

1. **Behavior to verify** — What does the agent do differently when this skill is invoked vs skipped?
2. **Trigger** — What prompt or scenario should trigger invocation of this skill?
3. **Verification method** — How do we confirm the skill was invoked? (agent response pattern, skill output, etc.)
4. **Failure condition** — What response means the skill was NOT invoked when it should have been?

**Do NOT use a static template.** Describe the behavior in natural language. The test mechanism (opencode-cli invocation, assertion method) follows from what behavior you're verifying.

**New skill without behavioral test plan = incomplete.**

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

Applies to NEW skills AND EDITS to existing skills. No exceptions — not for "simple additions," not for "just adding a section." Write skill before testing? Delete it. Start over.

## TDD Cycle for Skills

1. **RED:** Write failing test (baseline). Run pressure scenario WITHOUT skill. Document exact behavior, rationalizations, violation triggers.
2. **GREEN:** Write minimal skill addressing those rationalizations. Run same scenarios WITH skill. Agent should comply.
3. **REFACTOR:** Close loopholes. Agent found new rationalization? Add explicit counter. Re-test until bulletproof.

### Enforcement Test Step (MANDATORY)

After creating or updating a skill, add or update the corresponding enforcement test scenario in `.opencode/tests/test-enforcement.sh`. This is not optional — it is a critical violation to modify a skill without updating its enforcement test.

**Test scenario pattern:**

```bash
# In test-enforcement.sh, add to SCENARIOS:
SCENARIOS["your-scenario-name"]="prompt message that should trigger the skill/guideline"

# Add to EXPECTED_SKILLS:
EXPECTED_SKILLS["your-scenario-name"]="expected-skill-name"
```

**Run via the XDG-isolated wrapper (never bare `opencode-cli run`):**

```bash
bash .opencode/tests/with-test-home opencode-cli run '<test message>'
```

**See `.opencode/tests/README.md` for the complete template and per-change TDD pattern.**

## CSO Checklist (Claude Search Optimization)

1. **Description field:** "Use when..." format, triggering conditions only, NO workflow summaries
2. **Keyword coverage:** Include error messages, symptoms, synonyms, tool names
3. **Descriptive naming:** Active voice, verb-first
4. **Word efficiency:** Move details to references, use cross-references
5. **Target word counts:** getting-started <150, frequently-loaded <200, other skills <500

## Anti-Patterns

| Anti-Pattern | Why Bad | Better |
|-------------|---------|--------|
| Narrative example | Too specific, not reusable | Generalized pattern |
| Multi-language dilution | Mediocre quality, maintenance burden | One excellent example |
| Code in flowcharts | Can't copy-paste | Markdown code blocks |
| Generic labels | Lack semantic meaning | Descriptive names |
| Workflow in description | Agents follow description, skip body | Triggering conditions only |

## Measurement Standard

Word count is the universal unit for skill size measurement. Use `wc -w` as the canonical measurement method.

- **Why words, not tokens:** Token counts vary by tokenizer, model, and encoding. Word counts are stable, reproducible, and model-agnostic.
- **Why words, not lines:** Line length varies by formatting conventions. A 40-line function and a 100-word function are not comparable — words measure semantic density.
- **Measurement command:** `wc -w <file>` — available on every platform, no dependencies.
- **Skill metadata:** Report size in words (e.g., `| Task | Purpose | Words |` table in SKILL.md).
- **Size targets:** getting-started <150 words, frequently-loaded <200 words, other skills <500 words.

## Context Window Hygiene

Strongly encourage sub-agents and sub-tasks for skill operations that risk consuming significant context.

- **Sub-task isolation:** Skills that perform analysis, audits, or multi-step workflows should dispatch work to sub-tasks. The main session receives a minimal result, not intermediate reasoning.
- **Why:** LLM context windows are finite. A skill that consumes 2000 words of intermediate reasoning in the main session leaves less room for subsequent work. Sub-tasks isolate that consumption.
- **Pattern:** Skill invocation spawns a sub-task → sub-task processes and produces compact result → main session receives result only.
- **When to use sub-tasks:** Any skill task producing output, any multi-file analysis, any workflow with 3+ sequential operations. Sub-agent-first dispatch is mandatory — all task dispatches go through sub-agents, no inline exceptions.

## Worktree Awareness Requirement

**All new and updated skills MUST include worktree awareness.** This is a mandatory quality gate for the `validate` task.

### Required in every skill that:

1. **Performs git operations** — Must include a "Worktree Mode" section explaining how to handle `worktree.path`
2. **Dispatches sub-agents** — Must pass `worktree.path` in the dispatch context/prompt
3. **Reads or writes files** — Must document path prefixing rules when `worktree.path` is set

### Worktree Mode Template

Every skill SKILL.md should include (adapt as appropriate for the skill's operations):

```markdown
## Worktree Mode

When `worktree.path` is set:
- ALL `bash` tool calls MUST use `workdir` parameter set to `worktree.path`
- ALL `read`/`write`/`edit`/`glob`/`grep` tool calls MUST prefix `filePath`/`path` with `worktree.path/`
- `git` commands run from the worktree directory, NOT the main repo

If `worktree.path` is NOT set, operate normally from the project root.
```

### Sub-Agent Dispatch Template

When a skill dispatches sub-agents, the prompt MUST include:

```
worktree.path: <value or 'not set'>
If worktree.path is set, all file operations and git commands MUST use it as the base directory.
```

### Validation Gate

The `validate` task provides comprehensive checks via `validate_skill_cards.py` for multi-skill reviews and conflict/ambiguity detection, while `quick_validate.py` is for single-skill quick structural checks. Validation SHOULD check for:
- Skills with `bash` or `git` operations that lack a "Worktree Mode" section
- Skills that dispatch sub-agents but don't pass `worktree.path` in context
- New or updated SKILL.md and task/*.md files containing 0-based counting patterns (`Step 0`, `Phase 0`, `Step 0.`, `Phase 0.`) outside of code blocks, code-fenced examples, or inline code references — flag as validation error requiring correction before skill can be approved

**Rationale:** Sub-agents that don't receive worktree context silently modify the main repo instead of the feature branch. This is a context window safety issue (see #741).

## Placeholder Enforcement Requirement (MANDATORY)

**All new and updated skills MUST NOT contain hardcoded identity values.** This is a mandatory quality gate for the `validate` task.

### Required in every skill that:

1. **References AI agents** — MUST use `<AgentName>` and `<ModelId>` placeholders in byline contexts, never specific agent names or model IDs
2. **References developers** — MUST use `<dev.name>` and `<dev.email>` placeholders in angle-bracket form, matching `dev.name` and `dev.email` from session init
3. **References organizations/repos** — MUST use `<github.owner>` and `<github.repo>` (or `<gitbucket.owner>` and `<gitbucket.repo>` for GitBucket contexts) placeholders in angle-bracket form, matching `github.owner` and `github.repo` from session init
4. **Contains bylines or attribution** — MUST use `🤖 <AgentName> (<ModelId>) <status-icon> <status>` format, never specific agent/model combinations

### Validation Gate

The `validate` task uses `validate_skill_cards.py` for comprehensive cross-skill placeholder checks (conflict/ambiguity detection across all skill cards) and `quick_validate.py` for single-skill quick structural checks. Validation SHOULD check for and flag:
- Specific agent names in SKILL.md or task files — must use `<AgentName>` placeholder token
- Specific model IDs in SKILL.md or task files — must use `<ModelId>` placeholder token
- Specific developer names or emails in SKILL.md or task files
- Specific org/repo names in SKILL.md or task files (except in examples using the `<github.owner>/<github.repo>` pattern)
- Specific platform URLs in SKILL.md or task files (except in examples using session init variable references)

### Placeholder Reference

| Value Type | Placeholder | Source |
|-----------|-------------|--------|
| AI agent name | `<AgentName>` | System prompt identity detection |
| AI model ID | `<ModelId>` | System prompt identity detection |
| Developer name | `<dev.name>` | Session init (`dev.name`) |
| Developer email | `<dev.email>` | Session init (`dev.email`) |
| Organization | `<github.owner>` or `<gitbucket.owner>` | Session init (dotted names) |
| Repository | `<github.repo>` or `<gitbucket.repo>` | Session init (dotted names) |
| Platform | `github.platform` or `gitbucket.platform` | Session init |
| GitHub URL | `github.html_url` | Session init |
| GitBucket URL | `gitbucket.html_url` | Session init |

## Two Independent Pipelines

Session-init and env-loader are **two independent pipelines with zero cross-coupling**:

- **Session-init** (`.opencode/tools/session-init`): stdout → LLM system prompt. Uses dotted `scope.param` names. Agents read these values directly as MCP tool parameters.
- **Env-loader** (`.opencode/plugins/env-loader.ts`): `output.env[]` → bash environment. Uses UPPER_CASE names. Shell commands and Python scripts read these from `os.environ`.

Changing session-init output names does NOT require changes to env-loader. Adding a new LLM-facing variable goes in session-init only. Adding a new bash-facing variable goes in env-loader only. Add to the correct pipeline based on which consumers need the variable.

## Session Init Variable Alignment Requirement

Skills and guidelines reference session-init variables by exact dotted name (e.g., `github.owner`, `github.repo`, `gitbucket.html_url`). These names MUST match the `key: value` output of `.opencode/tools/session-init` exactly 1:1.

**When creating or updating a skill that references session-init variables:**

1. **Use canonical dotted variable names only** — never invent new names or use prose labels (e.g., use `github.owner`, not `Owner:`)
2. **Verify new variable references exist in session-init output** — if a skill needs a session-init variable that doesn't appear in `.opencode/tools/session-init`, it MUST be added to session-init only (NOT env-loader, unless bash consumers also need it)
3. **The canonical session-init variable list (dotted names, LLM context):** `github.owner`, `github.repo`, `github.platform`, `github.html_url`, `gitbucket.owner`, `gitbucket.repo`, `gitbucket.html_url`, `gitbucket.ssh_url`, `gitbucket.has_credentials`, `srclight.project`, `dev.name`, `dev.email`, `branch`, `worktree.path`, `worktree.fatal`, `AgentName`, `ModelId`
4. **The canonical env-loader variable list (UPPER_CASE, bash environment — separate pipeline):** `GIT_OWNER`, `GIT_REPO`, `GIT_PLATFORM`, `GITHUB_HTML_URL`, `GITBUCKET_HTML_URL`, `GITBUCKET_SSH_URL`, `GITBUCKET_HAS_CREDENTIALS`, `DEV_NAME`, `DEV_EMAIL`, `BRANCH_NAME`, `WORKTREE_PATH`, `WORKTREE_FATAL`

**Why:** Agents extract values from session-init output by matching variable names. A name mismatch (e.g., guideline says `GIT_OWNER` but session-init outputs `github.owner`) causes agents to fall back to inferring values from git remotes, which is a critical rule violation.

## Correctness-First Economics

GPU/CPU billing is flat-rate per inference, not per word. There is no economic incentive to be concise at the expense of correctness.

- **Correctness > conciseness:** A correct 200-word explanation is better than an ambiguous 100-word one. Never sacrifice clarity or completeness to reduce word count.
- **No per-token cost pressure:** LLM inference is billed per request, not per token generated. Writing more words does not cost more. Writing wrong words costs human time to fix — that IS expensive.
- **Redundancy for enforcement:** Repetition of critical rules across skill sections is not waste — it is enforcement insurance. An LLM that misses a rule in one section may catch it in another.
- **Anti-pattern:** Cutting a rule or explanation to "save tokens" when the rule exists because agents violated it without the extra context.

## Operating Protocol

1. Determine skill type (discipline-enforcing, technique, pattern, reference)
2. Run pressure scenarios WITHOUT skill (RED phase)
3. Write minimal skill addressing failures (GREEN phase)
4. Close loopholes, add rationalization tables and red flags (REFACTOR phase)
5. Validate skill structure with `quick_validate.py`
6. Package with `package_skill.py`

## Prose-Structure Check

When creating or updating skills, verify the output is prose-first. The SKILL.md overview, operating protocol, enforcement rules, and cross-reference descriptions should read as flowing narrative — not as rigid numbered procedures where prose is expected, not as tabular mappings that should be prose descriptions, and not as fixed checklists that should be flowing narrative. Task files with TDD steps (numbered implementation actions) are naturally structured and exempt from this check. Skill type taxonomy tables, task tables, and word count tables are also exempt as they are structured reference data.

Anti-prose drift patterns to watch for: rigid numbered procedures in the operating protocol where a prose description of the workflow would communicate better; tabular mappings in the overview or persona sections that replace narrative explanation; fixed checklists in enforcement rules that should be prose statements of principle. When these patterns are found, rewrite the affected sections as flowing prose.

## Cross-Reference Verification (MANDATORY)

**🚫 CRITICAL: Each cross-reference must be verified against actual skill content. Assertions without verification are VERIFICATION-GAP findings.**

| Reference | Verification | Finding Class |
| -- | -- | -- |
| `coherence-auditor` in Cross-References section | File exists at `.opencode/skills/coherence-auditor/SKILL.md` | MISSING-TRACEABILITY if missing |
| Task table entry `init` | File exists at `.opencode/skills/skill-creator/tasks/init.md` | MISSING-TRACEABILITY if missing |
| Task table entry `package` | File exists at `.opencode/skills/skill-creator/tasks/package.md` | MISSING-TRACEABILITY if missing |
| Task table entry `validate` | File exists at `.opencode/skills/skill-creator/tasks/validate.md` | MISSING-TRACEABILITY if missing |
| `coherence-auditor` maintenance behavior | Matches actual SKILL.md: drift detection and verification for skills | CONFLICTING if mismatched |

**Verification Procedure:**

Before invoking any cross-referenced skill:
1. `ls .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: file exists or MISSING-TRACEABILITY
2. `grep -c "<task-name>" .opencode/skills/<skill-name>/SKILL.md` → EVIDENCE: task referenced or MISSING-TRACEABILITY
3. Compare described behavior with actual content → EVIDENCE: match or CONFLICTING

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Referenced skill file missing | MISSING-TRACEABILITY | flag-for-review | Cannot verify cross-reference |
| Referenced task file missing | MISSING-TRACEABILITY | flag-for-review | Task may have been renamed |
| Described behavior mismatches | CONFLICTING | flag-for-review | Cross-reference may be stale |
| Invocation mismatch | CONFLICTING | flag-for-review | Skill may have been updated |

## Cross-References

| External Source | Content Adapted |
|----------------|-----------------|
| [obra/superpowers `writing-skills`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md) | TDD methodology, CSO, rationalization resistance, anti-patterns |
| [obra/superpowers `testing-skills-with-subagents`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/testing-skills-with-subagents.md) | Pressure scenario testing methodology |
| [obra/superpowers `persuasion-principles`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/persuasion-principles.md) | Persuasion principles for skill design |

Related skills: `coherence-auditor` (drift detection and verification for new/updated skills)

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: skill-creator-001
    title: "TDD mandatory — no skill without failing test first"
    conditions:
      all:
        - "failing_test_documented == false"
        - "skill_creation_or_update_in_progress == true"
    actions:
      - HALT
      - INVOKE(RED phase — document baseline failure)
    conflicts_with: []
    requires: []
    triggers: []
    source: "skill-creator/SKILL.md §The Iron Law"

  - id: skill-creator-002
    title: "No hardcoded identity values in skill files"
    conditions:
      all:
        - "skill_file_contains_hardcoded_identity == true"
    actions:
      - REJECT(skill)
      - REPLACE(with placeholder tokens)
    conflicts_with: []
    requires: []
    triggers: []
    source: "skill-creator/SKILL.md §Placeholder Enforcement Requirement"

  - id: skill-creator-003
    title: "Verification-enforcement gate before skill generation"
    conditions:
      all:
        - "verification_enforcement_verify_invoked == false"
    actions:
      - INVOKE(verification-enforcement --task verify)
    conflicts_with: []
    requires: []
    triggers: [verification-enforcement]
    source: "skill-creator/SKILL.md §Cross-Reference Verification"

  - id: skill-creator-004
    title: "Worktree awareness mandatory in all skills"
    conditions:
      all:
        - "skill_performs_git_or_file_operations == true"
        - "worktree_mode_section_present == false"
    actions:
      - REJECT(skill until Worktree Mode section added)
    conflicts_with: []
    requires: []
    triggers: []
    source: "skill-creator/SKILL.md §Worktree Awareness Requirement"

  - id: skill-creator-005
    title: "Enforcement test step mandatory after skill creation/update"
    conditions:
      all:
        - "enforcement_test_updated == false"
        - "skill_created_or_updated == true"
    actions:
      - HALT
      - ADD_ENFORCEMENT_TEST_SCENARIO
    conflicts_with: []
    requires: [skill-creator-001]
    triggers: []
    source: "skill-creator/SKILL.md §Enforcement Test Step"

  - id: skill-creator-006
    title: "Required frontmatter fields present"
    conditions:
      all:
        - "skill_frontmatter_missing_required_field == true"
    actions:
      - REJECT(skill until frontmatter complete)
    conflicts_with: []
    requires: []
    triggers: []
    source: "skill-creator/SKILL.md §Skill Type Taxonomy"

  - id: skill-creator-007
    title: "Session-init variable names must match canon"
    conditions:
      all:
        - "skill_references_non_canonical_session_var == true"
    actions:
      - REPLACE(with canonical dotted name)
    conflicts_with: []
    requires: []
    triggers: []
    source: "skill-creator/SKILL.md §Session Init Variable Alignment"

  - id: skill-creator-008
    title: "No 0-based counting patterns in skill/task docs"
    conditions:
      all:
        - "skill_contains_zero_based_counting == true"
        - "context != code_block"
    actions:
      - FLAG(validation error requiring correction)
    conflicts_with: []
    requires: []
    triggers: []
    source: "skill-creator/SKILL.md §Validation Gate"

tasks:
  - id: create
    skill: skill-creator
    preconditions:
      - "failing_test_documented == true (RED phase complete)"
      - "skill_type_determined == true"
    postconditions:
      - "skill_file_created == true"
      - "worktree_mode_section_present == true (if applicable)"
      - "placeholder_tokens_used == true"
      - "enforcement_test_scenario_added == true"
    mandatory: true
    bypass_violation: "Skill without TDD — creating skill without failing test first violates Iron Law"
    source: "skill-creator/SKILL.md §Tasks init"

  - id: update
    skill: skill-creator
    preconditions:
      - "existing_skill_file_found == true"
      - "failing_test_documented == true (RED phase for change)"
    postconditions:
      - "skill_file_updated == true"
      - "no_hardcoded_identity_values == true"
      - "enforcement_test_scenario_updated == true"
    mandatory: true
    bypass_violation: "Skill update without TDD — modifying skill without baseline failure test violates Iron Law"
    source: "skill-creator/SKILL.md §TDD Cycle"

  - id: validate
    skill: skill-creator
    preconditions:
      - "skill_files_exist == true"
    postconditions:
      - "all_frontmatter_complete == true"
      - "no_hardcoded_identity_values == true"
      - "worktree_sections_present == true (where applicable)"
      - "no_zero_based_counting == true"
      - "session_var_names_canonical == true"
    mandatory: false
    bypass_violation: "Validation recommended but not blocking — flagged issues should be addressed before skill is used"
    source: "skill-creator/SKILL.md §Tasks validate"

  - id: completion
    skill: skill-creator
    preconditions: []
    postconditions:
      - "terminal_state_dispatch_occurred == true"
      - "status_report_produced == true"
    mandatory: true
    bypass_violation: "Silent Agent Termination — halting without completion task is a critical violation"
    source: "skill-creator/SKILL.md Operating Protocol"

decomposition:
  - type: skill-task
    skill: verification-enforcement
    task: verify
    mandatory: true
    bypass_violation: "Skipping verification-enforcement — skill generation without verification gate is a critical violation"

  - type: sub-agent
    skill: coherence-auditor
    task: audit
    mandatory: false
    bypass_violation: "Coherence audit optional but recommended for cross-skill consistency"

gates:
  - id: no-hardcoded-identity
    condition: "skill_file_contains_hardcoded_identity == false"
    on_fail: HALT
    critical_violation: true

  - id: required-frontmatter
    condition: "frontmatter_name_present == true AND frontmatter_description_present == true AND frontmatter_type_present == true"
    on_fail: HALT
    critical_violation: true

  - id: tdd-red-phase
    condition: "failing_test_documented == true"
    on_fail: HALT
    critical_violation: true

  - id: worktree-awareness
    condition: "worktree_mode_section_present == true OR skill_has_no_git_file_operations == true"
    on_fail: WARN
    critical_violation: false

evidence_artifacts:
  - name: tdd_red_phase_evidence
    type: tool_call
    verification: "bash .opencode/tests/with-test-home opencode-cli run '<test message>' → baseline failure output"

  - name: validation_output
    type: tool_call
    verification: "uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py → REQ-1/2/3 check"

  - name: quick_validate_output
    type: tool_call
    verification: "./.opencode/skills/skill-creator/scripts/quick_validate.py <skill-folder> → frontmatter check"

  - name: placeholder_check
    type: tool_call
    verification: "grep for hardcoded agent names, model IDs, developer names in SKILL.md and task/*.md files"
```