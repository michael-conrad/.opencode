# Task: validate

## Purpose

Check an existing plan for placeholders and completeness.

## Validation Checks

- [ ] 01. (**sub-agent**) Placeholder detection — Zero TBD/TODO tolerance
  - Command: `grep(pattern="TBD|TODO|tbd|todo")` on plan body
  - SC: All
  - Expected: zero matches

- [ ] 02. (**sub-agent**) Completeness — Plan addresses the stated problem
  - Command: read plan body, compare against spec problem statement
  - SC: All
  - Expected: plan covers all spec requirements

- [ ] 03. (**sub-agent**) Actionability — Steps are concrete, not abstract goals
  - Command: manual parse — flag abstract goals
  - SC: All
  - Expected: each step has concrete action

- [ ] 04. (**sub-agent**) Testability — Success criteria include executable verification commands with exact expected values
  - Command: read each SC in plan, verify it has a verification command
  - SC: All
  - Expected: each SC specifies command that produces deterministic pass/fail

- [ ] 05. (**sub-agent**) TDD structure — Each task has failing test → implement → passing test steps
  - Command: verify RED/GREEN chain present for each item
  - SC: All
  - Expected: RED → GREEN → doublecheck → commit structure

- [ ] 06. (**sub-agent**) File structure — All files are listed with responsibilities
  - Command: read plan Files section, verify against spec
  - SC: All
  - Expected: all files listed with clear responsibilities

- [ ] 07. (**sub-agent**) Self-review evidence — Agent has performed spec coverage, placeholder, and type consistency checks
  - Command: check for self-review evidence in plan
  - SC: All
  - Expected: self-review evidence present

- [ ] 08. (**sub-agent**) Spec reference — Plan body contains a spec reference
  - Command: `grep(pattern="Spec: #")` on plan body
  - SC: All
  - Expected: spec reference present

- [ ] 09. (**sub-agent**) Sub-issue parent — If plan has sub-issues, they link to the plan (not the spec)
  - Command: `github_issue_read(method=get_sub_issues, issue_number=plan_number)`
  - SC: All
  - Expected: sub-issues linked to plan, not spec

- [ ] 10. (**sub-agent**) Plan file exists — Plan file exists at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
  - Command: `ls .issues/{N}/plan.md */.issues/{N}/plan.md 2>/dev/null`
  - SC: All
  - Expected: file exists

- [ ] 11. (**sub-agent**) Pipeline-gate completeness — All implementation-pipeline gate steps present
  - Command: read `implementation-pipeline/SKILL.md` §Dispatch Routing Table, compare against plan
  - SC: SC-13
  - Expected: all gate steps present in plan's exit criteria or phase structure

- [ ] 12. (**sub-agent**) Global sequential numbering — Step numbering is globally sequential across all phases
  - Command: parse plan step numbers, verify no per-phase restart
  - SC: All
  - Expected: step N+1 follows step N across phase boundaries

- [ ] 13. (**sub-agent**) Checkbox format — All implementation steps use `- [ ] N.` checkbox format
  - Command: `grep(pattern="- \\[ \\] \\d+\\.")` on plan body
  - SC: SC-9
  - Expected: all steps use checkbox format

- [ ] 14. (**sub-agent**) Phase workflow completeness — Every phase contains full implementation workflow step sequence
  - Command: read `implementation-pipeline/SKILL.md` §Dispatch Routing Table, compare each phase
  - SC: SC-13
  - Expected: each phase has complete RED/GREEN chain

- [ ] 15. (**sub-agent**) No duplicate global steps — Global pre/post steps not duplicated across per-file phases
  - Command: check Phase 1 (global pre) and Phase 7-8 (global post) steps against per-file phases
  - SC: SC-15
  - Expected: no global steps duplicated in per-file phases

- [ ] 16. (**sub-agent**) Canonical format compliance — Plan matches canonical reference
  - Command: read `.opencode/.issues/1393/plan.md`, compare against plan
  - SC: SC-22
  - Expected: three-tier structure, dispatch context, contract paths, failure conditions match

## Result Contract Schema

Before returning, load the output contract from `contracts/validate-output-template.yaml` and validate the result against it. The contract defines the expected output structure:

```yaml
status: string  # PASS | BLOCKED
per_check_results: list[dict]  # per-check PASS/FAIL with check_id, check_name, status, evidence_type, finding_classification, action
artifact_path: string  # path to full evidence on disk
summary: string  # 1-3 sentence summary
```

Each z3-check step runs `solve check` against the previous step's output contract to validate state transitions.

## No-Placeholders Rule

Every step must contain actual content. These are **plan failures**:

| Pattern | Why Prohibited |
| -- | -- |
| `TBD` | Incomplete plan |
| `TODO` | Incomplete plan |
| `[to be determined]` | Incomplete plan |
| `[needs investigation]` | Investigation should be in spec |
| `[placeholder]` | Incomplete plan |
| `[requires research]` | Research should be in spec |
| `implement later` | Plan not actionable |
| `fill in details` | Details must be specified |
| `Add appropriate error handling` | Must specify actual code |
| `Add validation` / `Handle edge cases` | Must specify actual code |
| `Write tests for the above` | Must include actual test code |
| `Similar to Task N` | Must repeat the code — engineer may read tasks out of order |
| Steps describing what to do without showing how | Code blocks required for code steps |
| References to types/functions not defined in any task | All referenced symbols must be defined |

## Specs vs Plans

| Artifact | Placeholders Allowed? | Examples |
| -- | -- | -- |
| Spec (GitHub Issue) | YES, during iterative development | TBD, TODO, \[needs investigation\], \[placeholder\] |
| Plan (for implementation) | NO — zero tolerance | None allowed before implementation begins |

## Validation Logic

```python
INVALID_PATTERNS = [
    "TBD", "TODO", "tbd", "todo",
    "[to be determined]", "[needs investigation]",
    "[placeholder]", "[requires research]",
    "implement later", "fill in details",
]

def validate_plan(plan_content: str) -> bool:
    for pattern in INVALID_PATTERNS:
        if pattern in plan_content:
            return False
    return True
```

Does NOT enforce a specific section order. A plan without "Risks" is valid if risks are addressed elsewhere or are not relevant.

## Live Verification: Validation Evidence (MANDATORY)

**Each validation check MUST be verified via tool call, not just asserted. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "No placeholders present" | Search for placeholder patterns in plan body | \`grep(pattern="TBD | TODO |
| "Spec reference exists in plan" | Search for `Spec: #N` pattern | `grep(pattern="Spec: #")` on plan body | MISSING-ELEMENT |
| "Sub-issues link to plan (not spec)" | Verify sub-issue parent | `issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=plan_number)` | STRUCTURE-VIOLATION | <!-- Routes through issue-operations per SPEC #683 -->
| "Plan file exists" | Verify plan file at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` | `ls .issues/{N}/plan.md */.issues/{N}/plan.md 2>/dev/null` | MISSING-ELEMENT |
| "Steps are actionable" | Verify each step has concrete action | Manual parse — flag abstract goals | VERIFICATION-GAP |

**Evidence artifact:** Tool call results for automated checks; manual review log for actionable-step verification.

### Finding Classification

| Finding | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Placeholders found | VERIFICATION-GAP | conditional | Remove placeholders or mark plan invalid |
| Missing spec reference | MISSING-ELEMENT | auto-fix | Add spec reference to plan body |
| Sub-issues under wrong parent | STRUCTURE-VIOLATION | auto-fix | Re-link under plan |
| Missing `plan` label | MISSING-ELEMENT | auto-fix | Add label immediately |
| Abstract goals found | VERIFICATION-GAP | flag-for-review | Flag for plan author to rewrite |
