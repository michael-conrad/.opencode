# [SPEC-FIX] Root Cause Analysis: Issue#1110 Pipeline Breach

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Problem

During implementation of Issue#1110, the orchestrator committed three structural violations in sequence:

1. **Bypassed existing `.issues/` local artifacts** — plan.md, implementation-checklist.md, and ordering.yaml exist on `issues-data` branch but were never pulled into `.issues/1110/spec-artifacts/`. The orchestrator read them from git (proving they existed) but then worked from memory instead of establishing the local workspace.

2. **Created unnecessary GitHub Issue #1111 as a phase tracker** — GitHub Issues in `.opencode` repo are exec-summary only. Full specs, plans, and sub-phase tracking belong in `.issues/<N>/`. The sub-issue API call created stakeholder noise, wasted API quota, and confused anyone watching the repo.

3. **Applied parent-repo workflow patterns to submodule repo** — The `approval-gate` skill's sub-issue requirement was interpreted as `github_sub_issue_write` API calls. In the `.opencode` submodule repo, "sub-issues" means local phase artifacts under `.issues/<N>/spec-artifacts/`, not GitHub Issue API objects.

## Root Cause Chain

- **Causal gap 1:** Orchestrator did not check whether `.issues/1110/` existed locally before reaching for GitHub APIs.
- **Causal gap 2:** Orchestrator conflated approval-gate's "verify sub-issue structure" (which in `.opencode` means local artifacts) with non-existent "create GitHub sub-issues" for a spec that already has full plan+checklist on `issues-data`.
- **Causal gap 3:** No pre-flight check: "Does this repo use `.issues/` + `issues-data` as the primary workspace?" — the `.opencode` repo does. This was detectable via `git ls-tree issues-data --name-only`.

## Fix Requirements

| Requirement | Description | File |
|-------------|-------------|------|
| R-1 | Pull plan.md from `issues-data` to `.issues/1110/spec-artifacts/plan.md` | `.issues/1110/spec-artifacts/plan.md` |
| R-2 | Pull implementation-checklist.md from `issues-data` to `.issues/1110/spec-artifacts/implementation-checklist.md` | `.issues/1110/spec-artifacts/implementation-checklist.md` |
| R-3 | Pull ordering.yaml from `issues-data` to `.issues/1110/spec-artifacts/dependency-ordering-verification/ordering.yaml` | `.issues/1110/spec-artifacts/dependency-ordering-verification/ordering.yaml` |
| R-4 | Ensure pipeline-readiness-gate.md task file exists (already created via sub-agent) | `.opencode/skills/spec-creation/tasks/pipeline-readiness-gate.md` |
| R-5 | Resume implementation using `.issues/1110/spec-artifacts/implementation-checklist.md` as the authoritative step sequence | — |
| R-6 | NEVER create GitHub sub-issues for phase tracking in `.opencode` repo — use `.issues/` local artifacts | — |

| R-7 | When working from submodule directory, `tmp/` artifacts MUST use absolute paths to parent repo's `tmp/` (`/home/muksihs/git/opencode-config/tmp/`), never `./tmp/` which resolves to submodule-local | — |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-R1 | All artifacts pulled from issues-data to `.issues/1110/spec-artifacts/` | `structural` | File existence check |
| SC-R2 | Pipeline-readiness-gate.md task file exists and is valid | `structural` | File exists |
| SC-R3 | All 4 phases implemented per implementation-checklist.md | `behavioral` | `opencode-cli run` for phase completion |
| SC-R4 | `tmp/` artifacts go to main repo `tmp/`, not submodule-local `./tmp/` | `structural` | Verify `./tmp/` is a symlink or resolve to parent |

## Authorization

This fix-spec is part of the authorized scope `for_pr` for Issue#1110. The fix is pre-implementation cleanup — not a separate scope.