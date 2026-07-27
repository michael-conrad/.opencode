> **Full spec and artifacts: [`.opencode/.issues/2161/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2161)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2161/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Holistic label YAML fix — single approval signal chain

## Objective

Establish a single deterministic approval signal chain using `issue.yaml` labels as the source of truth, eliminating the three-way disagreement between `### Status` body field, GitHub API labels, and `issue.yaml` labels.

## Background

The agent currently has no single deterministic signal to determine approval state. Three signal sources exist:

1. **`### Status` in issue body** — proposed by #2159 (now closed, wrong approach)
2. **GitHub API labels** — read by cascade, but require API availability
3. **`issue.yaml` labels** — written by `record-authorization` but never consumed by the gap-fill cascade

These three sources can disagree, causing agent paralysis or vibe coding. The fix consolidates on `issue.yaml` labels as the single source of truth, with local-first writes and best-effort remote mirroring.

## Not Included

- Changes to the GitHub API label read path (remote mirroring is best-effort, not primary)
- Changes to `spec.md` frontmatter `status` field (retained for backward compatibility)
- Changes to `comments.yaml` authorization records (retained for audit trail)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `local-issues create` auto-applies `needs-approval` label to every new issue's `issue.yaml` | `string` |
| SC-2 | Agent verifies `needs-approval` label exists in local `issue.yaml` after creation — if missing, agent remediates | `behavioral` |
| SC-3 | Agent verifies `needs-approval` label exists on remote issue after creation — if missing, agent remediates | `behavioral` |
| SC-4 | `record-authorization.md` writes `approved-for-{scope}` label to `issue.yaml` locally before any remote operation | `string` |
| SC-5 | Gap-fill cascade reads authorization state from `issue.yaml` labels (not GitHub API) | `string` |
| SC-6 | `### Status` field removed from issue body template and `record-authorization.md` | `string` |
| SC-7 | New critical violation: reading source files with intent to modify without `for_implementation`+ scope | `string` |
| SC-8 | Agent reads `issue.yaml` labels to determine approval state, not body prose | `behavioral` |

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

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-1 | Change `_create_issue_files()` labels default from `[]` to `["needs-approval"]` |
| 2 | SC-2, SC-3 | Add verification step after creation: agent reads local `issue.yaml` and remote labels, remediates if `needs-approval` missing from either |
| 3 | SC-4 | Rewrite `record-authorization.md` Step 4: local-first label write, then remote mirror, then remove `needs-approval` |
| 4 | SC-5 | Update gap-fill cascade to read `issue.yaml` labels via `local-issues read` instead of GitHub API |
| 5 | SC-6 | Remove `### Status` field from `record-authorization.md` procedure and exit criteria |
| 6 | SC-7 | Add Tier 1 critical violation to `000-critical-rules.md` |
| 7 | SC-8 | Add behavioral enforcement test verifying agent reads `issue.yaml` labels, not body prose |

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
