# Plan — [SPEC-FIX] Fix issues-data URL construction and plan-file repo routing

**Spec:** [michael-conrad/.opencode#1321](https://github.com/michael-conrad/.opencode/issues/1321)
**Authorization scope:** `for_pr` (auto-approved)
**Halt at:** `pr_created`
**PR strategy:** `stacked`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Goal

Fix the issues-data URL construction to use platform-agnostic `{html_url}/{owner}/{repo}/tree/issues-data/{N}` pattern with per-repo resolution, reconcile the two conflicting `.issues/AGENTS.md` directory layouts, add `local-issues sync-file` subcommand, and add repo-routing rules to the plan-creation workflow.

## Architecture

This is a SPEC-FIX spanning two repos (root `opencode-config` and `.opencode` submodule). Changes are in skill task files, AGENTS.md files, and the `local-issues` CLI tool. No runtime code changes — all changes are to agent-facing configuration and tooling.

## Tech Stack

- Shell (local-issues CLI)
- Markdown (AGENTS.md, skill task files)
- YAML (contracts)

---

### Phase 1: Fix URL Patterns in spec-creation/tasks/write.md

**Concern:** Entering URL construction fix. Prior scope: none (first phase). Handoff: none.
**Files:** `skills/spec-creation/tasks/write.md` (Steps 6.8 and 7r)
**SCs covered:** SC-1, SC-2, SC-3, SC-7

#### Pre-RED Common

- [ ] 1. Verification gate (**clean-room**). Run `verification-enforcement --task verify` to collect evidence artifacts for current URL patterns in `write.md`. → SC-1, SC-2
- [ ] 2. Read approved spec (**inline**). Extract URL patterns, per-repo resolution rules, and substitution verification requirements from `.opencode/.issues/1321/spec.md`. → SC-1, SC-2, SC-3, SC-7
- [ ] 3. Read current `write.md` (**clean-room**). Glob `skills/spec-creation/tasks/write.md` and read Steps 6.8 and 7r to understand current URL construction. → SC-1, SC-2

#### Per-Item RED+green Chains

- [ ] 4. TDD-1: Fix Step 7r URL pattern (SC-1)
  - [ ] 1. RED (**clean-room**). Write behavioral test: send agent prompt to create spec → verify stderr does NOT contain `tree/issues-data/.issues/` pattern. Test fails because current code produces `.issues/` prefix.
  - [ ] 2. GREEN (**clean-room**). Replace Step 7r URL construction with `{html_url}/{owner}/{repo}/tree/issues-data/{N}` pattern. Remove `.issues/` prefix. Remove hardcoded `github.html_url`. Add per-repo resolution rule referencing session-init `## Repo Information`. Add substitution verification step (HALT if `{html_url}` placeholder remains literal).

- [ ] 5. TDD-2: Fix Step 6.8 URL pattern to match Step 7r (SC-2)
  - [ ] 1. RED (**clean-room**). Write behavioral test: send agent prompt → verify Step 6.8 URL does NOT use hardcoded `github.html_url`. Test fails because current code hardcodes GitHub.
  - [ ] 2. GREEN (**clean-room**). Update Step 6.8 URL construction to match Step 7r pattern. Add cross-reference to `.issues/AGENTS.md`. Verify both steps use identical `{html_url}/{owner}/{repo}/tree/issues-data/{N}` pattern.

- [ ] 6. TDD-3: Add per-repo resolution rule (SC-3)
  - [ ] 1. RED (**clean-room**). Write content-verification test: grep for `session-init` or `Repo Information` in URL construction instructions. Test fails because no per-repo resolution rule exists.
  - [ ] 2. GREEN (**clean-room**). Add explicit per-repo resolution rule: `html_url`, `owner`, `repo` MUST come from session-init repo entry whose `path` matches the issue's repo. Add substitution verification: after URL construction, verify `{html_url}` was substituted (not left as literal placeholder). If placeholder remains, HALT with blocker.

- [ ] 7. TDD-4: URL resolves to valid page (SC-7)
  - [ ] 1. RED (**clean-room**). Write behavioral test: construct URL using current pattern → `webfetch` returns 404. Test fails because current URL is broken.
  - [ ] 2. GREEN (**clean-room**). After fix, construct URL using new pattern → `webfetch` returns 200. Test with both GitHub and GitBucket URL patterns.

#### Post-RED/green

- [ ] 8. Completeness gate (**clean-room**). Run `completeness-gate` to verify all SCs in Phase 1 have evidence artifacts. → SC-1, SC-2, SC-3, SC-7
- [ ] 9. Adversarial audit (**orchestrator multi-dispatch**). Run `resolve-models` → dispatch `adversarial-audit --task spec-audit` with auditor_1 → remediate on non-clean-pass → same audit with auditor_2 → cross-validate. → SC-1, SC-2, SC-3, SC-7
- [ ] 10. Regression check (**clean-room**). Run `test-driven-development --task patterns` to verify no other URL patterns in `write.md` were broken. → SC-1, SC-2

---

### Phase 2: Reconcile .issues/AGENTS.md Directory Layouts

**Concern:** Entering AGENTS.md reconciliation. Prior scope: Phase 1 (URL patterns). Handoff: Phase 1 established the canonical URL pattern `{html_url}/{owner}/{repo}/tree/issues-data/{N}` — this phase uses that pattern in AGENTS.md cross-references.
**Files:** `.opencode/.issues/AGENTS.md`, `.issues/AGENTS.md`
**SCs covered:** SC-4

#### Pre-RED Common

- [ ] 1. Verification gate (**clean-room**). Run `verification-enforcement --task verify` to collect evidence of current directory layout in both AGENTS.md files. → SC-4
- [ ] 2. Read approved spec (**inline**). Extract reconciliation requirements: flat layout (`{N}/plan.md`) is canonical; non-canonical file references canonical. → SC-4

#### Per-Item RED+green Chains

- [ ] 3. TDD-5: Make `.opencode/.issues/AGENTS.md` canonical with flat layout (SC-4)
  - [ ] 1. RED (**clean-room**). Write content-verification test: grep for `spec-artifacts/` in `.opencode/.issues/AGENTS.md`. Test fails if flat layout is already canonical (no `spec-artifacts/`).
  - [ ] 2. GREEN (**clean-room**). Update `.opencode/.issues/AGENTS.md` to declare flat layout (`{N}/plan.md`) as canonical. Remove any `spec-artifacts/` references. Add `canonical` marker.

- [ ] 4. TDD-6: Update `.issues/AGENTS.md` to reference canonical (SC-4)
  - [ ] 1. RED (**clean-room**). Write content-verification test: grep for `canonical` or `see` cross-reference in `.issues/AGENTS.md`. Test fails because no cross-reference exists.
  - [ ] 2. GREEN (**clean-room**). Update `.issues/AGENTS.md` to reference `.opencode/.issues/AGENTS.md` as canonical. Change directory layout from `spec-artifacts/plan.md` to flat `plan.md`. Add cross-reference: "See `.opencode/.issues/AGENTS.md` for the canonical directory layout."

#### Post-RED/green

- [ ] 5. Completeness gate (**clean-room**). Run `completeness-gate` to verify SC-4 evidence. → SC-4
- [ ] 6. Adversarial audit (**orchestrator multi-dispatch**). Run `resolve-models` → dispatch `adversarial-audit --task spec-audit` with auditor_1 → remediate → auditor_2 → cross-validate. → SC-4

---

### Phase 3: Add local-issues sync-file Subcommand

**Concern:** Entering CLI tool change. Prior scope: Phase 2 (AGENTS.md). Handoff: Phase 2 established flat layout — `sync-file` writes to `{N}/plan.md` directly.
**Files:** `tools/local-issues`
**SCs covered:** SC-5

#### Pre-RED Common

- [ ] 1. Verification gate (**clean-room**). Run `verification-enforcement --task verify` to collect evidence of current `local-issues` subcommands. → SC-5
- [ ] 2. Read approved spec (**inline**). Extract `sync-file` requirements: accepts file path, resolves correct worktree, handles commit+push. → SC-5

#### Per-Item RED+green Chains

- [ ] 3. TDD-7: Add `local-issues sync-file` subcommand (SC-5)
  - [ ] 1. RED (**clean-room**). Write behavioral test: `opencode-cli run` with agent creating plan file → verify stderr does NOT show `local-issues sync-file` call. Test fails because no sync-file subcommand exists.
  - [ ] 2. GREEN (**clean-room**). Add `sync-file` subcommand to `local-issues` tool. Accepts file path argument. Resolves correct worktree from file path prefix (`.opencode/.issues/` → `.opencode` repo worktree; `.issues/` → root repo worktree). Handles `git add`, `git commit`, `git push` in the correct worktree. Outputs commit SHA and file URL on success.

#### Post-RED/green

- [ ] 4. Completeness gate (**clean-room**). Run `completeness-gate` to verify SC-5 evidence. → SC-5
- [ ] 5. Adversarial audit (**orchestrator multi-dispatch**). Run `resolve-models` → dispatch `adversarial-audit --task spec-audit` with auditor_1 → remediate → auditor_2 → cross-validate. → SC-5

---

### Phase 4: Add Repo-Routing Rule to Writing-Plans

**Concern:** Entering plan-creation workflow change. Prior scope: Phase 3 (local-issues sync-file). Handoff: Phase 3 provides `sync-file` as the push mechanism — this phase adds the routing rule that determines which repo to use.
**Files:** `skills/writing-plans/tasks/write.md`, `skills/writing-plans/SKILL.md`
**SCs covered:** SC-6

#### Pre-RED Common

- [ ] 1. Verification gate (**clean-room**). Run `verification-enforcement --task verify` to collect evidence of current plan-creation workflow. → SC-6
- [ ] 2. Read approved spec (**inline**). Extract repo-routing requirements: determine which repo owns the spec via session-init, place plan in that repo's `.issues/` worktree. → SC-6

#### Per-Item RED+green Chains

- [ ] 3. TDD-8: Add repo-routing rule to writing-plans/tasks/write.md (SC-6)
  - [ ] 1. RED (**clean-room**). Write content-verification test: grep for repo-routing rule in `writing-plans/tasks/write.md`. Test fails because no rule exists.
  - [ ] 2. GREEN (**clean-room**). Add repo-routing step to plan-creation workflow: determine which repo owns the spec issue by matching the issue's repo path against session-init `## Repo Information` entries. Place plan file in that repo's `.issues/` worktree. Use `local-issues sync-file` for commit+push. URL MUST use that repo's `html_url`, `owner`, `repo`.

- [ ] 4. TDD-9: Add repo-routing to writing-plans/SKILL.md Operating Protocol (SC-6)
  - [ ] 1. RED (**clean-room**). Write content-verification test: grep for repo-routing in `writing-plans/SKILL.md` Operating Protocol. Test fails because no reference exists.
  - [ ] 2. GREEN (**clean-room**). Add repo-routing step to Operating Protocol section: after plan file is written, route through `local-issues sync-file` for commit+push in the correct repo's worktree.

#### Post-RED/green

- [ ] 5. Completeness gate (**clean-room**). Run `completeness-gate` to verify SC-6 evidence. → SC-6
- [ ] 6. Adversarial audit (**orchestrator multi-dispatch**). Run `resolve-models` → dispatch `adversarial-audit --task spec-audit` with auditor_1 → remediate → auditor_2 → cross-validate. → SC-6

---

### Post-All-Phases Sweep

- [ ] 1. FINISHING CHECKLIST (**clean-room**). Run `finishing-a-development-branch --task checklist`: git status clean, lint/typecheck from scratch, coverage sweep.
- [ ] 2. PR CREATION (**clean-room**). Run `git-workflow --task review-prep` then `git-workflow --task pr-creation`. Extract `html_url` from `github_create_pull_request` response.
- [ ] 3. POST-MERGE CLEANUP (**clean-room**). Run `git-workflow --task cleanup`: delete merged branches, close issues, sync dev.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
