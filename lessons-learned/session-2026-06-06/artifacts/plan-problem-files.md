# Plan Tool Problem Files — Session 2026-06-06

These are the problem files that failed with `UNSOLVABLE_INCOMPLETELY` due to key name mismatches.

## pr-creation-problem.yaml (original)

Used `precondition:` (singular) and `effect:` (singular) — parser expects `preconditions:` and `effects:` (plural). Also used `parameters:` on fluents — parser expects `params:`.

```yaml
domain: pr-creation
types:
  - name: issue
objects:
  - name: all
    type: issue
fluents:
  - name: committed
  - name: clean_tree
  - name: pushed
  - name: pr_created
  - name: issue_body_updated
    parameters:  # WRONG — should be `params:`
      - name: i
        type: issue
actions:
  - name: push-feature-branch
    precondition: ["committed", "clean_tree"]  # WRONG — singular
    effect: ["pushed"]                          # WRONG — singular
  - name: create-github-pr
    precondition: ["pushed"]                    # WRONG — singular
    effect: ["pr_created"]                      # WRONG — singular
init:
  - committed
  - clean_tree
goals:
  - "pushed"
  - "pr_created"
  - "issue_body_updated(all)"
```

## Diagnosis

The `plan ground --problem tmp/plan-pr-v2.yaml` command (minimal problem without types) revealed the tool CAN solve simple problems. The `ground` output showed 2 actions with 0 parameters — meaning the preconditions/effects were never parsed.

The fix: change `precondition:` → `preconditions:`, `effect:` → `effects:`, `parameters:` (on fluents) → `params:`.