> **Full spec and artifacts: [`.opencode/.issues/2241/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2241)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2241/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Authorization tracking: local issue.yaml is canonical source, not remote API labels

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Authorization state (labels like `needs-approval`, `approved-for-*`, `spec-cleared`) is currently read from and written to remote API labels as the primary source. Remote API labels are unreliable — GitBucket post-creation labels are broken, GitHub API can be rate-limited, and network failures make auth decisions dependent on remote availability. Additionally, agents scan issue comments for "approved"/"go" tokens as a fallback auth verification mechanism, which is fragile and produces false positives. |
| 2 | **Root Cause / Motivation** | The architecture was designed when remote API labels were the only available mechanism. The `local-issues` tool now supports reading and writing labels to local `issue.yaml` files, making local tracking viable. The "No Metadata Trust" doctrine was a workaround for unreliable remote labels — it is no longer needed when local `issue.yaml` is the canonical source. Comment-scanning for auth was a second workaround that must be eliminated. |
| 3 | **Approach Chosen** | Establish local `issue.yaml` as the canonical source for all authorization labels. All label-writing tasks write to local `issue.yaml` as primary with remote best-effort. All label-reading tasks read from local `issue.yaml` by default with remote fallback only. Remove the "No Metadata Trust" doctrine, cargo-cult remote auth references, and all comment-scanning for authorization. Delete the dead `push-body.md` file. Update the approval-gate guideline to document the new canonical source. |
| 4 | **Alternatives Considered & Why Discarded** | **Keep remote-only labels:** Would continue to depend on unreliable remote API for auth decisions. GitBucket post-creation labels remain broken. **Hybrid with remote as primary:** Same reliability problem — remote failure still blocks auth. **Remove labels entirely and use only comment scanning:** Comment scanning is more fragile than labels and produces false positives. |
| 5 | **Key Design Decisions** | (1) Local `issue.yaml` is the single source of truth — remote labels are advisory/display only. (2) Remote label writes are best-effort — pipeline never blocks on remote label failure. (3) Remote label reads are fallback-only — default is local. (4) Authorization is parsed from chat messages only, not from issue comments. (5) The `writing-plans/tasks/analyze.md` pattern (reads auth from local `issue.yaml`) is the reference pattern for all changes. |
| 6 | **User Intent / Original Prompt** | The user identified that authorization tracking relies on remote API labels which are unreliable, and that comment-scanning for auth is a fragile workaround. The request is to make local `issue.yaml` the canonical source, eliminating remote dependency and comment-scanning fragility. |

## 2. Not Included

- **Remote label API behavior** — Remote labels remain as advisory/display only. No changes to the API itself.
- **local-issues tool** — No changes to the tool itself; only the task files that call it.
- **Authorization grant mechanism** — Authorization is still granted via "approved"/"go" in chat. Only where it is stored and read from changes.
- **New API endpoints or CLI commands** — No new infrastructure is added.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|-------------------|
| SC-1 | `writing-plans/tasks/handoff.md` SHALL read authorization from local `{issues_prefix}/{N}/issue.yaml` instead of calling `approval-gate --task verify-authorization` (which reads remote labels) | semantic | Clean-room sub-agent reads handoff.md and evaluates whether auth is read from local issue.yaml |
| SC-2 | `approval-gate/tasks/apply-label.md` SHALL write `approved-for-{scope}` to local `issue.yaml` as canonical; remote write SHALL be best-effort only | semantic | Clean-room sub-agent reads apply-label.md and evaluates whether local write is primary |
| SC-3 | `issue-operations-core/tasks/creation.md` SHALL write `needs-approval` to local `issue.yaml` as primary; remote write SHALL be best-effort | semantic | Clean-room sub-agent reads creation.md and evaluates whether local write is primary |
| SC-4 | `issue-operations-core/tasks/completion.md` SHALL read `needs-approval` from local `issue.yaml`; remote write SHALL be best-effort | semantic | Clean-room sub-agent reads completion.md and evaluates whether local read is primary |
| SC-5 | `guidelines/010-approval-gate.md` SHALL clarify that canonical authorization state is in local `issue.yaml`; remote labels SHALL be advisory | string | grep for "canonical" or "local issue.yaml" in 010-approval-gate.md |
| SC-6 | `spec-creation/tasks/create.md` SHALL write labels to local `issue.yaml` as primary; remote secondary | semantic | Clean-room sub-agent reads create.md and evaluates whether local write is primary |
| SC-7 | `issue-review/tasks/analyze-and-spec.md` SHALL write labels to local `issue.yaml` as primary; remote secondary | semantic | Clean-room sub-agent reads analyze-and-spec.md and evaluates whether local write is primary |
| SC-8 | `writing-plans/tasks/create.md` SHALL write `spec-cleared` to local `issue.yaml` as primary; remote secondary | semantic | Clean-room sub-agent reads create.md and evaluates whether local write is primary |
| SC-9 | `issue-operations-core/tasks/read-labels.md` SHALL read from local `issue.yaml` by default; remote read SHALL be only when explicitly requested | semantic | Clean-room sub-agent reads read-labels.md and evaluates whether local read is default |
| SC-10 | `issue-operations-core/tasks/list-issues.md` SHALL remove "Authorization scope label verification" from use cases | string | grep for "Authorization scope label" in list-issues.md — SHALL return no matches |
| SC-11 | `issue-operations-core/tasks/search-issues.md` SHALL remove "Authorization scope label search" from use cases | string | grep for "Authorization scope label" in search-issues.md — SHALL return no matches |
| SC-12 | `issue-review/tasks/gather.md` SHALL read labels from local `issue.yaml`; remote fallback only | semantic | Clean-room sub-agent reads gather.md and evaluates whether local read is primary |
| SC-13 | `audit/tasks/drift-detection-investigator.md` SHALL read labels from local `issue.yaml`; remote fallback only | semantic | Clean-room sub-agent reads drift-detection-investigator.md and evaluates whether local read is primary |
| SC-14 | `verification-before-completion/tasks/operating-protocol.md` SHALL read labels from local `issue.yaml`; remote fallback only | semantic | Clean-room sub-agent reads operating-protocol.md and evaluates whether local read is primary |
| SC-15 | `audit/tasks/drift-detection-investigator.md` SHALL remove "Authorization currency" and "Authorization author identity" rows from Metadata Verification Extension | string | grep for "Authorization currency" and "Authorization author identity" in drift-detection-investigator.md — SHALL return no matches |
| SC-16 | `issue-operations-core/tasks/read-issue.md` SHALL remove the entire "No Metadata Trust Exceptions" section | string | grep for "No Metadata Trust" in read-issue.md — SHALL return no matches |
| SC-17 | `verification-before-completion/tasks/operating-protocol.md` SHALL remove the entire "No Metadata Trust Exceptions" section | string | grep for "No Metadata Trust" in operating-protocol.md — SHALL return no matches |
| SC-18 | `issue-review/tasks/gather.md` SHALL remove scanning comments for "approved"/"go" patterns | string | grep for comment-scanning patterns in gather.md — SHALL return no matches |
| SC-19 | `brainstorming/tasks/enforcement.md` SHALL remove "User approved design" verification row checking comments for approval | string | grep for "User approved design" in enforcement.md — SHALL return no matches |
| SC-20 | `issue-operations-core/tasks/post-creation.md` SHALL remove "approved"/"go" check in comments from Live Verification table | string | grep for "approved" or "go" in post-creation.md Live Verification section — SHALL return no matches for comment-scanning patterns |
| SC-21 | `approval-gate/tasks/resolve-scope.md` SHALL parse auth from chat message only, not from issue comments | semantic | Clean-room sub-agent reads resolve-scope.md and evaluates whether auth is parsed from chat only |
| SC-22 | `approval-gate/SKILL.md` SHALL remove references to reading comments for authorization | string | grep for "comments" in approval-gate/SKILL.md — SHALL return no matches for auth-related comment references |
| SC-23 | `gh-cli/tasks/triage-issues.md` SHALL remove noting authorization in comments | string | grep for "authorization" in triage-issues.md — SHALL return no matches for comment-scanning patterns |
| SC-24 | `guidelines/067-context-completeness.md` SHALL remove "authorization may live in a comment, not the body" | string | grep for "authorization" in 067-context-completeness.md — SHALL return no matches for comment-scanning language |
| SC-25 | `guidelines/257-procedural-discipline-reference.md` SHALL remove "Authorization verified via comment history" example | string | grep for "Authorization verified" in 257-procedural-discipline-reference.md — SHALL return no matches |
| SC-26 | `issue-operations/platforms/gitbucket-api/SKILL.md` SHALL remove label replacement via comment fallback | string | grep for "comment fallback" in gitbucket-api/SKILL.md — SHALL return no matches |
| SC-27 | `issue-operations/platforms/local/tasks/push-body.md` SHALL be removed (describes non-existent sync operation) | structural | File SHALL NOT exist at `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` |

## 4. Requirements

R-1. All label-writing task files SHALL write authorization labels to local `{issues_prefix}/{N}/issue.yaml` as the primary canonical source.
R-2. All label-writing task files SHALL treat remote API label writes as best-effort only — the pipeline SHALL NOT block on remote label failure.
R-3. All label-reading task files SHALL read authorization labels from local `{issues_prefix}/{N}/issue.yaml` by default.
R-4. All label-reading task files SHALL use remote API label reads only as a fallback when explicitly requested.
R-5. No task file SHALL scan issue comments for "approved", "go", or any authorization token.
R-6. The "No Metadata Trust" doctrine SHALL be removed from all files that contain it.
R-7. Cargo-cult remote auth references in `list-issues.md` and `search-issues.md` SHALL be removed.
R-8. The dead file `push-body.md` SHALL be deleted.
R-9. The approval-gate guideline SHALL document that canonical authorization state is in local `issue.yaml`.

## 5. Items

### Item 1 (SC-2): `approval-gate/tasks/apply-label.md` — local write primary

- RED: Behavioral enforcement test — verify agent writes `approved-for-*` to local issue.yaml
- GREEN: Modify apply-label.md to write to local issue.yaml as primary; remote best-effort
- verify: Clean-room sub-agent reads apply-label.md and confirms local write is primary
- commit: `apply-label.md` + behavioral test

### Item 2 (SC-3): `issue-operations-core/tasks/creation.md` — local write primary

- RED: Behavioral enforcement test — verify agent writes `needs-approval` to local issue.yaml
- GREEN: Modify creation.md to write `needs-approval` to local issue.yaml as primary; remote best-effort
- verify: Clean-room sub-agent reads creation.md and confirms local write is primary
- commit: `creation.md` + behavioral test

### Item 3 (SC-4): `issue-operations-core/tasks/completion.md` — local read primary

- RED: Behavioral enforcement test — verify agent reads `needs-approval` from local issue.yaml
- GREEN: Modify completion.md to read from local issue.yaml; remote write best-effort
- verify: Clean-room sub-agent reads completion.md and confirms local read is primary
- commit: `completion.md` + behavioral test

### Item 4 (SC-6): `spec-creation/tasks/create.md` — local write primary

- RED: Behavioral enforcement test — verify agent writes labels to local issue.yaml
- GREEN: Modify create.md to write labels to local issue.yaml as primary; remote secondary
- verify: Clean-room sub-agent reads create.md and confirms local write is primary
- commit: `create.md` + behavioral test

### Item 5 (SC-7): `issue-review/tasks/analyze-and-spec.md` — local write primary

- RED: Behavioral enforcement test — verify agent writes labels to local issue.yaml
- GREEN: Modify analyze-and-spec.md to write labels to local issue.yaml as primary; remote secondary
- verify: Clean-room sub-agent reads analyze-and-spec.md and confirms local write is primary
- commit: `analyze-and-spec.md` + behavioral test

### Item 6 (SC-8): `writing-plans/tasks/create.md` — local write primary

- RED: Behavioral enforcement test — verify agent writes `spec-cleared` to local issue.yaml
- GREEN: Modify create.md to write `spec-cleared` to local issue.yaml as primary; remote secondary
- verify: Clean-room sub-agent reads create.md and confirms local write is primary
- commit: `create.md` + behavioral test

### Item 7 (SC-1): `writing-plans/tasks/handoff.md` — local read primary

- RED: Behavioral enforcement test — verify agent reads auth from local issue.yaml
- GREEN: Modify handoff.md to read auth from local issue.yaml instead of `approval-gate --task verify-authorization`
- verify: Clean-room sub-agent reads handoff.md and confirms local read is primary
- commit: `handoff.md` + behavioral test

### Item 8 (SC-9): `issue-operations-core/tasks/read-labels.md` — local read default

- RED: Behavioral enforcement test — verify agent reads labels from local issue.yaml by default
- GREEN: Modify read-labels.md to read from local issue.yaml by default; remote explicit only
- verify: Clean-room sub-agent reads read-labels.md and confirms local read is default
- commit: `read-labels.md` + behavioral test

### Item 9 (SC-12): `issue-review/tasks/gather.md` — local read primary

- RED: Behavioral enforcement test — verify agent reads labels from local issue.yaml
- GREEN: Modify gather.md to read labels from local issue.yaml; remote fallback only
- verify: Clean-room sub-agent reads gather.md and confirms local read is primary
- commit: `gather.md` + behavioral test

### Item 10 (SC-13): `audit/tasks/drift-detection-investigator.md` — local read primary

- RED: Behavioral enforcement test — verify agent reads labels from local issue.yaml
- GREEN: Modify drift-detection-investigator.md to read labels from local issue.yaml; remote fallback only
- verify: Clean-room sub-agent reads drift-detection-investigator.md and confirms local read is primary
- commit: `drift-detection-investigator.md` + behavioral test

### Item 11 (SC-14): `verification-before-completion/tasks/operating-protocol.md` — local read primary

- RED: Behavioral enforcement test — verify agent reads labels from local issue.yaml
- GREEN: Modify operating-protocol.md to read labels from local issue.yaml; remote fallback only
- verify: Clean-room sub-agent reads operating-protocol.md and confirms local read is primary
- commit: `operating-protocol.md` + behavioral test

### Item 12 (SC-10): `list-issues.md` — remove cargo-cult line

- RED: grep for "Authorization scope label" in list-issues.md — SHALL match before change
- GREEN: Remove "Authorization scope label verification" line from use cases
- verify: grep for "Authorization scope label" in list-issues.md — SHALL return no matches
- commit: `list-issues.md`

### Item 13 (SC-11): `search-issues.md` — remove cargo-cult line

- RED: grep for "Authorization scope label" in search-issues.md — SHALL match before change
- GREEN: Remove "Authorization scope label search" line from use cases
- verify: grep for "Authorization scope label" in search-issues.md — SHALL return no matches
- commit: `search-issues.md`

### Item 14 (SC-16): `read-issue.md` — remove No Metadata Trust

- RED: grep for "No Metadata Trust" in read-issue.md — SHALL match before change
- GREEN: Remove entire "No Metadata Trust Exceptions" section
- verify: grep for "No Metadata Trust" in read-issue.md — SHALL return no matches
- commit: `read-issue.md`

### Item 15 (SC-17): `operating-protocol.md` — remove No Metadata Trust

- RED: grep for "No Metadata Trust" in operating-protocol.md — SHALL match before change
- GREEN: Remove entire "No Metadata Trust Exceptions" section
- verify: grep for "No Metadata Trust" in operating-protocol.md — SHALL return no matches
- commit: `operating-protocol.md`

### Item 16 (SC-15): `drift-detection-investigator.md` — remove auth rows

- RED: grep for "Authorization currency" in drift-detection-investigator.md — SHALL match before change
- GREEN: Remove "Authorization currency" and "Authorization author identity" rows from Metadata Verification Extension
- verify: grep for "Authorization currency" and "Authorization author identity" — SHALL return no matches
- commit: `drift-detection-investigator.md`

### Item 17 (SC-18): `gather.md` — remove comment scanning

- RED: grep for comment-scanning patterns in gather.md — SHALL match before change
- GREEN: Remove scanning comments for "approved"/"go" patterns
- verify: grep for comment-scanning patterns in gather.md — SHALL return no matches
- commit: `gather.md`

### Item 18 (SC-19): `enforcement.md` — remove approval comment check

- RED: grep for "User approved design" in enforcement.md — SHALL match before change
- GREEN: Remove "User approved design" verification row checking comments for approval
- verify: grep for "User approved design" in enforcement.md — SHALL return no matches
- commit: `enforcement.md`

### Item 19 (SC-20): `post-creation.md` — remove approved/go check

- RED: grep for comment-scanning patterns in post-creation.md — SHALL match before change
- GREEN: Remove "approved"/"go" check in comments from Live Verification table
- verify: grep for comment-scanning patterns in post-creation.md — SHALL return no matches
- commit: `post-creation.md`

### Item 20 (SC-21): `resolve-scope.md` — parse from chat only

- RED: Behavioral enforcement test — verify agent currently parses auth from issue comments
- GREEN: Modify resolve-scope.md to parse auth from chat message only, not from issue comments
- verify: Clean-room sub-agent reads resolve-scope.md and confirms auth is parsed from chat only
- commit: `resolve-scope.md` + behavioral test

### Item 21 (SC-22): `approval-gate/SKILL.md` — remove comment references

- RED: grep for auth-related comment references in approval-gate/SKILL.md — SHALL match before change
- GREEN: Remove references to reading comments for authorization
- verify: grep for auth-related comment references in approval-gate/SKILL.md — SHALL return no matches
- commit: `approval-gate/SKILL.md`

### Item 22 (SC-23): `triage-issues.md` — remove noting auth in comments

- RED: grep for "authorization" in triage-issues.md — SHALL match before change
- GREEN: Remove noting authorization in comments
- verify: grep for "authorization" in triage-issues.md — SHALL return no matches for comment-scanning patterns
- commit: `triage-issues.md`

### Item 23 (SC-24): `067-context-completeness.md` — remove auth in comment language

- RED: grep for "authorization" in 067-context-completeness.md — SHALL match before change
- GREEN: Remove "authorization may live in a comment, not the body"
- verify: grep for "authorization" in 067-context-completeness.md — SHALL return no matches for comment-scanning language
- commit: `067-context-completeness.md`

### Item 24 (SC-25): `257-procedural-discipline-reference.md` — remove example

- RED: grep for "Authorization verified" in 257-procedural-discipline-reference.md — SHALL match before change
- GREEN: Remove "Authorization verified via comment history" example
- verify: grep for "Authorization verified" in 257-procedural-discipline-reference.md — SHALL return no matches
- commit: `257-procedural-discipline-reference.md`

### Item 25 (SC-26): `gitbucket-api/SKILL.md` — remove comment fallback

- RED: grep for "comment fallback" in gitbucket-api/SKILL.md — SHALL match before change
- GREEN: Remove label replacement via comment fallback
- verify: grep for "comment fallback" in gitbucket-api/SKILL.md — SHALL return no matches
- commit: `gitbucket-api/SKILL.md`

### Item 26 (SC-27): `push-body.md` — delete dead file

- RED: File exists at `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` — SHALL exist before change
- GREEN: Delete `push-body.md`
- verify: File SHALL NOT exist at that path
- commit: `push-body.md` deletion

### Item 27 (SC-5): `010-approval-gate.md` — update guideline

- RED: grep for "canonical" or "local issue.yaml" in 010-approval-gate.md — SHALL return no matches before change
- GREEN: Update 010-approval-gate.md to clarify canonical auth is local issue.yaml; remote labels advisory
- verify: grep for "canonical" or "local issue.yaml" in 010-approval-gate.md — SHALL return matches
- commit: `010-approval-gate.md`

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| `local-issues` tool | Must support `read-labels` and `update --labels` for local issue.yaml operations | Satisfied — verified via tool help |
| `writing-plans/tasks/analyze.md` | Reference pattern for reading auth from local issue.yaml | Satisfied — pattern exists and is verified |
| `issue.yaml` format | Must include a `labels` field | Satisfied — verified via local-issues read output |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-2, SC-3, SC-4, SC-6, SC-7, SC-8 | P1 |
| R-2 | SC-2, SC-3, SC-4, SC-6, SC-7, SC-8 | P1 |
| R-3 | SC-1, SC-9, SC-12, SC-13, SC-14 | P2 |
| R-4 | SC-9, SC-12, SC-13, SC-14 | P2 |
| R-5 | SC-15, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26 | P5 |
| R-6 | SC-16, SC-17 | P4 |
| R-7 | SC-10, SC-11 | P3 |
| R-8 | SC-27 | P6 |
| R-9 | SC-5 | P7 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `local-issues` tool help | CLI | `.opencode/tools/local-issues --help` | Verified via bash: `read-labels` and `update --labels` subcommands exist |
| `writing-plans/tasks/analyze.md` | Task file | `.opencode/skills/writing-plans/tasks/analyze.md` | Verified via read: Step 2 reads issue.yaml labels field |
| `issue.yaml` format | Config | `.opencode/.issues/*/issue.yaml` | Verified via local-issues read: labels field exists |
| Pre-spec inspection | Artifact | `tmp/local-auth-regression/artifacts/pre-spec-inspection.yaml` | Verified via read: all 27 affected files documented |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying handoff.md reads from local issue.yaml costs one clean-room sub-agent read. Skipping means auth verification still depends on remote API availability — a network failure during handoff blocks the entire pipeline.
- SC-2: Verifying apply-label.md writes to local issue.yaml costs one clean-room sub-agent read. Skipping means the primary label-write path still targets unreliable remote API — GitBucket post-creation label failure silently drops auth state.
- SC-3: Verifying creation.md writes to local issue.yaml costs one clean-room sub-agent read. Skipping means new issues have no local auth state — the first auth check after creation hits remote API.
- SC-4: Verifying completion.md reads from local issue.yaml costs one clean-room sub-agent read. Skipping means completion checks still depend on remote API — a rate-limit during completion blocks issue closure.
- SC-5: Verifying the guideline update costs one grep search. Skipping means the next agent reads the old guideline and continues using remote labels as authoritative.
- SC-6: Verifying create.md writes to local issue.yaml costs one clean-room sub-agent read. Skipping means spec creation still writes labels to remote only — the local issue.yaml has no auth state.
- SC-7: Verifying analyze-and-spec.md writes to local issue.yaml costs one clean-room sub-agent read. Skipping means fix specs have no local auth state.
- SC-8: Verifying create.md writes spec-cleared to local issue.yaml costs one clean-room sub-agent read. Skipping means the spec-cleared signal is only on remote — a network failure during plan creation loses the signal.
- SC-9: Verifying read-labels.md reads from local by default costs one clean-room sub-agent read. Skipping means every label read still hits remote API — multiplying remote dependency across every auth check.
- SC-10: Verifying list-issues.md removes the cargo-cult line costs one grep. Skipping means the next agent reads "auth scope label verification" and tries to use remote issue lists for auth.
- SC-11: Verifying search-issues.md removes the cargo-cult line costs one grep. Skipping means the same cargo-cult pattern persists in search.
- SC-12: Verifying gather.md reads from local issue.yaml costs one clean-room sub-agent read. Skipping means issue review still reads labels from remote API.
- SC-13: Verifying drift-detection-investigator.md reads from local issue.yaml costs one clean-room sub-agent read. Skipping means drift detection still depends on remote API for label reads.
- SC-14: Verifying operating-protocol.md reads from local issue.yaml costs one clean-room sub-agent read. Skipping means VbC still depends on remote API for label reads.
- SC-15: Verifying drift-detection-investigator.md removes auth rows costs one grep. Skipping means the next agent still tries to verify auth via comment timestamps.
- SC-16: Verifying read-issue.md removes No Metadata Trust costs one grep. Skipping means the "Labels are not self-certifying" doctrine persists even though local issue.yaml IS the certifying source.
- SC-17: Verifying operating-protocol.md removes No Metadata Trust costs one grep. Skipping means the duplicate doctrine section persists.
- SC-18: Verifying gather.md removes comment scanning costs one grep. Skipping means agents still scan comments for "approved"/"go" — producing false positives from discussion language.
- SC-19: Verifying enforcement.md removes approval comment check costs one grep. Skipping means brainstorming enforcement still checks comments for approval.
- SC-20: Verifying post-creation.md removes approved/go check costs one grep. Skipping means post-creation verification still scans comments for auth tokens.
- SC-21: Verifying resolve-scope.md parses from chat only costs one clean-room sub-agent read. Skipping means agents still parse auth from issue comments — reading stale or out-of-context authorization.
- SC-22: Verifying approval-gate/SKILL.md removes comment references costs one grep. Skipping means the skill card still tells agents to read comments for auth.
- SC-23: Verifying triage-issues.md removes noting auth in comments costs one grep. Skipping means gh-cli triage still notes authorization found in comments.
- SC-24: Verifying 067-context-completeness.md removes auth in comment language costs one grep. Skipping means the guideline still tells agents "authorization may live in a comment."
- SC-25: Verifying 257-procedural-discipline-reference.md removes the example costs one grep. Skipping means the example still demonstrates auth verification via comment history.
- SC-26: Verifying gitbucket-api/SKILL.md removes comment fallback costs one grep. Skipping means GitBucket still uses comment fallback for label replacement.
- SC-27: Verifying push-body.md is deleted costs one file existence check. Skipping means a dead file describing a non-existent operation remains in the codebase.

## 11. Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|------------------|------------|
| Remote API unavailable during label write | Pipeline continues — local issue.yaml is already written | Remote write is best-effort; no block |
| Remote API unavailable during label read | Pipeline reads from local issue.yaml (default) | Remote fallback is skipped; local is sufficient |
| Local issue.yaml does not exist | Pipeline SHALL NOT proceed — auth state is unknown | Task SHALL fail BLOCKED with MISSING_LOCAL_ISSUE |
| Local issue.yaml has no labels field | Pipeline SHALL treat as no auth state (equivalent to `needs-approval`) | Read returns empty labels; agent checks `needs-approval` by absence |
| Chat message contains ambiguous auth language | resolve-scope.md SHALL parse deterministically via verb-prefix table | No agent judgment — table is the sole authority |
| Multiple "approved" messages in same session | Last authorization scope wins | resolve-scope.md SHALL use most recent scope |
| Issue has both local and remote labels that differ | Local issue.yaml is authoritative | Remote labels are advisory/display only |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
