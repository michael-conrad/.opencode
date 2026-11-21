# Plan — .opencode#2763: validate-yaml findings carry the repo qualifier

## Goal

Make `local-issues validate-yaml` emit every finding's path qualified with
its owning repository's identity (`<repo>/<path>: <error-class>`), at both
emission sites (the unscoped per-store sweep and the scoped `--number`
branch), and update the committed tests pinning the old unqualified shape —
implementing the spec at `.opencode/.issues/2763/spec.md` (SC-1, SC-2).
Detection logic, other verbs' output, and record YAML content are untouched.

## Execution surface

Repository: `.opencode` (the deck submodule checkout). Branch:
`feature/2763-validate-yaml-qualified-paths` off the synced trunk tip.
Files touched: `.opencode/tools/local-issues` (the two `print(f"{rel}:
{error_class}")` loops in `cmd_validate_yaml`), and the two committed test
files `tests/test_local_issues/test_validate_yaml_validate_yaml_scoped.py` —
correction: `tests/test_local_issues/test_validate_yaml_scoped.py` and
`tests/test_local_issues/test_validate_yaml_exit_codes.py`. Test runs use
`uv run --script` against sandbox copies of the tool, per the existing test
files' harness; the suite runs under the canonical command
`cd .opencode && uv run pytest`.

Findings shape (current code, verified by read):

- Scoped branch: `rel` is `f"{entry.name}/{f.relative_to(entry)}"` from
  `_scan_issue_dir_errors(target)`; qualifier is the `repo_name` already in
  scope at the print loop.
- Unscoped sweep: scans only `PROJECT_DIR/.issues` (the workspace-root
  store); qualifier is `_resolve_repo_name()` — the workspace-root
  directory name, matching the tool's own available-qualifier listing.

## Items — one item per success criterion

### Item 1 — qualified emission at both sites (SC-1)

- **Deliverable**: the two print loops in `cmd_validate_yaml` print
  `<repo>/<path>: <error-class>`. Scoped site: prefix `repo_name`/.
  Unscoped site: prefix `opencode-config` qualifier from
  `_resolve_repo_name()`/. Emission-only: the `rel` tuples and error
  taxonomy are unchanged.
- **RED**: the shell repro from the spec's SC-1 instrument fails on the
  pre-change tool: in a sandbox holding two stores with a defective file at
  the identical relative path `20/artifacts/pre-spec-inspection.yaml`, at
  least one finding line does not name its repository from the line alone
  (currently both lines read `20/artifacts/pre-spec-inspection.yaml: …`
  with no qualifier), and the two stores' outputs are indistinguishable.
- **GREEN**: compose the qualifier into the printed path at emission time in
  both loops; nothing else in the command changes.
- **Tier marks**: the instrument is an ephemeral shell repro (scratch
  observation in the session's own space — not committed); assertion of the
  committed behavior is carried by Item 2's updated test pins (they move to
  `regression`-class assertions of the qualified form in the existing
  sandbox suite).
- **Instrument**: shell repro per the spec's SC-1 instrument — seed the
  malformed file at `20/artifacts/pre-spec-inspection.yaml` in each of two
  sandbox stores, run `validate-yaml` on each store root in both modes
  (unscoped sweep, and scoped `--number <repo>#20`), assert every finding
  line matches `<repo>/20/artifacts/pre-spec-inspection.yaml:
  <error-class>` with the two runs showing distinct qualifiers; remove the
  seeded artifacts afterward (sandbox copies — deleted with the sandbox).

### Item 2 — updated test pins + suite green (SC-2)

- **Deliverable**: `test_validate_yaml_scoped.py`
  (`test_scoped_report_lines_target_only`, `test_scoped_report_lines_match_format`,
  `test_scoped_output_equals_filtered_workspace`) and
  `test_validate_yaml_exit_codes.py` (`test_validate_yaml_report_lines`)
  updated to pin the qualified `<repo>/<path>: <error-class>` form; the
  qualifier in the scoped harness is the sandbox root's directory name
  (`opencode-config`, already fixed as `REPO_QUALIFIER` there — the same
  name `test_scoped_output_equals_filtered_workspace` composes its
  cross-mode filter against, so the equality assert stays valid with both
  sides qualified).
- **RED**: with Item 1's GREEN in place but the pins still unqualified
  (current HEAD): the four pinned assertions fail on the old
  `<path>: <class>` matches.
- **GREEN**: update the four assertions to the qualified form (scoped:
  `REPO_QUALIFIER + "/" + path_str`; unscoped: the sandbox root name
  `opencode-config + "/" + path_str`). No new test file, no fixture
  restructure.
- **Tier marks**: updated assertions stay in the committed suite —
  `regression` tier (changed area, default gate) — unchanged placement, no
  heavy-tier items added.
- **Instrument**: `cd .opencode && uv run pytest
  tests/test_local_issues/test_validate_yaml_scoped.py
  tests/test_local_issues/test_validate_yaml_exit_codes.py` — exit 0;
  then the full canonical suite `cd .opencode && uv run pytest` — exit 0.

## Dependency order

Item 1 → Item 2: the pins' GREEN form is defined by Item 1's emission
change; Item 1's RED is verified against the pre-change tool, Item 2's RED
against the post-Item-1 tool with stale pins. No cycles.

## Traceability

| Item | SC |
|---|---|
| Item 1 | SC-1 |
| Item 2 | SC-2 |

## Verification summary

- Fact checks: Item 1's emission sites' qualifier sources verified by read
  (stated in Execution surface).
- Authored tests: none new; four existing assertions moved to the qualified
  form — `regression` tier, default gate (Item 2).
- Ephemeral: Item 1's shell repro — session scratch only.
- Cycle-time runs: the Item 2 instrument runs (targeted files, then full
  suite) at implementation; the same two runs repeat at PR-check time.
