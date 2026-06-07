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

Both chains can execute in parallel up to common dependency gates.

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
| `D_A => (A_p1 ... A_p14)` - domain=True only when all gates pass | **VALID** |
| `A_p14 => (A_p1 ... A_p13)` - serial ordering | **VALID** |
| All-false init state | **SAT** |

## Unit Breakdown

---

### Unit A: help_subcommand - Add `plan help` subcommand to argparse

**RED condition:** `./.opencode/tools/plan help` exits with error or prints nothing useful
**GREEN condition:** `./.opencode/tools/plan help` prints full schema reference and exits 0

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Plan items align with spec SC-5 structure |
| 2 | pre-red-baseline | `plan help` fails (no subcommand yet) |
| 3 | red-phase | Behavioral test for `plan help` fails: agent gets USAGE error |
| 4 | red-doublecheck | RED-side SC evidence: test exit code != 0 |
| 5 | green-phase | `_action_help()` function + argparse registration implemented |
| 6 | checkpoint-commit | Help subcommand committed |
| 7 | structural-checks | Ruff + pyright pass on modified tool |
| 8 | green-doublecheck | `plan help` exits 0, prints schema |
| 9 | green-vbc | All SC evidence artifacts collected |
| 10 | adversarial-audit | Dual-auditor: help subcommand present, output covers schema topics |
| 11 | cross-validate | No cross-unit contamination (other subcommands unchanged) |
| 12 | regression-check | `plan plan --problem simple.yaml` still solves and validates |
| 13 | review-prep | PR body drafted, diff reviewed |
| 14 | exec-summary | Push + issue comment posted |

---

### Unit B: help_content - Write full schema reference content

**RED condition:** Help output is empty or contains placeholders
**GREEN condition:** Help output covers all 7 topics: top-level schema, action structure, expression syntax, object/type resolution, init defaults, validation constraints, complete example

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Content plan covers spec SC-6 requirements |
| 2 | pre-red-baseline | Help subcommand exists but content is empty |
| 3 | red-phase | Behavioral test: `plan help` output missing topic X |
| 4 | red-doublecheck | RED evidence: grep for each topic shows absence |
| 5 | green-phase | Write 7-topic reference string |
| 6 | checkpoint-commit | Help content committed |
| 7 | structural-checks | Line length, formatting clean |
| 8 | green-doublecheck | `plan help` output covers all 7 topics |
| 9 | green-vbc | All 7 topics verified in output |
| 10 | adversarial-audit | Dual-auditor: content completeness check |
| 11 | cross-validate | No cross-unit contamination |
| 12 | regression-check | `plan plan` still works |
| 13 | review-prep | PR body updated |
| 14 | exec-summary | Push + issue comment |

---

### Unit C: top_val - Add top-level schema validation

**RED condition:** `precondition:` (singular) silently accepted, produces cryptic error
**GREEN condition:** `precondition:` produces: `ERROR: unknown key 'precondition'. Did you mean 'preconditions'?` - exits code 1

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Spec SC-1 to SC-4 validation requirements covered |
| 2 | pre-red-baseline | `precondition:` produces UNSOLVABLE_INCOMPLETELY |
| 3 | red-phase | Behavioral test: singular key -> no validation error |
| 4 | red-doublecheck | RED evidence: cryptic error captured |
| 5 | green-phase | `_validate_schema()` recognizes known keys per section, Did you mean matching |
| 6 | checkpoint-commit | Schema validation committed |
| 7 | structural-checks | Ruff + pyright pass |
| 8 | green-doublecheck | `precondition:` -> validation error with Did you mean preconditions? |
| 9 | green-vbc | SC-1 + SC-2 evidence collected |
| 10 | adversarial-audit | Dual-auditor: validation catches unknown keys |
| 11 | cross-validate | Validation doesnt reject valid files |
| 12 | regression-check | `simple.yaml` still validates as valid |
| 13 | review-prep | PR body updated |
| 14 | exec-summary | Push + issue comment |

---

### Unit D: section_val - Add section-level key validation

**RED condition:** `parameters:` on a fluent silently creates 0-arity fluent, produces UP stack trace
**GREEN condition:** `parameters:` on a fluent produces: `ERROR: unknown key 'parameters'. Did you mean 'params'?`

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Spec SC-3 section validation covered |
| 2 | pre-red-baseline | `parameters:` on fluent -> Python stack trace |
| 3 | red-phase | Behavioral test: wrong key on fluent -> no validation |
| 4 | red-doublecheck | RED evidence: stack trace captured |
| 5 | green-phase | Section-level key validation + param count validation |
| 6 | checkpoint-commit | Section validation committed |
| 7 | structural-checks | Ruff + pyright pass |
| 8 | green-doublecheck | `parameters:` on fluent -> validation error + Did you mean params? |
| 9 | green-vbc | SC-3 evidence collected |
| 10 | adversarial-audit | Dual-auditor: all section key sets validated |
| 11 | cross-validate | No cross-unit contamination |
| 12 | regression-check | `simple.yaml` + `cyclic.yaml` still work |
| 13 | review-prep | PR body updated |
| 14 | exec-summary | Push + issue comment |

---

### Unit E: error_snippets - Append correct-format snippets to validation errors

**RED condition:** Validation error messages end after Did you mean - no format snippet
**GREEN condition:** Each validation error is followed by a YAML example of correct structure

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Spec requires correct-format snippets |
| 2 | pre-red-baseline | Validation errors are one-line only |
| 3 | red-phase | Behavioral test: error for singular key has no format snippet |
| 4 | red-doublecheck | RED evidence: snippet absence confirmed |
| 5 | green-phase | Format snippets appended to each error category |
| 6 | checkpoint-commit | Error snippets committed |
| 7 | structural-checks | Ruff + pyright pass |
| 8 | green-doublecheck | Error message includes YAML example |
| 9 | green-vbc | SC-4 evidence (multiple errors reported) collected |
| 10 | adversarial-audit | Dual-auditor: snippets match actual correct format |
| 11 | cross-validate | No cross-unit contamination |
| 12 | regression-check | Valid files still validate clean |
| 13 | review-prep | PR body updated |
| 14 | exec-summary | Push + issue comment |

---

### Unit F: help_tests - Behavioral enforcement tests for help subcommand

**RED condition:** Test runs but fails because help subcommand doesnt exist
**GREEN condition:** Test passes - `plan help` exits 0, output covers 7 topics

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Spec SC-5 behavioral test requirement covered |
| 2 | pre-red-baseline | No help behavioral test exists |
| 3 | red-phase | `plan-help.sh` -> FAIL (help subcommand absent) |
| 4 | red-doublecheck | RED evidence: exit code != 0 captured |
| 5 | green-phase | Help test written and passing against Unit A + B |
| 6 | checkpoint-commit | Test + implementation committed together |
| 7 | structural-checks | Shellcheck on test |
| 8 | green-doublecheck | `bash plan-help.sh` -> PASS |
| 9 | green-vbc | SC-5 + SC-6 evidence collected |
| 10 | adversarial-audit | Dual-auditor: test covers both subcommand presence and content |
| 11 | cross-validate | No cross-unit contamination |
| 12 | regression-check | Existing behavioral tests still pass |
| 13 | review-prep | PR body updated |
| 14 | exec-summary | Push + issue comment |

---

### Unit G: val_tests - Behavioral enforcement tests for schema validation

**RED condition:** Test runs but fails because validation is not implemented
**GREEN condition:** Test passes - all 3 bad-key patterns detected with Did you mean + snippet

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Spec SC-1 to SC-4 behavioral coverage |
| 2 | pre-red-baseline | No validation behavioral test exists |
| 3 | red-phase | `plan-validation.sh` -> FAIL (validation absent) |
| 4 | red-doublecheck | RED evidence: each bad-key pattern silently accepted |
| 5 | green-phase | Validation test written, passing against Unit C + D + E |
| 6 | checkpoint-commit | Test + implementation committed together |
| 7 | structural-checks | Shellcheck on test |
| 8 | green-doublecheck | `bash plan-validation.sh` -> PASS |
| 9 | green-vbc | SC-1 through SC-4 all verified |
| 10 | adversarial-audit | Dual-auditor: tests cover all failure modes from spec |
| 11 | cross-validate | No cross-unit contamination |
| 12 | regression-check | Existing behavioral tests still pass |
| 13 | review-prep | PR body updated |
| 14 | exec-summary | Push + issue comment |

## Artifacts

All artifacts at `.issues/1057/spec-artifacts/` on `issues-data` branch:

| Artifact | Description |
|----------|-------------|
| `plan.yaml` | Artifact metadata with all 7 units, RED/GREEN, Z3 status |
| `plan-order.yaml` | Planner-verified step ordering |
| `issue-1050-problem.yaml` | Planning problem model (domain/fluents/actions/goals) |
| `issue-1050-plan.yaml` | Generated plan output (SOLVED_SATISFICING) |
| `issue-1050-contract.yaml` | Z3 contract for pipeline gate invariants |

**Plan issue:** https://github.com/michael-conrad/.opencode/issues/1057
**Spec:** https://github.com/michael-conrad/.opencode/issues/1050

