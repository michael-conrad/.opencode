> **Full spec and artifacts: [`.opencode/.issues/2161/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2161)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2161/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Holistic label YAML fix — single approval signal chain

## Objective

Establish a single deterministic approval signal chain using `issue.yaml` labels as the source of truth, eliminating the three-way disagreement between `### Status` body field, GitHub API labels, and `issue.yaml` labels.

## Background

The agent currently has no single deterministic signal to determine approval state. Three signal sources exist:

1. **`### Status` in issue body** — proposed by #2159 (now closed, wrong approach). Verified: `grep "### Status" .opencode/skills/approval-gate-scope/tasks/` returns zero matches — the field is already absent from all task files in the approval-gate-scope skill.
2. **GitHub API labels** — read by cascade, but require API availability. Verified: gap-fill cascade files (`for-pr.md`, `for-implementation.md`, `for-plan.md`) already read `issue.yaml` labels via `local-issues read` — not GitHub API.
3. **`issue.yaml` labels** — written by `record-authorization` but never consumed by the gap-fill cascade. Verified: `record-authorization.md` Step 4 writes `approved-for-{scope}` to `issue.yaml` labels locally. Gap-fill cascade reads `issue.yaml` labels.

These three sources can disagree, causing agent paralysis or vibe coding. The fix consolidates on `issue.yaml` labels as the single source of truth, with local-first writes and best-effort remote mirroring.

### Current State (last verified: 2026-07-27T14:36Z via live grep + srclight)

| Component | Status | Evidence |
|-----------|--------|----------|
| `_create_issue_files()` | Already calls `_ensure_needs_approval()` which ensures `needs-approval` is first in labels | `.opencode/tools/local-issues:910-927` |
| `_ensure_needs_approval()` | Exists, ensures `needs-approval` is always in labels list | `.opencode/tools/local-issues:901-907` |
| `### Status` in `record-authorization.md` | Already absent — zero matches in `approval-gate-scope/tasks/` | `grep "### Status" .opencode/skills/approval-gate-scope/tasks/` → 0 matches |
| Gap-fill cascade label reads | Already reads `issue.yaml` labels via `local-issues read` | `for-pr.md:18`, `for-implementation.md:18`, `for-plan.md:18` |
| `record-authorization.md` label writes | Already writes `approved-for-{scope}` to `issue.yaml` locally | `verify-authorization/record-authorization.md:40`, `tasks/record-authorization.md:75` |
| SC-7 critical violation | Already exists in `000-critical-rules.md:281` as `[critical-rules-073]` | `grep "intent to modify" .opencode/guidelines/000-critical-rules.md` → found |

## Not Included

- Changes to the GitHub API label read path (remote mirroring is best-effort, not primary)
- Changes to `spec.md` frontmatter `status` field (retained for backward compatibility)
- Changes to `comments.yaml` authorization records (retained for audit trail)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues create` auto-applies `needs-approval` label to every new issue's `issue.yaml` | `string` | `grep "_ensure_needs_approval" .opencode/tools/local-issues` — confirm function exists and is called by `_create_issue_files` |
| SC-2 | Agent verifies `needs-approval` label exists in local `issue.yaml` after creation — if missing, agent remediates | `behavioral` | `opencode run "create issue"` → assert stderr contains `local-issues read` or `local-issues update --labels +needs-approval` |
| SC-3 | Agent verifies `needs-approval` label exists on remote issue after creation — if missing, agent remediates | `behavioral` | `opencode run "create issue"` → assert stderr contains `github_issue_read` with `get_labels` or `github_issue_add_labels` |
| SC-4 | `record-authorization.md` writes `approved-for-{scope}` label to `issue.yaml` locally before any remote operation | `string` | `grep "approved-for-{scope}" .opencode/skills/approval-gate-scope/tasks/record-authorization.md` — confirm local-first order |
| SC-5 | Gap-fill cascade reads authorization state from `issue.yaml` labels (not GitHub API) | `string` | `grep "issue.yaml" .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/*.md` — confirm all files read local labels |
| SC-6 | `### Status` field removed from issue body template and `record-authorization.md` | `string` | `grep "### Status" .opencode/skills/approval-gate-scope/tasks/` — confirm zero matches |
| SC-7 | New critical violation: reading source files with intent to modify without `for_implementation`+ scope | `string` | `grep "intent to modify" .opencode/guidelines/000-critical-rules.md` — confirm `[critical-rules-073]` section present |
| SC-8 | Agent reads `issue.yaml` labels to determine approval state, not body prose | `behavioral` | `opencode run "check approval state for issue N"` → assert stderr contains `issue.yaml` read, not body prose grep |
| SC-9 | `spec-audit-evaluator.md` removes SC-ADMONISHMENT from narrow criteria list and Step 5i (admonishments are skill-card-specific, not a spec concern) | `string` | `grep "SC-ADMONISHMENT" .opencode/skills/audit/tasks/spec-audit-evaluator.md` — confirm zero matches |

## Requirements

1. `local-issues create` SHALL auto-apply `needs-approval` label to every new issue's `issue.yaml`
2. After creation, agent SHALL verify `needs-approval` label exists in local `issue.yaml` via `local-issues read`
3. If local `needs-approval` is missing, agent SHALL remediate by running `local-issues update --labels +needs-approval`
4. After creation, agent SHALL verify `needs-approval` label exists on the remote issue via `github_issue_read(method=get_labels)`
5. If remote `needs-approval` is missing, agent SHALL remediate by calling `github_issue_add_labels`
6. `record-authorization.md` SHALL write `approved-for-{scope}` to `issue.yaml` locally before any remote API call
7. `record-authorization.md` SHALL mirror the label to GitHub as a best-effort secondary step
8. `record-authorization.md` SHALL remove `needs-approval` label after writing `approved-for-{scope}`
9. Gap-fill cascade SHALL read authorization state from `issue.yaml` labels via `local-issues read`
10. `### Status` field SHALL be removed from `record-authorization.md` procedure
11. `000-critical-rules.md` SHALL include a Tier 1 critical violation: reading source files with intent to modify constitutes implicit self-authorization
12. Agent SHALL read `issue.yaml` labels to determine approval state, not body prose
13. `spec-audit-evaluator.md` Step 5i SHALL emit PASS (not N/A) for non-skill/task card audits

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-1 | Verify `_create_issue_files()` already calls `_ensure_needs_approval()` — add behavioral test confirming agent behavior |
| 2 | SC-2, SC-3 | Add verification step after creation: agent reads local `issue.yaml` and remote labels, remediates if `needs-approval` missing from either |
| 3 | SC-4 | Verify `record-authorization.md` already writes `approved-for-{scope}` to `issue.yaml` locally — add behavioral test |
| 4 | SC-5 | Verify gap-fill cascade already reads `issue.yaml` labels — add behavioral test |
| 5 | SC-6 | Verify `### Status` already absent from `record-authorization.md` — add structural test |
| 6 | SC-7 | Verify `[critical-rules-073]` already exists in `000-critical-rules.md` — add structural test |
| 7 | SC-8 | Add behavioral enforcement test verifying agent reads `issue.yaml` labels, not body prose |
| 8 | SC-9 | Fix `spec-audit-evaluator.md` Step 5i to emit PASS (not N/A) for non-skill/task card audits |

## Edge Cases

| Condition | Expected Behavior | Recovery |
|-----------|------------------|----------|
| `local-issues read` fails (tool unavailable) | Agent reports BLOCKED with `ISSUES_WORKTREE_NOT_INITIALIZED` | Developer runs `local-issues init` to bootstrap worktree |
| GitHub API unreachable for remote label verification | Agent skips remote verification, proceeds with local-only state | Remote label sync occurs on next `local-issues sync` cycle |
| `issue.yaml` missing `labels` field entirely | Agent treats as empty labels list, remediates by adding `needs-approval` | `local-issues update --labels +needs-approval` creates the field |
| `issue.yaml` has malformed YAML | Agent reports BLOCKED with `MALFORMED_ISSUE_YAML` | Developer fixes YAML syntax in `.issues/{N}/issue.yaml` |
| Concurrent label modification (local write succeeds, remote write fails) | Local state is authoritative — remote is best-effort mirror | Remote inconsistency resolved on next `local-issues sync` |
| Issue creation fails before label write | No issue created — no label state to manage | Agent retries creation; if persistent, reports BLOCKED |
| `needs-approval` already present in labels | Idempotent — no change needed | Agent skips update, reports success |
| `approved-for-{scope}` write to `issue.yaml` fails | Agent reports BLOCKED with `COMMIT_FAILED` | Developer resolves git conflict in `.issues/` worktree |

## Documentation Sources

| Source | Path | Purpose |
|--------|------|---------|
| `local-issues` tool | `.opencode/tools/local-issues` | Issue creation, label read/write, worktree management |
| `record-authorization.md` | `.opencode/skills/approval-gate-scope/tasks/record-authorization.md` | Local-first label write procedure |
| `record-authorization.md` (verify-authorization) | `.opencode/skills/approval-gate-scope/tasks/verify-authorization/record-authorization.md` | Authorization recording with `issue.yaml` label update |
| Gap-fill cascade files | `.opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/for-*.md` | Authorization state reading from `issue.yaml` labels |
| `000-critical-rules.md` | `.opencode/guidelines/000-critical-rules.md` | Tier 1 critical violation definitions |
| GitHub API (label operations) | `github_issue_read(method=get_labels)`, `github_issue_add_labels` | Remote label verification and mirroring |

## Cost Frame

Verification cost is measured in **defect-discovery-latency (DDL)** — the time between defect introduction and discovery. Shorter DDL means cheaper fixes; longer DDL means exponentially compounding cost.

| SC | DDL Frame | Death Spiral Risk | Break Point |
|----|-----------|-------------------|-------------|
| SC-1 | String grep — ~1s execution, catches missing `_ensure_needs_approval` at commit time | Low — structural check at pre-commit gate | Pre-commit |
| SC-2 | Behavioral test — ~2min execution, catches agent skipping local label verification | Medium — behavioral defect would ship to CI | Pre-PR |
| SC-3 | Behavioral test — ~2min execution, catches agent skipping remote label verification | Medium — behavioral defect would ship to CI | Pre-PR |
| SC-4 | String grep — ~1s execution, catches wrong write order | Low — structural check at pre-commit gate | Pre-commit |
| SC-5 | String grep — ~1s execution, catches wrong label source | Low — structural check at pre-commit gate | Pre-commit |
| SC-6 | String grep — ~1s execution, catches `### Status` re-introduction | Low — structural check at pre-commit gate | Pre-commit |
| SC-7 | String grep — ~1s execution, catches missing critical violation | Low — structural check at pre-commit gate | Pre-commit |
| SC-8 | Behavioral test — ~2min execution, catches agent reading body prose instead of labels | High — behavioral defect would cause agent paralysis in production | Pre-PR |
| SC-9 | String grep — ~1s execution, catches N/A re-introduction in evaluator task | Low — structural check at pre-commit gate | Pre-commit |

## SC Enforcement Gate

**All SCs MUST pass before this fix is considered complete. No partial delivery is permitted — if any SC fails, the entire fix is BLOCKED until remediation resolves the failure.** This is a hard gate: a single FAIL among the 9 SCs blocks advancement to PR creation. The 3 behavioral SCs (SC-2, SC-3, SC-8) require clean-room semantic evaluation — grep/string evidence is insufficient for behavioral SCs.

## Note on SC-7 Scope

SC-7 (new critical violation for read-with-intent-to-modify) addresses a related but independent concern from the spec's primary root cause (three-way signal disagreement). SC-7 was included because it shares implementation scope with the label YAML changes (both modify `000-critical-rules.md` and `approval-gate-scope` task files). It is not orphaned — it is a co-located improvement that benefits from the same implementation pass. The root cause for SC-7 is: "The agent currently has no explicit prohibition against reading source files with intent to modify without authorization scope, creating an implicit self-authorization loophole."

## Dependencies

- **#1538** (needs revision to align with local-first model — dependent on this spec)
- **#2057** (blocked by this spec — modifies same task files)

## Traceability

| Requirement | SCs | Items |
|-------------|-----|-------|
| REQ-1 | SC-1 | 1 |
| REQ-2, REQ-3 | SC-2 | 2 |
| REQ-4, REQ-5 | SC-3 | 2 |
| REQ-6, REQ-7, REQ-8 | SC-4 | 3 |
| REQ-9 | SC-5 | 4 |
| REQ-10 | SC-6 | 5 |
| REQ-11 | SC-7 | 6 |
| REQ-12 | SC-8 | 7 |
| REQ-13 | SC-9 | 8 |
