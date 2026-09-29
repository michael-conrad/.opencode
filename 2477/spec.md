> **Full spec and artifacts: [`.opencode/.issues/2477/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2477/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

---
---
number: 2477
title: '[SPEC] issue-operations-sync import-remote task card — align mirror-file schema with local-issues'
status: open
labels: [needs-approval, spec-draft]
created: '2026-09-29'
updated: '2026-09-29'
remote_issue: 2477
remote_url: https://github.com/michael-conrad/.opencode/issues/2477
github_url: https://github.com/michael-conrad/.opencode/issues/2477
---

# Spec — issue-operations-sync import-remote mirror-file schema alignment

## 1. Intent and Executive Summary

1. **Problem Statement:** The `issue-operations-sync` `import-remote` task card (`.opencode/skills/issue-operations-sync/tasks/import-remote.md`) instructs the executing agent to produce mirror files `comments.md`, `remote.md`, and `state.md` — filenames that do not exist anywhere in the `local-issues` tool schema. The tool's verified constants are `YAML_FILES = ("issue.yaml", "comments.yaml", "links.yaml")` and `MARKDOWN_FILES = ("spec.md",)`. An agent following the card verbatim produces a mirror invisible to the tool: comments written to `comments.md` are unreadable by `read-comments`, and completeness gates demand nonexistent files.
2. **Root Cause / Motivation:** The task card was written against a legacy/planned schema that was never implemented in `local-issues`. The drift went unnoticed because imports succeeded through manual directory creation (e.g., this issue's own local record `.opencode/.issues/2477/` uses the correct new schema). The card is the documented contract for future import work, so its schema references SHALL match tool ground truth before the next import executes it.
3. **Approach Chosen:** Rewrite the task card's mirror-file contract to the real schema: replace `comments.md` with `comments.yaml` (list format), remove `remote.md`/`state.md` from Steps, Exit Criteria, the Step 4 completeness gate, Edge Cases, and the Live-Verification evidence table; separately correct Step 7's `.counter` advancement guidance to align with the tool's fail-fast `_next_number` semantics — a validated write consisting of a digit-parse check plus a monotonic-invariant check against the current `.counter` contents (counter after write >= remote_number + 1), never an unvalidated blind `echo`.
4. **Alternatives Considered & Why Discarded:**
   - **Implement `remote.md`/`state.md` support in `local-issues`** — discarded: requires tool source changes (out of scope per CON-1), and no consumer reads those files; adding them creates dead schema.
   - **Fix all sibling task cards with legacy references simultaneously** (sync-pull-to-local, platforms/local/*, spec-mirror, etc.) — discarded: scope per issue title is this card only; sibling drift is a candidate follow-up issue that needs its own blast-radius analysis.
   - **Defer until next import breaks** — discarded: the card is the contract an executing sub-agent follows verbatim; waiting guarantees a repeat of the hermes-ingest-pubmed#209 failure mode.
5. **Key Design Decisions:**
   - **Tool constants as single ground truth:** the card's enumerated mirror file set MUST equal `local-issues` `YAML_FILES`/`MARKDOWN_FILES` (issue.yaml, comments.yaml, links.yaml, spec.md). Tradeoff: couples the card's text to current tool constants — future tool schema changes require card re-sync (accepted; this spec is the correction pass).
   - **Counter instruction hygiene over mechanism change:** Step 7 is corrected at the documentation layer only (validation guidance consistent with `_next_number` digit-parse semantics); the tool's counter management is NOT modified. Tradeoff: the documented procedure still touches `.counter` externally, but with validation instructions (digit-parse check + monotonic invariant) that prevent silent-corruption writes.
   - **Existing-import recognition:** the completeness gate MUST recognize a directory already migrated to the new schema (issue.yaml + comments.yaml + links.yaml, as with `.opencode/.issues/2477/` itself) as complete — it MUST NOT demand legacy files.
6. **User Intent / Original Prompt:** Issue #2477 `[ENHANCEMENT] issue-operations-sync import-remote task card references legacy mirror filenames comments.md/state.md not used by local-issues schema` — the executing sub-agent in a real import had to ground the schema in tool source and store precedent because the card was wrong; the card SHALL be corrected.

## 2. Not Included

- **Sibling task-card legacy references** (`sync-pull-to-local.md`, `sync-from-remote.md`, `platforms/local/tasks/*.md`, `platforms/github-mcp/tasks/spec-mirror.md`, `issue-operations-comments/tasks/comment.md`, `platforms/local/SKILL.md`) — rationale: issue title scopes this spec to `import-remote.md` only; sibling fixes need their own drift inventory and are candidate follow-up issues.
- **`local-issues` tool source changes** — rationale: CON-1 constrains this spec to task-card documentation; the tool already implements the correct schema.
- **Adding `remote.md`/`state.md` support to the tool** — rationale: no consumer exists; dead schema.
- **Changing `sync-from-remote` / `sync-pull-to-local` behavior** — rationale: not the target file; their routing/dispatch strings are unchanged by this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `import-remote.md` contains zero references to legacy mirror filenames (`comments.md`, `remote.md`, `state.md`). | string | `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md` returns 0 |
| SC-2 | The `import-remote.md` Step 4 completeness gate and Live-Verification evidence table enumerate the actual schema files (`spec.md`, `issue.yaml`, `comments.yaml`, `links.yaml`). | string | Positive grep for `issue.yaml`, `comments.yaml`, `links.yaml` inside the completeness gate returns matches; positive grep for the same filenames in the Live-Verification evidence table returns matches |
| SC-3 | `import-remote.md` Step 7 counter instructions specify a validated write — a digit-parse check on the current `.counter` content plus a monotonic-invariant check (counter after write >= remote_number + 1) validated against the tool's `_next_number` behavior in `local-issues` — and no longer imply an unvalidated blind `echo`. | string | Read of revised Step 7 shows the digit-parse check and monotonic-invariant guidance consistent with `_next_number` semantics; grep for a bare unvalidated `echo $((...))` counter write returns no match |

## 4. Requirements

- R-1. `import-remote.md` SHALL reference only mirror filenames implemented by the `local-issues` tool schema (`spec.md`, `issue.yaml`, `comments.yaml`, `links.yaml`) in every section that enumerates or gates mirror files (Steps, Exit Criteria, Step 4 completeness gate, Edge Cases, Live-Verification evidence table).
- R-2. `import-remote.md` SHALL instruct comment import into `comments.yaml` in the `comments:` list format read by the tool's `read-comments`/`read`/`list` commands.
- R-3. The card's Step 4 completeness gate SHALL recognize a pre-existing directory already populated with the new-schema file set (`issue.yaml` + `comments.yaml` + `links.yaml` [+ `spec.md`]) as complete, without requiring legacy filenames.
- R-4. The card's Step 7 `.counter` instructions SHALL specify a validated write consistent with `_next_number` fail-fast digit-parse semantics — read the current `.counter`, verify it parses as digits, write a value that satisfies the monotonic invariant (counter after write >= remote_number + 1) — and SHALL NOT present an unvalidated blind `echo` as the procedure. The concrete procedure is the digit-parse check + monotonic invariant validated against the tool's `_next_number` behavior; no alternative mechanism is offered.
- R-5. The Live-Verification evidence table rows SHALL verify the new filenames (issue.yaml, comments.yaml, links.yaml) rather than `comments.md`/`state.md`.
- R-6. `spec.md` YAML frontmatter examples in the card SHALL remain valid for the tool's frontmatter parser (keys among `number`, `title`, `status`, `labels`, `created`, `updated` tolerated set).

## 5. Items

### Item 1 (SC-1, SC-2): Mirror-file contract rewrite to actual schema

- RED: `grep 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md` returns matches (legacy names present); positive grep for `issue.yaml`/`comments.yaml`/`links.yaml` in the completeness gate and Live-Verification evidence table returns no matches (actual schema absent)
- GREEN: Rewrite Steps 5/6, Exit Criteria, Step 4 completeness gate, Edge Cases table, and Live-Verification evidence table to the actual schema; replace `comments.md` instructions with `comments.yaml` list-format instructions; add completeness recognition of already-migrated directories (R-3); frontmatter examples remain parser-valid (R-6). Negative grep returns zero legacy-name matches; positive greps return matches in the completeness gate and evidence table.
- verify: Negative grep (zero legacy matches per SC-1) + positive greps for `issue.yaml`/`comments.yaml`/`links.yaml` in the completeness gate and Live-Verification evidence table (per SC-2); read-back confirms YAML frontmatter example preserved.
- commit: `.opencode/skills/issue-operations-sync/tasks/import-remote.md` — single commit, schema-accuracy scope. Tool source, skill frontmatter, TDT/dispatch strings unchanged.

### Item 2 (SC-3): Counter semantics correction in Step 7

- RED: Read of Step 7 shows a bare `echo $((N+1)) > .counter`-style instruction without validation guidance
- GREEN: Rewrite Step 7 (and referencing edge-case/verification rows) to specify a validated write — digit-parse check on the current `.counter` content consistent with `_next_number`, plus monotonic-invariant check (counter after write >= remote_number + 1) — with no tool-mediated alternative offered (R-4 names the concrete procedure). Read shows validation guidance present.
- verify: Read-back of Step 7 + edge-case/verification rows confirms no unvalidated blind-echo instruction remains; digit-parse check and invariant statement (counter >= remote_number + 1) present.
- commit: Same file, control-state scope; item 2 commits after item 1 (sequential TDD cycles).

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tools/local-issues` source | Ground truth for schema constants (`YAML_FILES`, `MARKDOWN_FILES`, `_next_number`) — read-only reference, MUST NOT be modified | satisfied |
| `.opencode/skills/issue-operations-sync/SKILL.md` | Dispatches the import-remote task card; unchanged by this spec | satisfied |
| Issue #2477 | Authorization source (`approved-for-for_pr` label) | satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Item 1 |
| R-2 | SC-2 | Item 1 |
| R-3 | SC-2 | Item 1 |
| R-4 | SC-3 | Item 2 |
| R-5 | SC-2 | Item 1 |
| R-6 | SC-2 | Item 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| local-issues tool source | code | `.opencode/tools/local-issues` (YAML_FILES/MARKDOWN_FILES constants, `cmd_comment`, `cmd_read_comments`, `_next_number`, frontmatter parser) | grep + read (pre-spec-inspection) |
| Live store record for #2477 | config | `.opencode/.issues/2477/` (issue.yaml, comments.yaml, links.yaml — new schema in practice) | directory listing |
| Remote issue #2477 | API | https://github.com/michael-conrad/.opencode/issues/2477 | `gh issue view` |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the zero-legacy-name grep and completeness-gate positive grep costs seconds of execution time — the defect (a sub-agent producing a tool-invisible mirror) is caught before the next import executes. Skipping means the next import sub-agent following the card verbatim writes `comments.md` that `read-comments` cannot see, and the defect surfaces only when issue data is found missing — a diagnosis across tool source, store directories, and skill cards.
- SC-2: Reading Step 7 and confirming counter-validation guidance costs one file read — counter-corruption instructions are caught before they are executed. Skipping means an import bypasses the tool's fail-fast digit parse with a blind echo, silently corrupting `.counter`, and the corruption surfaces only when a later issue creation fails on a non-digit counter.

## 11. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Empty or missing `comments.yaml` after import (issue has zero comments) | Card SHALL specify that `comments.yaml` with an empty `comments:` list is still materialized — the tool reads the file unconditionally | Covered by Step 6 rewrite |
| Directory already migrated to new schema (e.g., `.opencode/.issues/2477/`) when import re-runs | Completeness gate recognizes `issue.yaml` + `comments.yaml` + `links.yaml` [+ `spec.md`] as complete; no legacy-file demotion | R-3 |
| `.counter` write races a concurrent `local-issues create` | Card SHALL instruct the validated write only after verifying current `.counter` equals the imported number's successor expectation; tool `_next_number` fail-fast catches a corrupt counter at next use | Step 7 rewrite (R-4) |
| `local-issues` tool schema changes after this spec (constants renamed) | Out of scope — the card MUST be re-synced by a follow-up issue; this spec fixes one drift instance | Not Included section |
| Frontmatter with keys outside the parser's known set (`promoted_at`, `last_sync`, etc.) | Parser tolerates unknown keys (verified: parser reads `number`, `title`, `status`, `labels`, `created`, `updated`; unknown keys tolerated) — card examples SHOULD use known keys for portability | R-6 |

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-29 | SC-1 decomposed into SC-1 (zero legacy references) and SC-2 (completeness gate + evidence table enumerate actual schema files); former SC-2 renumbered SC-3; R-4 disjunction removed — concrete procedure named (digit-parse check + monotonic invariant validated against `local-issues` `_next_number`); traceability and Items updated to new SC numbering | Validation findings: aggregate_verdict FAIL (10 PASS / 4 FAIL) — compound-SC detection, Determinism (disjunctive 'or a tool-mediated mechanism'), Decomposition-criteria atomicity | Validator remediation directives on issue #2477 |