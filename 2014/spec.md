## Bug Description

The `pre-red-baseline` task in `implementation-pipeline` has a SUBMODULE-DRIFT check that BLOCKs when the `.opencode` submodule is on a feature branch instead of `main` tip.

## Problem

This is too strict for stacked PR workflows where the submodule is intentionally on a feature branch (the parent repo's feature branch tracks the submodule's feature branch). The check blocks legitimate stacked PR development.

## Root Cause

The check treats ANY deviation from `main` tip as drift, including being on a feature branch. In stacked PR workflows, the submodule is intentionally on a feature branch to match the parent repo's feature branch.

## Suggested Fix

The check should only flag drift when the submodule is on:
- DETACHED HEAD (unintentional state)
- An UNKNOWN branch (not a recognized feature branch)

Being on a feature branch is expected in stacked PR workflows and should NOT trigger a BLOCKED status.

## Impact

Blocks stacked PR development workflow. Developers must work around the check or disable it, defeating its purpose.