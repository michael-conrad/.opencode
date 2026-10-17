## Problem

The platform `glob` tool silently returns no results for paths inside git
submodules. During file discovery, an agent that globs a submodule path
receives "No files found" for files that exist, reads that as ground truth,
and concludes the files are absent — producing false-absence reports and
downstream failed work.

The failure window is pre-card: file discovery routinely happens before any
skill card is loaded, and no card gates reaching for `glob`. On-demand deck
content (guidelines, skill references) loads only after the failure can
already have occurred. The only always-injected instruction surface is
`floor.md`.

## Evidence

- Live reproduction (2026-10-17, the deck's holding repo, which contains a
  registered submodule at `.opencode`):
  - `glob("**/*.md")` at the repo root returned 15 files, all parent-repo
    paths — zero entries under the submodule.
  - `glob(".opencode/skills/*/SKILL.md")` returned "No files found" for
    files verified to exist by direct read and directory listing.
- `.opencode` is a registered git submodule (`git submodule status`) and the
  parent `.gitignore` contains no matching entry, so ignore-file semantics do
  not explain the omission.
- Original incident record (.opencode#1394 investigation, 2026-06-25): the
  same behavior was investigated after failed implementations attributed to
  it, and the deck at that time contained extensive instructions routing
  agents to `glob`.

## Root cause

1. `glob` excludes submodule content from its results (observed; whether
   this is a platform defect or by-design submodule opacity is undetermined
   — the undetermined status does not gate this fix).
2. The result is silent: empty glob output is indistinguishable from genuine
   absence.
3. Agents reach for `glob` during file discovery before any card is loaded,
   so no on-demand surface can intervene in time; only the always-injected
   floor is guaranteed present at the moment of failure.

## Scope

Add exactly one line to `floor.md`'s Environment section stating that `glob`
does not traverse submodules and directing submodule file discovery to other
tools (R-1). The work also adds the behavioral verification scenario required
by SC-3 under `tests-v2/` (a tracked deck surface). No other deck content
changes.

## Requirements

- R-1: `floor.md` SHALL contain, in its Environment section, exactly the
  following line, verbatim and byte-exact:

  > - The `glob` tool does not traverse submodules — "no files found" there
  >   is false absence; use `grep`, `read`, or `bash` for submodule file
  >   discovery.

  As specified, the line is a single line and root-agnostic: it names no
  repository, owner, or absolute path.

## Approach

An always-loaded one-line note in `floor.md`'s Environment section.
Alternatives weighed:

- Blanket permission deny of `glob` (config or per-card) — rejected: `glob`
  works correctly outside submodules, so a deny removes a working tool to
  fix a bounded failure, and reaching built-in sub-agent types requires the
  heavier central-config mechanism.
- On-demand documentation in a guideline or skill reference — rejected:
  loads after the failure window (root cause 3).
- Upstream platform fix — parked: whether submodule opacity is defect or
  by-design is undetermined and does not gate the note.

## Out of scope

- Permission-layer denial of `glob` (central config or per-card) — a
  rejected alternative, not a defect fix.
- Scrubbing `glob` references from the skill deck — the pre-rip deck
  retirement already removed all live glob-tool references; the current live
  deck contains none (surveyed `skills/`, `guidelines/`, `agents/`,
  `plugins/`, `prompts/`, `floor.md`; the only remaining hits are the
  generic verbs "globally" and "globbing").
- Upstream investigation of `glob`'s submodule handling.
- The stale enforcement-test mapping `tests-v2/test-enforcement.sh:145` →
  `guidelines/060-tool-usage.md` (a retired file) — separate defect, different
  surface.

## Impact

- Consumers: every agent session on every repo mounted with this deck — the
  floor is always-injected, so the note costs one line of tokens per session.
- Risk: advisory content only; no enforcement, no permission change;
  regression risk is limited to wording ambiguity, bounded by R-1's fixed
  content contract.
- Blast radius: `floor.md` (submodule), the SC-3 behavioral scenario script
  under `tests-v2/behaviors/`, and this spec's issues-data record. No source
  code; no other deck files.

## Success Criteria

| ID | Criterion | Class | Verification instrument |
|----|-----------|-------|-------------------------|
| SC-1 | `floor.md`'s Environment section contains exactly the R-1 line, verbatim | structural | `rg -F -x` exact-line match of the R-1 line against `floor.md` returns exactly 1 match, located between the `## Environment` heading and the next `## ` heading |
| SC-2 | The `floor.md` modification consists of exactly one added line — the R-1 line — with no lines removed | structural | The `git diff` of the `floor.md` change contains exactly one `+` line and it matches the R-1 line (`rg -F`), and zero `-` lines |
| SC-3 | An agent with the revised floor loaded, assigned a task requiring discovery of known-existing files under a submodule path, reports those files as present (no false absence) | behavioral | tests-v2 behavioral scenario: dispatch an agent on a submodule file-discovery task whose ground truth is pre-verified; assert the agent's final report names the target files as present; session evidence extracted via `session-to-timeline` |

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
