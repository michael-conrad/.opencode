---
remote_issue: 1196
remote_url: "https://github.com/michael-conrad/.opencode/issues/1196"
last_sync: "2026-06-14T16:10:15Z"
source: github
---

## Summary

Every guideline file in `.opencode/guidelines/` ends with a `yaml+symbolic` rule block declaring `conditions`, `actions`, `tier`, `requires`, `conflicts_with`, and `triggers`. These blocks look like machine-parseable enforcement rules but currently have no runtime consumer — no parser reads them, no plugin evaluates them, no gate checks them. They are decorative YAML in Markdown.

The Z3 solver already exists (`.opencode/tools/solve` with `model`, `check`, `unsat-core` subcommands). The blocks already declare constraints. Build an extractor that translates `conditions` → Z3 boolean variables, `requires` → dependency constraints, `conflicts_with` → mutual-exclusion constraints, and feeds the resulting contract to `solve check` at each pipeline gate. UNSAT + unsat core identifies exactly which constraints are violated.

## Core Principle

The yaml+symbolic blocks are a partial implementation of workflow validation. They declare what must be true, what conflicts, and what depends on what — but in a format only humans (and AI agents reading prose) can evaluate. Z3 gives us runtime evaluation of the same declarations.

## Root Cause

The symbolic rules were written without a consumer. The solver was built later (`solve` tool with Z3 bindings). The pipeline between declarative rule files and the solver was never constructed.

## Affected Components

| Component | Role |
|-----------|------|
| `.opencode/guidelines/*.md` | Source of yaml+symbolic rule blocks (input) |
| `.opencode/skills/*/SKILL.md` | May also contain symbolic rules (input) |
| `.opencode/tools/solve` | Z3 solver (consumer) |
| New: extractor script | Translates yaml+symbolic → Z3 contract YAML |
| Pipeline gates | Invocation points for `solve check` |

## Spec

### Phase 1: Define Z3 Contract Schema

Design a YAML contract schema that maps yaml+symbolic structures to Z3 variables:

| yaml+symbolic field | Z3 representation |
|---------------------|-------------------|
| `conditions.all` | Conjunction of boolean variables |
| `conditions.any` | Disjunction of boolean variables |
| `requires` | Implication: rule → requires |
| `conflicts_with` | Mutual exclusion: NOT(rule AND conflict) |
| `triggers` | Activation condition (skill is loaded → rules active) |
| `tier` | Constraint weight or group (1=hard, 2=soft, 3=advisory) |

Output: a single YAML file per pipeline gate that the `solve` tool's existing `model`/`check` subcommands can consume.

Schema decisions to resolve:
- How to handle variable naming across files (namespace per file?)
- How `requires` chains translate (direct implication vs transitive closure)
- Whether `tier` produces hard vs optional constraints in Z3
- How `triggers` maps to solver activation (only include rules whose trigger matches the current pipeline phase)

### Phase 2: Build Extractor Script

Create `.opencode/tools/extract-rules` (or extend `solve` with a `collect` subcommand) that:

1. Reads all `.opencode/guidelines/*.md` files
2. Extracts yaml+symbolic blocks (between ```yaml+symbolic and ``` fences)
3. Parses each block's `rules` array into Z3-compatible variables
4. Merges rules from all files into a single contract YAML
5. Handles namespace collisions (same variable name across files)
6. Outputs to `./tmp/{pipeline-phase}/rules-contract.yaml`

Optionally accept an `--include` flag to filter by `triggers` (only include rules relevant to the current pipeline phase).

### Phase 3: Wire to Pipeline Gates

At each pipeline gate where verification currently happens, replace or supplement file-existence checks with `solve check`:

```bash
./.opencode/tools/extract-rules --output ./tmp/checkpoint/rules-contract.yaml
./.opencode/tools/solve check --contract ./tmp/checkpoint/rules-contract.yaml
```

If UNSAT: extract unsat core → identify which rules are violated → report as blocker with rule IDs.

Candidate gates:
- Pre-commit (Gate 2 replacement — currently file-existence checks)
- Pre-push
- assemble-work phase transitions
- verify-authorization Step 4.5 (item decomposition check)
- plan validation (Step 9 in create-and-validate)

### Phase 4 (optional): Remove or Reduce yaml+symbolic Boilerplate

Once the extractor is proven, consider:
- Moving yaml+symbolic blocks to standalone YAML files (`.opencode/rules/`) instead of embedding in Markdown
- Adding schema validation for the blocks so malformed rules are caught at extract time
- Dropping the prose duplication (rules appear both as prose paragraphs and as yaml+symbolic — one layer may suffice)

This is deferred — Phase 1-3 are the core work.

## Non-Goals

- Not removing yaml+symbolic blocks from guideline files (they remain the authoring surface)
- Not changing the solve tool's existing subcommand interface
- Not enforcing every guideline rule through Z3 — only rules with explicit yaml+symbolic blocks
- Not building a real-time continuous solver (pipeline-gate invocations only)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Z3 contract schema defined and documented | `string` |
| SC-2 | Extractor script reads yaml+symbolic blocks from all guideline files and produces a valid contract YAML | `behavioral` |
| SC-3 | Extractor correctly translates `conditions.all` to conjunction, `conditions.any` to disjunction, `requires` to implication, `conflicts_with` to mutual exclusion | `behavioral` |
| SC-4 | `solve check` against extracted contract returns SAT with no state variables set | `behavioral` |
| SC-5 | `solve check` returns UNSAT with identifiable unsat core when a `conflicts_with` pair is simultaneously asserted | `behavioral` |
| SC-6 | Extractor supports `--include` flag filtering by trigger skill name | `string` |
| SC-7 | At least one pipeline gate runs `solve check` against extracted rules as part of its procedure | `behavioral` |

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/yaml-symbolic-z3-contracts`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)