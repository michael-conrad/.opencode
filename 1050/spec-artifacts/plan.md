# Plan: [#1050](https://github.com/michael-conrad/.opencode/issues/1050) — plan tool: schema validation + plan help subcommand

## Overview

Two phases: add `_validate_schema()` to `.opencode/tools/plan` that catches unknown keys with "Did you mean" suggestions and format snippets, then add a `plan help` subcommand printing the full YAML schema reference.

## Changes

| # | Action | Target | Details |
|---|--------|--------|---------|
| 1 | Edit | `.opencode/tools/plan` | Add `_validate_schema()` called from `_action_plan()` before `_build_problem()` |
| 2 | Edit | `.opencode/tools/plan` | Add `help` subcommand to `_build_parser()` and `_action_help()` function |
| 3 | Create | `.opencode/tmp/bad-singular.yaml` | RED fixture: action with `precondition:` (singular) |
| 4 | Create | `.opencode/tmp/bad-fluent-params.yaml` | RED fixture: fluent with `parameters:` (wrong key) |
| 5 | Create | `.opencode/tmp/bad-multiple.yaml` | RED fixture: action with both `precondition:` and `effect:` (singular) |

## Pipeline Gates

### Phase 1 — Schema validation

| # | Gate | Exit Criterion |
|---|------|----------------|
| 1 | RED | Create 3 test YAMLs with bad keys, confirm current tool gives cryptic errors |
| 2 | GREEN | `_validate_schema()` — checks known keys per section, fuzzy matches, reports all errors, exits 1 |
| 3 | VBC-SC1 | `bad-singular.yaml` → `"Did you mean 'preconditions'?"` + snippet, exit 1 |
| 4 | VBC-SC2 | `bad-fluent-params.yaml` → `"Did you mean 'params'?"` + snippet, exit 1 |
| 5 | VBC-SC3 | `bad-multiple.yaml` → BOTH suggestions in single run |
| 6 | REGRESSION | `simple.yaml`, `cyclic.yaml`, `gripper.yaml` still parse and plan correctly |

### Phase 2 — plan help subcommand

| # | Gate | Exit Criterion |
|---|------|----------------|
| 1 | RED | `.opencode/tools/plan help` exits non-zero |
| 2 | GREEN | Add `help` subcommand to parser, implement `_action_help()` |
| 3 | VBC-SC4 | `.opencode/tools/plan help` exits 0, output covers all 7 required topics |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `precondition` (singular) on action → `"Did you mean 'preconditions'?"` + snippet, exit 1 | `behavioral` |
| SC-2 | `parameters` on fluent → `"Did you mean 'params'?"` + snippet, exit 1 | `behavioral` |
| SC-3 | Multiple unknown keys reported in single pass | `behavioral` |
| SC-4 | `.opencode/tools/plan help` prints complete schema reference, exit 0 | `behavioral` |

## Dispatch Markers

| Phase | Marker |
|-------|--------|
| 1 | `1050-schema-validation` |
| 2 | `1050-plan-help` |