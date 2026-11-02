<!-- Intake mirror of the filed request (remote tracker, 2026-10-19T15:50:04Z).
     Mirrored per the issues card's mirror-repair rule (§7) — verbatim filer wording.
     This is the intake document, not yet a spec: spec-creation runs before any
     plan/implementation work, revising this file in place. -->

# .opencode#2643 — legacy-format warning fires permanently on removable open/closed residue — offer a remediation affordance

Observed behavior: every `local-issues` invocation (except `doctor`/`validate-yaml`) in `hermes-ingest-pubmed` printed "Warning: Legacy issue directory format detected in .issues/. Correct format is .issues/{N}/ ... AI agent must inspect and remediate manually." because `.issues/open/` contained three contentless legacy stub records (`003-sub-15-phase-1-ingest-stream`, `004-sub-15-phase-2-ingest-qoc`, `005-sub-15-phase-3-ingest-db` — YAML metadata only, empty bodies, `github_issue: null`, superseded long ago by #15's closed current-format record) plus an empty `closed/` dir. The store was otherwise current-format and `doctor` reported HEALTHY, so the warning was permanent, non-actionable noise on every create/read/close/sync call. Remediation was possible only as a hand-rolled git operation this session (git rm of `open/`, rmdir of `closed/`, commit + push on the `issues-data` branch).

Expected behavior: the tool should offer a remediation affordance for the residue it detects — e.g. a `doctor --remediate-legacy` mode that verifies the legacy records are contentless/unreferenced and removes (or archives) them with a recorded commit, or auto-migrating current-format candidates. At minimum, the warning should not repeat on every invocation for a store whose current-format records are all healthy.

Steps to reproduce: leave an `open/` (or `closed/`) dir in `.issues/`; run `read`, `sync`, `create`, or `close` — the warning fires every time.

Component affected: `.opencode/tools/local-issues` — legacy-format warning path (`_check_legacy_format` region, ~line 2494) and CLI affordances.