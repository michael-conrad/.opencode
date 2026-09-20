> Full spec and artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2449/

# [SPEC] local-issues list reports [open] for artifact-only dirs without issue.yaml

## Problem

`local-issues list` and `search` fabricate ticket state: directories that contain only analysis artifacts (no `issue.yaml`) are reported as `[open]` tickets with an empty title. This phantom state corrupts the issue-store view that agents use for routing and can mask genuinely malformed records.

- `list`: `_read_issue_title_status` (local-issues:315-327) returns `("", "open")` when `issue.yaml` is absent but `spec.md` exists.
- `search`: `_read_issue_data_in_repo` (local-issues:1305-1339) synthesizes `result["issue"] = {..., "status": "open"}` for yaml-less dirs with plain-markdown specs.
- Validation (`_validate_issue_dir`, local-issues:88-108) only warns on files that exist; absence of `issue.yaml` is never flagged.

## Success Criteria

| ID | Success Criterion | Evidence Type | Documentation Sources |
|----|-------------------|---------------|----------------------|
| SC-1 | `local-issues list` SHALL NOT emit `[open]` for a directory whose only file is `spec.md` (or any artifact-only dir without `issue.yaml`); it SHALL emit a distinct artifact-only marker or skip the dir per the presentation policy fixed in SC-3. | semantic | `.opencode/tools/local-issues` `_read_issue_title_status` (315-327), `_format_list_output` (1674-1681) |
| SC-2 | `local-issues search` (and the `read` subcommand sharing `_read_issue_data_in_repo`) SHALL NOT synthesize `status: "open"` for a yaml-less directory with a plain-markdown spec. | semantic | `.opencode/tools/local-issues` `_read_issue_data_in_repo` (1305-1339), `_search_issues_in_repo` (1590-1614) |
| SC-3 | The list/search output policy for yaml-less dirs SHALL be a single shared decision: a distinct marker token (e.g. `[artifact-only]`) consistently applied by `_format_list_output` and `_format_search_results`; well-formed tickets (issue.yaml + spec.md) SHALL keep real status. Cost-frame: failure to fix costs every future agent session wasted routing decisions on phantom tickets and lets malformed dirs hide among real ones — re-debugging this family (#2404, #2394) repeatedly. | semantic | `_format_list_output` (1674-1681), `_format_search_results` (1617-1620) |

## Approach

Fix the two read functions to stop fabricating ticket state when `issue.yaml` is missing: `_read_issue_title_status` returns a sentinel (e.g. `None` status) instead of `("", "open")`, and `_read_issue_data_in_repo` omits the synthesized status. Presentation-layer formatters then apply one shared policy (SC-3 marker token) for yaml-less dirs; the read path keeps detection logic inside the reader functions per the concern map. Follow existing sandbox pytest conventions in `.opencode/tests/test_local_issues/` (pattern: `test_yaml_load_warn_and_skip.py`, issue 2432 error-class taxonomy).

Out of scope: validation warning for missing `issue.yaml` in `_validate_issue_dir` (separate concern), any migration of artifact-only dirs, behavioral opencode-run tests (CLI output fidelity is unit-testable).

## Impact

- Risk 1: `read` subcommand output changes for yaml-less dirs — mitigate with consistency test (testability phase: read side-effect).
- Risk 2: agents parsing list output tokens — additive marker, non-breaking for well-formed tickets; document the token.
- Risk 3: search fixture matrix misses a file combination — mitigate with SC-3 matrix fixtures (spec-only, comments.yaml-only, links.yaml-only, empty, control).
- Dependencies: none external; single-file tool `.opencode/tools/local-issues`.
- Related: #2404, #2394 (same phantom-state family).

## Verification

Per-SC unit tests in `.opencode/tests/test_local_issues/` using sandbox fixture trees; RED first against current tool, then GREEN. Evidence type: semantic (sandbox pytest stdout assertions). No behavioral opencode-run tests required — tool is deterministic CLI.

---
