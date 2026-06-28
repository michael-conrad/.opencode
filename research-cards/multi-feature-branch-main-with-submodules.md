<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-assisted -->

---
name: multi-feature-branch-main-with-submodules
confidence: 0.7
tags: [branch-management, submodules, trunk-based-development, shared-dependencies]
created: 2026-06-27
status: draft
gap: pr-target hardcoded to dev; missing branch naming convention and rebase strategy for stacked feature→main
---

# Research Card: Multi-Feature Branch Management Against `main` Without `dev`, with Shared Submodule Dependencies

## Overview

Investigating how to reliably work against multiple parallel GitHub Issues on a single working feature branch (or set of stacked PRs) targeting `main` directly, without an intermediate `dev` integration branch — in the context of repos that use Git submodules as shared common code across many parent repositories.

## Problem Statement

Current workflow: `<feature-branch> → dev → main`. This creates problems for repos with large numbers of submodules:
- `dev` and `main` develop different submodule pointer commits, causing drift between them
- Developers on feature branches see inconsistent submodule states depending on their base branch
- Submodule pointers become the most frequently conflicted merge target

Desired workflow: `<feature-branch> → main` (no `dev`). Multiple parallel issues work against one working branch; PRs converge directly on `main`.

## Constraints

1. **Submodules are shared common code** (POJOs, REST definitions, utilities) across a very large number of parent repos
2. **`main` must be protected** — only alterable via PR requests with review
3. **Multiple parallel issues** need to be worked against the same working branch reliably
4. Previous attempts at tag-based and release-tag tracking for submodules failed due to agent skill deficiencies (will require dedicated specs)

## Key Findings from Research

### Trunk-Based Development (TBD) — Established Pattern for `<feature> → main`

Per [trunkbaseddevelopment.com](https://trunkbaseddevelopment.com/), trunk-based development is the established name for your desired pattern: short-lived feature branches converging directly on `main`, with no intermediate dev/staging branch. Key principles:

- **Short-lived branches**: Days, not weeks — keeps divergence manageable
- **CI as safety net** replaces the testing buffer that `dev` traditionally provides (required PR reviews + passing CI)
- **Continuous code review** happens before merge, not after
- **Google scales this to 35k developers** in a single monorepo trunk
- **Feature flags and branch-by-abstraction** handle longer-running work without breaking main

This maps directly to your workflow: multiple parallel issues on short-lived feature branches (stacked commits), PRs converge directly on `main`. The safety mechanisms are CI gating + required reviews.

### GitHub Flow Alignment

GitHub Flow is essentially TBD adapted for open source/PR-based workflows — exactly what you're describing. It's the same `<feature> → main` model with:
- One integration branch (`main`)
- Feature branches created from `main`, merged back via PR
- No release/dev branches — releases happen directly from main

### Tag-Based Submodule Pinning at Dev Start

Your approach is sound within a single repo. When work starts on a feature branch, pin all submodules to their latest tagged commit (via SHA). This gives you:
- **Deterministic dependency state** for the entire duration of that feature branch's life
- **No pointer drift** during development — submodules stay fixed regardless of upstream activity in the submodule repos
- **Clean release PR** — the only submodule change is the pinned SHAs, which become what main ships with

The remaining question within a single repo: when you merge your release PR into `main`, do you also need to update dev's submodule pins? If there's no dev branch (per your desired model), this doesn't apply.

## Confirmed Workflow

Based on discussion, the target workflow is:

1. **Short-lived feature branches** (hours/days, not weeks) for individual issue tickets — each branch handles one or more related issues via stacked commits
2. **Multiple parallel issues** can be worked against an existing feature branch by adding commits to it
3. **Rebase onto main when PR is ready** — not continuously during development, just before merge to ensure clean convergence on main
4. **PR directly from feature → main** — no intermediate dev staging area
5. **Submodule pinning at dev start** — all submodules pinned to latest tagged commit SHAs; these pins stay fixed for the branch's lifetime and carry through via release PR

This eliminates the `dev` branch entirely, removing the source of submodule pointer divergence between development integration and mainline while keeping the safety mechanisms (CI gating + required reviews) that were previously provided by dev as a staging buffer.

## Research Gaps — What Actually Needs Investigation

Based on examining the actual skill deck (not guessing), here's what exists and what doesn't:

### Already Defined in Skill Deck ✅

**Stacked PRs:** `pr_strategy: stacked` defined in git-workflow SKILL.md line 43 + pr-creation-workflow SKILL.md line 75. Each issue maps to one commit; all commits go into a single PR. The skill deck already supports this pattern targeting dev.

**CI/CD Safety:** Agent handles CI gating through `pre-pr-checklist` and `review-prep` tasks (pr-creation-workflow §5). Changelog, diff review, squash verification — all defined. No research gap here.

**Submodule Tagging:** Full system exists:
- `submodule-tag-prework`: Hash permanence tags at pre-work Step 3.5
- `submodule-feature-push`: Tip tag management in review-prep
- `submodule-liveness-check`: PR-time hash reachability verification
- `submodule-dev-restore`: Cleanup submodule restoration to dev tip

**Branch Cleanup:** Defined in cleanup/branch-cleanup.md — local + remote deletion after PR merge, with parallel work tracking.

### What's Missing — Real Gaps 🔍

1. **PR target is hardcoded to `dev`**, not configurable to `main`. The skill deck explicitly states "Base branch = dev for feature PRs" (pr-creation-workflow §5.2). There is no `<feature> → main` path in the existing skills — this is a new workflow pattern, not an existing one.

2. **Branch naming convention for stacked multi-issue branches** exists as variable (`<branch-name>`) but has no concrete naming standard when multiple issues are involved (e.g., `feature/42-43-topic` vs `feature/issues-42,43`).

3. **Rebase timing strategy for stacked feature branches** — the skill deck has a `rebase-pending` task but doesn't define *when* rebasing should happen during development of a multi-issue branch (continuous? before PR only? after each issue?). This is critical for keeping divergence manageable with short-lived branches targeting main.

4. **Stacked commit rebase strategy at merge time** — when 3+ commits are stacked and need to converge on `main`, the skill deck only supports squash at PR creation (currently targeting dev). The question of whether to:
   - Rebase entire branch onto main (rewriting all commits)
   - Create a release-merge commit preserving history
   - Squash everything at PR creation
   
   ...is not defined in any existing task.

## Next Steps

1. Draft spec for `<feature> → main` workflow — requires modifying pr-creation-workflow and git-workflow skills to support `main` as an alternative feature PR target
2. Define branch naming convention for stacked multi-issue branches
3. Design rebase strategy for stacked feature branches targeting main (not dev)
