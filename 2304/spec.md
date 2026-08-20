---
title: '[SPEC] Standardize remote branch-tip terminology across skilldeck and guidelines'
status: open
labels:
- needs-approval
- spec-draft
remote_issue: 2304
remote_url: https://github.com/michael-conrad/.opencode/issues/2304
promoted_at: '2026-08-19T22:58:42+00:00'
---

> **Full spec and artifacts: [`.opencode/.issues/2304/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2304)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2304/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Standardize remote branch-tip terminology

## 1. Intent and Executive Summary

**Problem Statement:** The skilldeck and guidelines use inconsistent branch-tip terminology. Prose in many skill cards and task cards reads "at trunk tip", "verify trunk tip", "dev tip", "feature-branch tip", or bare branch names ("dev", "master") without the remote qualifier. When an agent reads "trunk tip" unqualified, it assumes the stale LOCAL branch tip is authoritative and never consults the remote (`origin/`) tip — causing starting work from a stale base. The verification enforcement already compares against `origin/$DEFAULT_BRANCH` (e.g., `trunk-tip-verification.md` Steps 3 and 6), but the prose labels do not communicate that the REMOTE tip is the source of truth.

**Root Cause / Motivation:** The prose terminology predates the trunk-based workflow and was never standardized. The 6 existing "remote trunk tip" sites in `create-pr.md` and `trunk-tip-verification.md` (F6) prove the remote-prefixed model is already the intended vocabulary, but ~21 unqualified "trunk tip" lines (F1/F2) plus 5 "dev tip" lines (F3) and hardcoded "dev"/"master" branch names (F5) remain. This inconsistency lets agents escape-hatch onto stale local tips, which is the exact defect the verification gate was built to prevent. It must be fixed now because every agent that reads these cards is a consumer of the ambiguity.

**Approach Chosen:** Perform a holistic documentation-only terminology sweep across `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, and `AGENTS.md`. Every branch-tip reference is standardized to "remote `<branch>` branch tip" or "`origin/<branch>`" so the agent always reads that the remote `origin/` tip is authoritative. All sites align with the existing model pattern in `create-pr.md` ("remote trunk tip SHA") and `enforcement-gate.md` ("remote trunk HEAD SHAs"). The `$DEFAULT_BRANCH` / `origin/$DEFAULT_BRANCH` vocabulary replaces hardcoded branch names. The verification enforcement gates (Steps 3/6 fetch+compare) are left byte-identical.

**Alternatives Considered & Why Discarded:**
- **In place:** Modify the verification gate to auto-detect the remote tip and refuse stale local base. **Discarded:** this changes enforcement behavior, which is explicitly out of scope; the verification already correctly compares against `origin/$DEFAULT_BRANCH`. The defect is prose miscommunication, not logic.
- **Abandoned / leave as-is:** accept the inconsistency. **Discarded:** leaves the escape-hatch that lets agents start from stale local bases, defeating the verification gate's purpose.

**Key Design Decisions:**
- **Remote qualifier is mandatory on all branch-tip prose** — "trunk tip" always becomes "remote trunk tip"; bare "dev"/"master" branch names become `$DEFAULT_BRANCH` / `origin/$DEFAULT_BRANCH`. **Tradeoff:** verbosity increases slightly in prose, but removes the ambiguity that currently lets agents assume local-tip authority.
- **Enforcement logic untouched** — `trunk-tip-verification.md` Steps 3/6 remain byte-identical; only prose labels change. **Tradeoff:** a structural guard (SC-3) is required to prove the sweep never altered a git command.
- **Behavioral regression guard** — SC-4 adds a behavioral tests-v2 scenario asserting the agent consults `origin/$DEFAULT_BRANCH`. **Tradeoff:** adds a behavioral test to the suite, but it is the only evidence that proves the prose change actually changes agent behavior.

**User Intent / Original Prompt:** Standardize remote branch-tip terminology across the skilldeck and guidelines so agents read the remote `origin/` tip as authoritative, eliminating stale-base starts.

## 2. Not Included

- **Verification enforcement logic** — any change to `trunk-tip-verification.md` Steps 3/6 fetch+compare is excluded; the enforcement gate already correctly compares against `origin/$DEFAULT_BRANCH`.
- **Branch naming conventions** — the `feature/*`, `spec/*`, `pair-*` naming scheme is untouched.
- **Git workflow behavior** — no command, config, or workflow behavior change.
- **Parent `opencode-config` repo** — all sweep targets resolve under `.opencode/` in the `.opencode` repo; the parent repo is out of scope.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Structural scan across `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, and `AGENTS.md` returns zero unqualified branch-tip references remaining (`trunk tip`, `dev tip`, `feature-branch tip`, and hardcoded `dev`/`master` branch-tip names). | string | `rg -i 'trunk tip|dev tip|feature-branch tip'` on the four directories, plus a `rg` assertion for hardcoded `dev`/`master` in branch-tip contexts; expect zero non-remote matches |
| SC-2 | All `trunk tip` prose sites standardized to `remote trunk tip` / `remote $DEFAULT_BRANCH tip`. | string | `rg -i 'remote .*trunk tip'` returns the full sweep set; `rg -i 'trunk tip'` returns only remote-qualified sites (no unqualified matches) |
| SC-3 | `trunk-tip-verification.md` Steps 3/6 fetch+compare against `origin/$DEFAULT_BRANCH` remain byte-identical to pre-change state. | structural | `git diff` of `trunk-tip-verification.md` scoped to prove only prose lines changed; assert Steps 3/6 git commands unchanged |
| SC-4 | Behavioral tests-v2 scenario asserts the agent consults `origin/$DEFAULT_BRANCH` rather than a stale local tip. | behavioral | `bash .opencode/tests-v2/with-test-home opencode run '<real-domain prompt>'`; assert stderr shows agent consulting `origin/$DEFAULT_BRANCH` via `assert_stderr_pattern_present` |

## 4. Requirements

R-1. The prose SHALL standardize every unqualified `trunk tip` reference to `remote trunk tip` / `remote $DEFAULT_BRANCH tip` across `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, and `AGENTS.md`.
R-2. The prose SHALL standardize `dev tip` and hardcoded `dev`/`master` branch-name prose to `remote $DEFAULT_BRANCH tip` / `$DEFAULT_BRANCH` / `origin/$DEFAULT_BRANCH`.
R-3. The prose SHALL standardize `feature-tip` to `remote feature branch tip` / `remote $DEFAULT_BRANCH tip`.
R-4. The sweep SHALL use `$DEFAULT_BRANCH` / `origin/$DEFAULT_BRANCH` vocabulary in place of hardcoded branch names.
R-5. The stale `dev tip` and `dev`/`master` branch-name terminology SHALL be retired from all branch-tip prose.
R-6. A full scan SHALL cover `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, and `AGENTS.md` for all unqualified branch-tip references.
R-7. The sweep SHALL align all sites with the existing model pattern in `create-pr.md` ("remote trunk tip SHA") and `enforcement-gate.md` ("remote trunk HEAD SHAs").
R-8. The verification enforcement logic in `trunk-tip-verification.md` Steps 3/6 SHALL remain UNCHANGED (documentation-only change).
R-9. The change SHALL be documentation-only; no code, config, or workflow behavior SHALL change.
R-10. The parent `opencode-config` repo SHALL remain out of scope.
R-11. No branch naming convention or git workflow behavior SHALL change.
R-12. All changes SHALL belong to the `.opencode` repo, not the root repo.
R-13. A behavioral regression test SHALL assert the agent consults `origin/$DEFAULT_BRANCH` rather than a stale local branch tip.

## 5. Items

### Item 1 (SC-1): Structural scan gate enforcing zero unqualified branch-tip references

- RED: rg scan shows unqualified `trunk tip`, `dev tip`, `feature-tip` and hardcoded `dev`/`master` references present.
- GREEN: sweep completes; rg scan returns zero remaining unqualified references.
- verify: `rg` run across the four directories asserting zero unqualified matches.
- commit: the scan assertion script together with the sweep changes.

### Item 2 (SC-2): Standardize all `trunk tip` prose to `remote` qualifier

- RED: `rg 'trunk tip'` returns unqualified sites.
- GREEN: all `trunk tip` prose is remote-prefixed.
- verify: `rg -i 'trunk tip'` returns only `remote`-prefixed matches.
- commit: the `trunk tip` prose sweep changes.

### Item 3 (SC-3): Verify `trunk-tip-verification.md` Steps 3/6 remain unchanged

- RED: assertion detects an altered Steps 3/6 git command.
- GREEN: Steps 3/6 byte-identical to pre-change state.
- verify: `git diff` scoped to prove lines; assert Steps 3/6 commands unchanged.
- commit: the guard assertion.

### Item 4 (SC-4): Behavioral regression guard asserting `origin/$DEFAULT_BRANCH` consultation

- RED: behavioral scenario shows the agent falls back to a stale local tip.
- GREEN: agent stderr shows consultation of `origin/$DEFAULT_BRANCH`.
- verify: `with-test-home opencode run` with stderr-based `assert_stderr_pattern_present`.
- commit: the behavioral scenario + the prose sweep that enables it.

## 6. Dependencies

- **Reference:** `trunk-tip-verification.md` (`.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md`) — **Relationship:** SC-3 requires its Steps 3/6 to be the pre-sweep baseline for the byte-identical diff; **Status:** satisfied (file exists).
- **Reference:** model pattern in `create-pr.md` / `enforcement-gate.md` — **Relationship:** SC-2 must align new wording with the existing `remote trunk tip SHA` pattern; **Status:** satisfied (verified F6).
- **Reference:** mandatory test framework `with-test-home` — **Relationship:** SC-4 behavioral test must run via `with-test-home opencode run`; **Status:** satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1, SC-2 | Phase 1 |
| R-5 | SC-1 | Phase 1 |
| R-6 | SC-1 | Phase 1 |
| R-7 | SC-2 | Phase 1 |
| R-8 | SC-3 | Phase 1 |
| R-9 | SC-3 | Phase 1 |
| R-10 | SC-1 | Phase 1 |
| R-11 | SC-1 | Phase 1 |
| R-12 | SC-1 | Phase 1 |
| R-13 | SC-4 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `trunk-tip-verification.md` | task card | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` | `read` of lines 5-15, 78-79 |
| `create-pr.md` | task card | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` | rg F6 — remote model lines 234, 237, 238 |
| `enforcement-gate.md` | task card | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` | rg F6 — line 32 |
| Pre-spec inspection scan | analysis | `pre-spec-inspection.yaml` | live `rg` scan on 2026-08-19 (F1-F9) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the rg scan costs seconds. Skipping means a missed unqualified site ships, the prose still says "trunk tip", and the agent starts from a stale local base — the exact defect the gate prevents.
- **SC-2:** Standardizing the prose costs one per-site edit plus a grep. Skipping leaves the 21 unqualified `trunk tip` sites that let agents treat the local tip as authoritative.
- **SC-3:** Verifying Steps 3/6 unchanged costs a scoped `git diff`. Skipping risks a prose edit silently altering a git command, turning a documentation sweep into a behavioral defect.
- **SC-4:** Running the behavioral test costs minutes of execution time. Skipping means the behavioral defect (agent falls back to stale local tip) ships to production and costs 1000× more to fix.

## 11. Edge Cases

- **Input boundaries:** An empty directory scan (no branch-tip prose found) must still pass SC-1 (zero unqualified is trivially satisfied). A file that uses `$DEFAULT_BRANCH` inline within a command example is a legitimate `$DEFAULT_BRANCH` usage and not a sweep target.
- **State transitions:** START (unqualified prose) → AFTER (remote-qualified prose) via SC-2; the transition is a pure prose rewrite with no runtime state machine change.
- **Failure modes:** A sweep site missed → SC-1 scan FAIL; the sweep re-scans and fixes. A prose edit accidentally alters a Step 3/6 command → SC-3 guard FAIL; revert the altered command.
- **Concurrency:** no race conditions — prose-only edit, no concurrent state mutation.
- **Recovery:** missed site → re-run the sweep and re-scan; altered gate → restore the byte-identical Steps 3/6 from the pre-change baseline.

## 12. Change Control

| Date | Authorized By | Change | Why |
|------|---------------|--------|-----|
| 2026-08-19 | Spec revision (traceability) | Added R-13 (behavioral regression test requirement) and mapped R-13 → SC-4 in Section 7 Traceability | Validation finding: SC-4 was orphaned (appeared in no Traceability table row); R-1..R-12 mapped only to SC-1/SC-2/SC-3, violating the "Every SC MUST trace to at least one requirement" standard |
| 2026-08-19 | Spec revision (validation findings) | Changed SC-1 and SC-2 evidence type from `structural` to `string` to match their `rg` grep-pattern verification methods; documented why analytical artifacts are not required | Validation finding: EVIDENCE_TYPE_MISMATCH FAIL — the canonical evidence-type taxonomy classifies `rg` grep/pattern scans as `string`, not `structural`; SC-3 (`git-diff`, structural) and SC-4 (behavioral) left unchanged. WARNING: empty artifacts directory — analytical artifacts (blast-radius, concern-map, interface-compatibility, testability-assessment) are not applicable to a documentation-only terminology sweep |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
