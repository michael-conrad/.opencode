<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2382 -->

# Plan — gb pr close 404 caveat (gb-cli card) + issues-card local/remote routing correction

Source: `.opencode/.issues/2382/spec.md` (authoritative). Every item traces to
a spec requirement (R-1…R-7) or the spec's success criterion (SC-1); the
traceability table in the spec ties all of them to SC-1's behavioral outcome.
Feature branch: `feature/2382-pr-close-404-caveat` in the `.opencode`
submodule, cut from a fresh `main`.

## Dependency order

Item 1 → Item 2 → Item 3 → Item 4. Item 2's caveat wording depends on the
condition set Item 1 pins; Items 3 and 4 are independent of Item 2's wording
but sequenced after it so the deck edits land as one coherent reviewable
change. Item 4 (the SC-1 probe) runs against the corrected cards, so it is
last. R-5 (diff confinement) and R-6 (provenance) are verified inside Items 2
and 3's instruments and re-checked at the verify gate — no separate item.

## Item 1 — Pin the deleted-branch failure condition by reproduction (R-1)

- **Deliverable:** a reproduction transcript at
  `.opencode/.issues/2382/artifacts/repro-deleted-branch-pr-close.md`
  recording, for each of three PR conditions (deleted head only, deleted base
  only, both deleted): whether `gb pr close` fails and with what HTTP status,
  and whether `gb pr edit <N> --state closed --web` succeeds.
- **Trace:** R-1.
- **RED:** the transcript file does not exist; the failure condition is
  uncharacterized (assertion: read of the artifacts directory finds no
  transcript — fails now).
- **GREEN:** run the reproduction on a non-production GitBucket — the
  behavioral-testing harness's self-contained GitBucket container
  (behavioral-testing skill governs the harness; production repositories are
  never touched). In the container: create a repository, open one PR, and
  produce the three branch-deletion conditions; attempt `gb pr close` and
  `gb pr edit --state closed --web` per condition, capturing commands and
  raw outputs. Behavioral work routes through the behavioral-testing skill;
  no ad-hoc remote API calls.
- **Instrument:** the stored transcript exists and contains a per-condition
  row for all three cases with observed statuses; the caveat wording in Item 2
  is written from this transcript's observed condition set only.

## Item 2 — gb-cli §4 caveat, fallback, and provenance (R-2, R-3, R-4, R-6)

- **Deliverable:** a single-digit-line edit to
  `.opencode/skills/gb-cli/SKILL.md` §4 (Platform awareness): the caveat for
  PR state mutation stating the failure condition exactly as Item 1 pinned it,
  `gb pr edit <N> --state closed --web` named as the sanctioned fallback, the
  exception placed adjacent to the existing "(`PATCH .../pulls/{n}` accepts
  `state`)" claim inside the same §4 entry, and provenance front-matter and
  SPDX comment citing `.opencode#2382`.
- **Trace:** R-2, R-3, R-4, R-6 (gb-cli card).
- **RED:** `grep -n "accepts \`state\`" .opencode/skills/gb-cli/SKILL.md`
  shows the claim with no deleted-branch exception in the same entry, and
  `grep -n "pr edit" .opencode/skills/gb-cli/SKILL.md` finds no fallback
  command — both fail now, pass after the edit.
- **GREEN:** apply the edit; no other file or section changes.
- **Instrument:** the greps above pass post-edit; `gb pr edit --help`
  confirms `--state` and `--web` exist (R-3's CLI-surface check); the caveat's
  condition string matches Item 1's transcript; the diff shows only §4 lines
  plus the two provenance lines changed.

## Item 3 — Issues-card §7 routing correction and reference update row (R-7, R-6)

- **Deliverable:** edits to `.opencode/skills/issues/SKILL.md` §7
  (mirror-repair) and `.opencode/skills/issues/references/local-issues-cli.md`
  (`update` row): §7 ceases attributing the remote-body pointer correction to
  `update --github` and routes the remote correction through the
  platform-appropriate card (gh-cli / gb-cli) per the card's own §1; both
  files state the local/remote boundary explicitly — local-issues commands
  manage only the local issues-data store and never contact any remote
  issues-system API on any platform; both files' provenance cites
  `.opencode#2382`.
- **Trace:** R-7, R-6 (issues card + reference).
- **RED:** `grep -n "update --github" .opencode/skills/issues/SKILL.md`
  finds §7 attributing the remote pointer correction to that command, and the
  reference's `update` row carries no local-only statement — both fail now.
- **GREEN:** apply the two edits; no other file, section, or row changes; the
  `local-issues` tool script itself is untouched (the correction is
  instructional).
- **Instrument:** exhaustive read of both short files post-edit: no
  instruction attributes a remote correction to a local-only command; both
  state the doctrine explicitly; the diff touches only the named sentence(s),
  row, and provenance lines.

## Item 4 — SC-1 behavioral comprehension probe (SC-1)

- **Deliverable:** a fresh-context comprehension probe transcript at
  `.opencode/.issues/2382/artifacts/sc1-routing-probe.md` with a PASS/FAIL
  verdict.
- **Trace:** SC-1.
- **RED:** no probe transcript exists; SC-1 unverified (assertion: read of
  the artifacts directory — fails now).
- **GREEN:** dispatch one fresh-context agent that loads only the corrected
  issues card (`.opencode/skills/issues/SKILL.md` as it stands after Item 3),
  present the two scenarios (update the local store record for a qualified
  `repo#N`; edit the remote tracker's issue body for the same `repo#N`), and
  record the routing the agent states. Behavioral work routes through the
  behavioral-testing skill. PASS requires: local-issues for the first
  scenario, the platform card for the second, and no local-issues attempt for
  the remote operation.
- **Instrument:** the stored probe transcript with the agent's stated routing
  for both scenarios and the verdict; a FAIL verdict remediates the card
  wording and re-runs the probe with a fresh agent until PASS.

## Out of scope (per spec)

Attic'd card resurrection; any file beyond the three named above; root
`AGENTS.md`; new `references/` detail cards; production-repo mutation;
changes to the `local-issues` tool script.

---
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
