# Task: verify-authorization — Step 4.5: Verify Item Decomposition and Behavioral Test Coverage

## Purpose

Before implementation proceeds, verify that the plan includes item-level decomposition as required by `091-incremental-build.md` AND that items which change agent behavior have behavioral enforcement test coverage in their TDD cycles. This gate applies to ALL scopes (GREENFIELD, NEW_FEATURE, FIX, ENHANCEMENT) and ALL authorization types.

## Key Principles

### Item Decomposition Is Not Optional

A plan without item enumeration is a prose description, not an implementation plan. Item decomposition provides:
- **Traceability:** Each implementation unit maps to a spec requirement
- **Dependency ordering:** Items are sequenced so each item's dependencies are satisfied
- **TDD discipline:** Each item has its own RED/GREEN/COMMIT cycle
- **Incremental verification:** Each item is independently testable

### Behavioral TDD for Rule Changes Is Not Optional

For items that change agent behavior (guideline text, skill enforcement, critical violation text), content-verification tests alone are insufficient. A content-verification test confirms "the text exists in the file" but does NOT confirm "the agent actually follows the rule." Behavioral enforcement tests verify agent behavior by sending a prompt and checking the response.

## Verification Checks

1. **Item enumeration exists** — The plan lists every implementation unit as a discrete item with name, scope, and deliverable
2. **Dependency ordering exists** — Items are ordered so that each item's dependencies are satisfied by preceding items
3. **Acceptance criteria per item** — Each item has testable acceptance criteria that can be verified independently
4. **Behavioral TDD for rule items** — For each plan item that changes a rule governing agent behavior, the item's TDD cycle includes a behavioral RED phase and a behavioral GREEN phase. Items with only content-verification tests for behavioral rule changes are flagged as STRUCTURE-VIOLATION.

## Procedure

```
plan_issue = github_issue_read(method="get", issue_number=plan_number)
plan_body = plan_issue["body"]

# Check for item enumeration
has_items = "Item" in plan_body and ("Dependencies" in plan_body or "Acceptance Criteria" in plan_body)

# Check for TDD step structure
has_tdd_steps = "RED" in plan_body and "GREEN" in plan_body and "COMMIT" in plan_body

if not has_items:
    # STRUCTURE-VIOLATION: No item decomposition found
    finding = "Plan lacks item decomposition — no item enumeration found"
    action = "BLOCK implementation; require plan revision with top-down item decomposition"
    severity = "STRUCTURE-VIOLATION"

if not has_tdd_steps:
    # STRUCTURE-VIOLATION: No TDD cycle defined
    finding = "Plan lacks TDD cycle definition — no RED/GREEN/COMMIT steps found"
    action = "BLOCK implementation; require plan revision with per-item TDD steps"
    severity = "STRUCTURE-VIOLATION"

# Check for behavioral TDD in rule-changing items
for item in plan_items:
    if is_rule_change_item(item):
        has_behavioral_test = "assert_tool_calls_made" in item or "assert_forbidden_pattern_absent" in item or "assert_required_pattern_present" in item or "behavioral" in item
        has_content_verification_only = not has_behavioral_test and ("grep" in item or "content-verification" in item)
        if has_content_verification_only:
            # STRUCTURE-VIOLATION: Rule change item has only content-verification test
            finding = f"Item '{item['name']}' changes agent behavior but has only content-verification test — behavioral enforcement test required"
            action = "BLOCK implementation; require behavioral TDD for rule-changing item"
            severity = "STRUCTURE-VIOLATION"
```

## Exemption

Single-task plans (0 or 1 phases) are exempt from the item decomposition check. The check applies ONLY to multi-task plans with more than one phase.

## Item vs Phase Distinction

- **Phase:** A major unit of work containing multiple items (e.g., "Phase 1: Data Model")
- **Item:** The smallest independently testable implementation unit within a phase (e.g., "Item 1.1: Create User model")

Items are the decomposition unit; phases are the grouping unit. Item-level TDD cycles are the enforcement granularity.

## Cross-Reference

See `091-incremental-build.md` for the complete discipline rules, scope classification, and per-item TDD cycle. See `091-incremental-build.md` → "Enforcement Mechanism" section for RED phase verification requirements. See `080-code-standards.md` → "Behavioral Enforcement Tests (PRIMARY)" for the behavioral RED/GREEN gate mandate.

## Work State I/O

- **Reads from:** `## scope-auto-resolve`
- **Writes to:** `## item-decomposition-check`

After completing this task, write results to the work state file under section `## item-decomposition-check` using the YAML format defined in `enforcement/work-state-schema.md`.

## Result Contract

```yaml
status: PASS | STRUCTURE-VIOLATION
task: item-decomposition-check
has_items: bool
has_tdd_steps: bool
behavioral_tdd_complete: bool
violations: [<finding>, ...]
blocking: bool
```