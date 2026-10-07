# PLAN: `.opencode#2549` — local-first resolution of qualified issue references

Derived entirely from `spec.md` in this directory. One item per change/SC,
dependency ordered. Branch: `feature/2548-issues-store-friction` (shared with
the stacked scope; base b2f357f7).

## Item 1 — change 1 → SC-1 (repo-aware not-found + remote fallback hint)

- Deliverable: `cmd_read`/`cmd_read_comments`/`cmd_read_labels`/
  `cmd_read_sub_issues` pass the resolved repo path into `_not_found`
  (call sites 1300, 1330, 1357, 1383); `_not_found` (1285-1291) appends, when
  the repo has an origin remote, one line:
  `Local record absent — remote mirror may know this number: local-issues url --number {repo}#{N}`.
- RED: `./.opencode/tools/local-issues read --number .opencode#999999` lists
  root-store numbers (`#2161, #2127, …`) with no hint today (spec observation).
- GREEN: thread repo_path + repo name/number into the message.
- Verify: spec SC-1 instrument — recents all from `.opencode/.issues/`, hint
  contains `url --number .opencode#999999`, exit 1.

## Item 2 — change 2 → SC-2 (Repo Information: real repos only + issues: field)

- Deliverable: `collect_repo_info` (session-init:149-241) skips entries whose
  path is `.issues` or ends in `/.issues` (predicate reused from
  `collect_issue_artifact_paths`, 549-552); every remaining repo entry emits
  `  issues: {path}/.issues/` in the Repo Information block (emitter at
  657-665).
- RED: `./.opencode/tools/session-init` output contains store entries
  (`.issues`, `.opencode/.issues`) and no `issues:` line today.
- GREEN: skip predicate in both scan loops; `issues:` line after `url`.
- Verify: spec SC-2 instrument — no store-path entries; `issues: .issues/`
  and `issues: .opencode/.issues/` present.

## Item 3 — change 3 → SC-3, SC-4 (Local Issue Folders: artifact rule + honest existence check)

- Deliverable: `collect_issue_artifact_paths` (session-init:540-561) emits one
  vocabulary line stating local artifacts for `repo#N` live at that repo's
  `issues:` path under `{N}/`; checks store existence and emits a setup hint
  naming `local-issues init` when a store is absent (docstring/code drift fix).
- RED: no `.issues/{N}/` artifact-rule line in output today; docstring claims
  an existence check the code doesn't perform (spec F-item 4).
- GREEN: rule line + existence check + setup hint.
- Verify: spec SC-3 + SC-4 instruments (SC-4 in a sandbox clone without
  `.issues/`).

## Item 4 — change 4 → SC-5 ({issues_prefix} derivation made true)

- Deliverable: reword `.opencode/.issues/AGENTS.md:122` minimally so the
  derivation names the now-emitted `issues:` field exactly, keeping the
  never-hardcode mandate. Issue-data hygiene.
- Depends on: item 2 (the field must exist before the sentence is true).
- Verify: spec SC-5 instrument — every field the sentence names is emitted by
  session-init.

## Item 5 — change 5 → SC-6 (DESCRIPTION line)

- Deliverable: `local-issues:18` (and the `--description` echo at 2264-2266 —
  keep the two in sync) becomes: `Local issue tracking CLI for .issues/
  stores; resolves qualified repo#N references to local artifacts.`
- Verify: spec SC-6 instrument — grep DESCRIPTION line contains `.issues/`
  and `repo#N`.

## Item 6 — change 6 → SC-7 (routing row)

- Deliverable: `routing.md:24` issues row extends to "creating,
  reading/resolving, commenting, linking, or closing issues".
- Deck-governance-gated edit (skill-creator card loads first).
- Verify: spec SC-7 instrument — routing.md issues row contains
  `reading`/`resolving`.

## Item 7 — SC-8 (regression on existing resolution surfaces)

- No code change. Run the spec's three live commands after items 1-5 and
  confirm all match current observed behavior (read full → spec_path; bare
  2466 → exit 1 qualifier list; url --artifacts → GitHub tree URL).
