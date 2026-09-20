> Full spec and artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2449/

# [SPEC] local-issues list reports [open] for artifact-only dirs without issue.yaml

## Preamble

- **Problem Statement**: `local-issues list` and `search` fabricate ticket state: directories that contain only analysis artifacts (no `issue.yaml`) are reported as `[open]` tickets with an empty title. This phantom state corrupts the issue-store view that agents use for routing and can mask genuinely malformed records. `list` SHALL NOT emit `[open]` for an artifact-only directory, and `search`/`read` SHALL NOT synthesize `status: "open"` for it — verified by sandbox pytest execution with stdout assertions against fixture trees.
- **Root Cause / Motivation**: The two read functions treat `issue.yaml` absence as an ordinary ticket: `_read_issue_title_status` in `.opencode/tools/local-issues` returns `("", "open")` when `issue.yaml` is absent but `spec.md` exists, and `_read_issue_data_in_repo` synthesizes `result["issue"] = {..., "status": "open"}` for yaml-less dirs with plain-markdown specs. Validation (`_validate_issue_dir`) only warns on files that exist; absence of `issue.yaml` is never flagged. It must be solved now because agents route on `list`/`search` output — phantom tickets poison every subsequent session's routing decisions.
- **Approach Chosen**: Fix the two read functions to stop fabricating ticket state when `issue.yaml` is missing: `_read_issue_title_status` returns a sentinel (a `None` status) instead of `("", "open")`, and `_read_issue_data_in_repo` omits the synthesized status. Presentation-layer formatters (`_format_list_output`, `_format_search_results`) then apply one shared, fixed presentation policy: yaml-less directories are marked with the exact token `[artifact-only]` in both list and search output. Follow existing sandbox pytest conventions in `.opencode/tests/test_local_issues/` (pattern: `test_yaml_load_warn_and_skip.py`, issue 2432 error-class taxonomy).
- **Alternatives Considered & Why Discarded**: (1) Add a validation warning in `_validate_issue_dir` for missing `issue.yaml` — discarded because it changes the validate subcommand contract (separate concern, out of scope) and does not fix the fabricated state emitted by `list`/`search`/`read`. (2) Skip artifact-only dirs entirely in `list` output — discarded because silently hiding directories masks malformed records; a distinct marker keeps them visible and greppable. (3) Migrate artifact-only dirs into well-formed tickets — discarded because it mutates tracked issue data as a side effect of a read-path fix.
- **Key Design Decisions**: (1) **Single fixed presentation policy**: the marker token for yaml-less directories is exactly `[artifact-only]` — chosen deterministically at spec time, applied identically by `_format_list_output` and `_format_search_results`. Tradeoff: a fixed token slightly constrains future re-wording, but it makes list/search output deterministic and independently testable. (2) **Sentinel, not exception**: readers return a `None`-status sentinel rather than raising — tradeoff: callers must branch on the sentinel, but read paths stay total functions and well-formed tickets are untouched. (3) **Detection inside readers, presentation in formatters**: keeps the concern map intact — readers decide *whether* state is known; formatters decide *how* it renders. Tradeoff: one extra sentinel hand-off between layers.
- **User Intent / Original Prompt**: Bug report that `local-issues list` shows phantom `[open]` entries for artifact-only directories (same defect family as #2404 and #2394), with a spec requested so the read-path fix lands with per-SC sandbox tests.

## Not Included

- **Validation warning for missing `issue.yaml` in `_validate_issue_dir`** — separate concern (the validate subcommand contract); changing it here would expand scope beyond the read-path fix.
- **Migration of artifact-only dirs into well-formed tickets** — mutating tracked issue data is not a read-path concern.
- **Behavioral `opencode run` tests** — the CLI output is deterministic and fully unit-testable with sandbox pytest; behavioral runs add cost without new signal.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues list` SHALL NOT emit `[open]` for a directory without `issue.yaml`; for such a directory (including a dir whose only file is `spec.md`) it SHALL emit the marker token `[artifact-only]`. | behavioral | Sandbox pytest in `.opencode/tests/test_local_issues/`: fixture tree with an artifact-only dir; run list; assert stdout contains `[artifact-only]` and does not contain `[open]` for that entry. |
| SC-2 | `local-issues search` SHALL NOT synthesize `status: "open"` for a yaml-less directory with a plain-markdown spec; such a result SHALL carry the marker token `[artifact-only]`. | behavioral | Sandbox pytest: fixture tree with a yaml-less spec-only dir; run search against a matching query; assert the result block contains `[artifact-only]` and no synthesized `status: open`. |
| SC-3 | The `read` subcommand SHALL NOT report `status: open` for a yaml-less directory with a plain-markdown spec. | behavioral | Sandbox pytest: fixture tree with a yaml-less spec-only dir; run read on that number; assert output omits `status: open`. |
| SC-4 | Well-formed tickets (directories containing both `issue.yaml` and `spec.md`) SHALL keep their real status in `list`, `search`, and `read` output — the `[artifact-only]` marker SHALL NOT appear for them. | behavioral | Sandbox pytest: fixture matrix with a well-formed control ticket plus artifact-only variants; run list, search, read; assert control ticket shows its real status and no `[artifact-only]` marker. |

## Requirements

- R-1. The `list` subcommand SHALL render every directory lacking `issue.yaml` with the marker token `[artifact-only]` instead of a fabricated `[open]` status.
- R-2. The `search` subcommand SHALL omit any synthesized status for yaml-less directories and SHALL mark such results with `[artifact-only]`.
- R-3. The `read` subcommand SHALL omit `status: open` output for yaml-less directories with plain-markdown specs.
- R-4. The `list`, `search`, and `read` subcommands SHALL NOT alter the rendered status or add the `[artifact-only]` marker for directories that contain both `issue.yaml` and `spec.md`.

## Items

### Item 1 (SC-1): List formatter applies the `[artifact-only]` marker for yaml-less dirs

- RED: Sandbox pytest that creates a fixture tree with an artifact-only dir (spec.md only) and asserts list output contains `[artifact-only]` — fails against current tool, which emits `[open]`.
- GREEN: `_read_issue_title_status` returns a `None`-status sentinel when `issue.yaml` is absent; `_format_list_output` renders the `[artifact-only]` token for sentinel entries.
- verify: Re-run the SC-1 sandbox test plus the existing list tests in `.opencode/tests/test_local_issues/`.
- commit: Sentinel change + formatter change + SC-1 test in one commit.

### Item 2 (SC-2): Search results marked `[artifact-only]` without synthesized status

- RED: Sandbox pytest asserting a search hit on a yaml-less spec-only dir carries `[artifact-only]` and no `status: open` — fails against current tool.
- GREEN: `_read_issue_data_in_repo` omits the synthesized status for yaml-less dirs; `_format_search_results` renders `[artifact-only]` for such results.
- verify: Re-run the SC-2 sandbox test plus existing search tests.
- commit: Reader + search formatter change + SC-2 test in one commit.

### Item 3 (SC-3): Read subcommand omits fabricated status for yaml-less dirs

- RED: Sandbox pytest asserting `read` output for a yaml-less spec-only dir does not contain `status: open` — fails against current tool.
- GREEN: `read` path consumes the same sentinel from `_read_issue_data_in_repo` and renders no status line.
- verify: Re-run the SC-3 sandbox test plus existing read tests.
- commit: Read-path change + SC-3 test in one commit.

### Item 4 (SC-4): Well-formed ticket status preservation matrix

- RED: Sandbox fixture matrix (well-formed control + artifact-only, comments.yaml-only, links.yaml-only, empty dir variants) asserting the control keeps real status and no marker — passes partially against current tool only where the tool already behaves; the control-with-no-marker assertion fails once markers exist without the control guard, and the matrix pins the non-regression.
- GREEN: Guard logic in all three formatters that applies `[artifact-only]` only when `issue.yaml` is absent.
- verify: Run the full matrix test; assert control ticket real status, variants marked, empty dir handled per Edge Cases.
- commit: Guard logic + SC-4 matrix test in one commit.

## Dependencies

- **Reference**: `.opencode/tests/test_local_issues/` sandbox conventions (pattern `test_yaml_load_warn_and_skip.py`, issue 2432 error-class taxonomy)
- **Relationship**: must be read before implementation — tests follow these conventions
- **Status**: satisfied (existing test directory and patterns present)

- **Reference**: #2404, #2394 (michael-conrad/.opencode, remote — both verified OPEN via `gh issue view`)
- **Relationship**: related defects in the same phantom-state family — context only, not a build prerequisite
- **Status**: satisfied (remote-verified, recorded for traceability)

No external dependencies. The tool is single-file (`.opencode/tools/local-issues`).

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-4 | Phase 1 |
| R-2 | SC-2, SC-4 | Phase 1 |
| R-3 | SC-3, SC-4 | Phase 1 |
| R-4 | SC-4 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| local-issues tool | code | `.opencode/tools/local-issues` (`_read_issue_title_status`, `_read_issue_data_in_repo`, `_validate_issue_dir`, `_format_list_output`, `_format_search_results`, `_search_in_repo`) | read (pre-spec inspection, grep-verified definitions) |
| Sandbox test conventions | code | `.opencode/tests/test_local_issues/test_yaml_load_warn_and_skip.py` | read (pre-spec inspection) |
| Related defect family | issue | #2404, #2394 (michael-conrad/.opencode, remote) | read (remote — `gh issue view 2404` / `2394` confirm both OPEN; 2404: autonumber counter, 2394: cross-repo numbering) |
| Issue 2432 error-class taxonomy | issue | `.opencode/.issues/2432/` | read (issue history) |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

- **SC-1:** Running the list fixture test costs one sandbox pytest run — minutes of agent time. Skipping costs every future agent session wasted routing decisions on phantom `[open]` tickets — repeated misroutes and re-debugging of this defect family (#2404, #2394). Correctness is the only metric.
- **SC-2:** Running the search fixture test costs one sandbox pytest run — minutes of agent time. Skipping costs silent fabricated state in search results that corrupts every downstream query consumer — defects discovered far from their cause. Correctness is the only metric.
- **SC-3:** Running the read consistency test costs one sandbox pytest run — minutes of agent time. Skipping costs divergence between read and list/search views of the same directory — agents trust one view and get another. Correctness is the only metric.
- **SC-4:** Running the preservation matrix costs one sandbox pytest run with a small fixture tree — minutes of agent time. Skipping costs regression risk: the marker leaking onto well-formed tickets would corrupt the real issue store view — the exact defect this spec exists to remove. Correctness is the only metric.

## Edge Cases

- **Input boundary — empty directory (no files at all):** list/search SHALL NOT emit a fabricated `[open]` entry; an empty dir is not a ticket. Expected behavior: excluded from ticket enumeration (current tool behavior preserved); Resolution: reader returns the not-a-ticket condition, formatter skips it.
- **Input boundary — metadata-only dir (`comments.yaml` or `links.yaml` without `issue.yaml` or `spec.md`):** same treatment as spec-only dirs — `[artifact-only]` marker, no synthesized status. Expected behavior: marked, not skipped; Resolution: absence of `issue.yaml` is the sole trigger, file combination is irrelevant to the policy.
- **State transition — dir gains an `issue.yaml` later:** the `[artifact-only]` marker disappears and real status renders on the next list/search/read. Expected behavior: policy is computed per invocation, never cached; Resolution: reader consults `issue.yaml` presence on every read.
- **Failure mode — malformed `issue.yaml` (present but unparseable):** out of this spec's trigger set — the dir HAS an `issue.yaml`, so the `[artifact-only]` policy does not apply. Expected behavior: existing parse-error handling (issue 2432 taxonomy) governs; Resolution: none here — validation concern, excluded scope.
- **Concurrency — concurrent writes during read:** readers may see a partially written dir. Expected behavior: same as today — absence of `issue.yaml` at read time yields the `[artifact-only]` policy; Resolution: read paths remain non-mutating and idempotent; a subsequent read reflects the completed write.
- **Recovery:** none required — the fix removes fabrication; any agent that previously routed on a phantom ticket recovers by re-running `list`/`search` after the fix, which now reports truthful state.

## Verification

Per-SC unit tests in `.opencode/tests/test_local_issues/` using sandbox fixture trees; RED first against current tool, then GREEN. Evidence type: behavioral — sandbox pytest execution with stdout assertions against the CLI output. No behavioral `opencode run` tests required — tool is deterministic CLI, fully covered by sandbox pytest execution.

---

## Change Control

- 2026-09-19 — Revised per spec-creation validate FAIL findings: (1) added missing required sections per spec-structure-standards (preamble 6 fields, Not Included, Requirements, Items, Dependencies, Traceability, Enforcement Gate, Cost Frame, Edge Cases, Documentation Sources); (2) added per-SC cost frames (dark-prose-007); (3) SC table restructured to canonical 4 columns with Verification Method; (4) fixed presentation policy to a single deterministic decision — marker token is exactly `[artifact-only]` (determinism finding); (5) split compound SC-3 into atomic SCs (SC-1 list, SC-2 search, SC-3 read, SC-4 well-formed preservation) so each SC is independently verifiable and SC-1 no longer depends on SC-3's policy; (6) redeclared evidence types from `semantic` to `behavioral` to match sandbox pytest execution with stdout assertions (EVIDENCE_TYPE_MISMATCH); (7) removed line-number references per spec-structure-standards prohibited content. Preserved all 3 root-cause fixes (list reader `_read_issue_title_status`, search/read synthesis `_read_issue_data_in_repo`, shared presentation policy). Authorized by: spec-creation validate gate (revision_reason: must reach 100% clean pass).

---

- 2026-09-19 — Revised per spec-audit round-1 evaluator verdict DRAFT (Provenance dimension FAIL): (1) replaced fabricated `_search_issues_in_repo` citation with the actual search-path symbol `_search_in_repo` (grep-verified definition at line 1586 of `.opencode/tools/local-issues`; the formatter `_format_search_results` is at line 1617); (2) re-verified related defects #2404/#2394 on the remote tracker via `gh issue view` — both confirmed OPEN on michael-conrad/.opencode, so the citation was kept and its verification method corrected from "read (issue history)" to explicit remote-read with evidence. No SC criterion was touched. Authorized by: spec-creation revise task (revision_reason: spec-audit round-1 holistic Provenance FAIL).


Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
