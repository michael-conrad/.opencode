# [PLAN] Issue #1050: plan schema validation + extended help subcommand

**Spec:** https://github.com/michael-conrad/.opencode/issues/1050
**Repo:** `michael-conrad/.opencode`
**Target file:** `.opencode/tools/plan`

## Topology

Two independent dependency chains:

```
Chain 1 (help):  help_subcommand -> help_content -> help_tests
Chain 2 (val):   top_val -> section_val -> error_snippets -> val_tests
```

Both chains can execute in parallel.

## Plan-Verified Dependency Order (via `.opencode/tools/plan`)

```
1. implement_help_subcommand()        [Chain 1 start]
2. add_top_level_validation()         [Chain 2 start]
3. add_section_validation()           [Chain 2: depends on top_val_done]
4. write_help_content()               [Chain 1: depends on help_subcommand_done]
5. add_error_snippets()               [Chain 2: depends on section_val_done]
6. write_help_tests()                 [Chain 1: depends on help_content_done]
7. write_val_tests()                  [Chain 2: depends on error_snippets_done]
```

**Planner status:** SOLVED_SATISFICING (7 actions, 7 goals)
**Validate status:** valid

## Z3-Verified Contract Invariants

| Invariant | Status |
|-----------|--------|
| D_A => (all A gates) | VALID |
| A_p14 => (A_p1 ... A_p13) | VALID |
| All-false init state | SAT |

## Unit Breakdown

### Unit A: help_subcommand
**RED:** `./.opencode/tools/plan help` exits with error
**GREEN:** `plan help` prints full schema reference, exits 0

### Unit B: help_content
**RED:** Help output is empty or placeholder
**GREEN:** Covers all 7 topics

### Unit C: top_val
**RED:** `precondition:` silently accepted, cryptic error
**GREEN:** `precondition:` -> "Did you mean 'preconditions'?" + snippet

### Unit D: section_val
**RED:** `parameters:` on fluent -> UP stack trace
**GREEN:** `parameters:` on fluent -> "Did you mean 'params'?"

### Unit E: error_snippets
**RED:** Validation errors are one-line only
**GREEN:** Each error includes YAML format snippet

### Unit F: help_tests
**RED:** `plan-help.sh` fails
**GREEN:** `plan-help.sh` passes

### Unit G: val_tests
**RED:** `plan-validation.sh` fails
**GREEN:** `plan-validation.sh` passes

## Artifacts

All at `.issues/1050/spec-artifacts/` on `issues-data` branch:

| File | Description |
|------|-------------|
| `plan.md` | Full plan document |
| `plan.yaml` | Artifact metadata |
| `plan-order.yaml` | Planner-verified step ordering |
| `issue-1050-problem.yaml` | Planning domain model |
| `issue-1050-plan.yaml` | Generated plan output |
| `issue-1050-contract.yaml` | Z3 contract |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
