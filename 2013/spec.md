## Description

The `pre-red-baseline` task in `implementation-pipeline` has a SUBMODULE-DRIFT check that BLOCKs when the `.opencode` submodule is on a feature branch instead of `main` tip. This is too strict for stacked PR workflows where the submodule is intentionally on a feature branch.

## The Problematic Check

The SUBMODULE-DRIFT check in `pre-red-baseline` compares the submodule HEAD against `main` tip and BLOCKs on any mismatch. It does not distinguish between:
- **Detached HEAD** (unintentional, should block)
- **Unknown/untracked branch** (should block)
- **Feature branch** (intentional in stacked PR workflows - should NOT block)

## Why It Blocks Stacked PR Workflows

In a stacked PR workflow, the parent repo creates a feature branch (e.g. `feature/1962-writing-plans-workflow-fix`) and the `.opencode` submodule tracks a corresponding feature branch. This is expected behavior - the submodule is intentionally on a feature branch that matches the parent repo's branch. The SUBMODULE-DRIFT check should not flag this as drift.

## Suggested Fix

Modify the SUBMODULE-DRIFT check to only flag drift when:
- The submodule is on a **detached HEAD** (not pointing to any branch)
- The submodule is on an **unknown branch** (not `main` and not a recognized feature branch pattern)

Being on a feature branch should be accepted as valid state in stacked PR workflows.