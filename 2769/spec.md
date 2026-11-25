# .opencode#2769 — local-issues: remote-tracker number as record identity anchor (migration, sweep detection, mirror-repair doctrine)

## 1. Intent and Executive Summary

**Problem Statement** — For every issue store with a live remote tracker
(host-mapped GitBucket via `local-issues-host-maps.conf`, or github.com), the
tracker-assigned number is the record's identity anchor in doctrine (issues
card §2 remote-first reservation; sync-mirroring "remote-first number
reservation"), but three surfaces do not hold the anchor. First, no tool
surface detects a local record whose folder number disagrees with its tracker
identity: the record-minting incident is observed, not hypothetical —
`NewSRX-Tech-LLC/ClinicaltrialsStagingLoader` minted its sole ticket record at
counter-derived `2440/` on 2026-09-18 while the tracker had assigned the same
ticket `issues/1`, and no tool surface flagged the divergence for 2+ months; a
downstream developer question surfaced it. Second, no doctrine text guards the
mirror-repair moment: the 2026-11-23 repair session created the correct local
`1/` record, deleted it 44 seconds later, kept the phantom `2440/`, and wrote
a spec-audit validation record onto the phantom (store history `c6c2dbd` →
`c6fad10`, 11:22–11:26 EST, corroborated by the sibling report `.opencode#2770`'s
forensic commit inventory). Third, no defined disposition exists for stores
already diverged when discovery arrives — the one known store was reconciled
ad hoc.

**Root Cause / Motivation** — Record identity lived in agent judgment and
card prose, with enforcement asymmetry at the tool. The write side is hard:
`create` requires an explicit `--number` and mints nothing (verified this
triage: zero `.counter` references in the tool source; the counter-derivation
mechanism the filed report names was the attic-era deck's, removed with the
pre-rip task lists — `.opencode#2774`'s audit-verified sweep). But every
read-only surface is blind to identity: `doctor` emits branch-state,
merge-base-delta, worktree, and classification markers only; `validate-yaml`
carries the SC-05 YAML-shape taxonomy only (both verified this triage against
the tool source at the trunk tip). So a record holding the wrong number passes
every health and shape check indefinitely. The issues card's §7 mirror-repair
text names creating at the remote-assigned number but does not carry the
anchor doctrine that stops a repair session from following the stored phantom
precedent, and no text anywhere defines the reconciling disposition for the
stale counter-derived store population that outlives the mechanism which
created it.

**Approach Chosen** — Three parts, all in `.opencode` (single-repo scope):
(1) tool — record-identity divergence checks in the read-only validation
sweep: `validate-yaml` carries the per-record check (on a tracker-host store,
every record carries a resolvable `remote_url`; the folder number matches the
issue number the recorded identity names; the identity's repo slug matches the
store's repo), computed from locally stored facts only — host maps, origin,
record fields — never contacting a remote issues-system API, the §7 boundary
held; `doctor` MAY surface a repo-level rollup marker. (2) card — the issues
card's §7 mirror-repair block carries the identity-anchor doctrine (the
just-created correct record is never deleted in favor of a stored phantom
folder; a stored pointer naming a different folder is the defect to repair,
never the precedent to follow) and the diverged-store reconciliation
disposition: renumber local folders and in-record pointers to the
tracker-assigned number using the existing `renumber` command, with pointer
corrections (remote body via the platform CLI; local cross-references) in the
same reconciliation workflow. (3) delivered sibling — the card-doctrine
acquisition half (number-acquisition recipe, selection prohibition, tracker
decidability, agnostic pointer spellings) landed via `michael-conrad/.opencode#2774`
(closed 2026-11-25); this spec holds the tool-side and §7 residual, tracking
each class in its own ticket.

**Alternatives Considered & Why Discarded** —

1. *#2723 warn→refuse redecision* — the sibling `.opencode#2774` deferred its
   strongest rejected lever ("tool-layer refusal of local-minted `create` on
   remote-host stores") to "2769's tool work". Rejected on a ground the
   deferral did not carry: refusal requires deciding that a supplied number is
   not remote-sourced, and the tool never contacts a remote issues-system API
   (the §7 boundary #2723's own text states); no locally available fact
   separates a remote-sourced number from a fabricated one, so refusal is
   unimplementable without widening a boundary that is not this change's to
   widen. Detection (R-2) plus doctrine (R-4) carry the gap instead.
2. *Alias disposition for already-diverged stores* (the filed report's option
   B: keep legacy folders, register both numbers as cross-linked aliases) —
   rejected: it institutionalizes the forked number space permanently and
   forces alias resolution into every exact-match lookup path, contradicting
   the delivered doctrine that the remote-returned number **is** the number;
   renumbering composes with the existing `renumber` primitive and clears the
   divergence permanently.
3. *Bulk automated migration* (the tool auto-renumbers every diverged store on
   discovery) — rejected: a silent bulk mutation of store folders crosses the
   hygiene mandate's judgment line and contradicts the sweep's read-only
   contract; reconciliation stays agent-executed on discovery with the
   single-record `renumber` primitive (unchanged), the mutation moment gated
   by §7 doctrine.
4. *Extend the delivered #2774 change instead of a separate spec* — rejected:
   its delivered scope explicitly excludes the script and the migration (its
   Not-Included section routes both here), and its own ground for splitting
   was the all-or-nothing completion gate over mixed deliverables.

**Key Design Decisions** —
- *`validate-yaml` carries the identity check* — tradeoff: it already scans
  each record directory (SC-05 taxonomy, `.opencode#2450`'s scoped mode,
  `.opencode#2755`'s validator role), so the check composes with existing
  scoped-run and exit-code semantics; `doctor` stays repo-level and may roll
  up a count. One canonical carrier for record-level checks.
- *Fact-decidable predicates only* — presence of `remote_url` on
  tracker-host-store records, parse of the issue number and repo slug out of
  that stored identity, folder-number and origin comparison — every predicate
  decidable from local state; the remote-API-contact boundary is preserved and
  named as a design constraint, per the report's own classification input.
- *Renumber as the reconciliation disposition* — tradeoff: folder renames
  rewrite store paths that cross-references point into; the store is a git
  branch (history preserved, revertible) and the disposition requires pointer
  corrections in the same workflow, so the rewrite lands resolved rather than
  lingering as aliases.
- *Detection keyed on each record's own stored identity* — tradeoff: a
  divergence the record itself conceals (a remote-host-era record with no
  `remote_url` at all) is caught by the presence check, but a divergence that
  requires reading the tracker live (the record stores a plausible but wrong
  identity) is out of the sweep's reach by the boundary — those stay in the
  agent workflows the boundary already governs.
- *`.counter` untouched* — remoteless-store reserve state and post-filing
  maintenance per the #2774-delivered issues §2 text; no new coupling.

**User Intent / Original Prompt** (verbatim, dated) —
1. 2026-11-24, filed report (this record's original body): "The `local-issues`
   tool derives local issue-store folder numbers from a store-local
   `.counter`, even when the repository has a live remote tracker that assigns
   its own number via the API. The two number spaces diverge, so a ticket
   carries two non-matching identities … and operations literally targeting
   the remote number — read, audit dispatch, `create --number repo#N`
   mirror-repair — either miss the existing local record or fabricate a
   duplicate record for the ticket."
2. 2026-11-24, routed triage ground (canonicalized from `.opencode#2770`):
   "the remote-tracker-assigned number is the store record's identity anchor
   for any live-tracker store — divergence must be prevented at derivation
   (#2774's delivered card-doctrine half; this report's tool half), detected
   when it slips through, and unmissable during mirror-repair."
3. 2026-11-24, developer directive continuing the work: "triage and spec audit
   .opencode#2769".
4. 2026-11-24, sibling cycle's scoping directive (`.opencode#2774`'s
   provenance): "proceed to spec, do not alter the script local-issues" —
   that cycle's exclusion, whose tool-side residual this spec holds.

## 2. Not Included

- **The card-doctrine acquisition half** (spec rule 5 acquisition recipe,
  selection prohibition, counter-advance relocation, tracker-decidability
  sentences, agnostic pointer spellings) — delivered via
  `michael-conrad/.opencode#2774` (closed); this spec composes with its text
  and re-opens none of it.
- **#2723 warn→refuse redecision** — unimplementable without widening the
  tool's remote-API-contact boundary (discarded alternative 1); the warn
  surface stays as is under R-1.
- **Tool-side remote-body pointer correction** — the tool never contacts a
  remote issues-system API; pointer corrections at reconciliation stay
  agent-executed through the platform CLI per the issues card §7.
- **`renumber` behavior changes** — the existing primitive is unchanged; the
  disposition is doctrine over it.
- **Attic cleanup** — preserved unloaded, pending soak and deletion under its
  own plan.
- **Root-repo (`opencode-config`) source changes** — none; the deliverable is
  the `.opencode` tool, the deck's issues card, and the store artifacts.

## 3. Requirements

- **R-1** — The `local-issues` tool SHALL treat the remote-tracker-assigned
  number as the only registration identity on tracker-host stores: `create`
  SHALL require an explicit `--number repo#N`, SHALL never mint, derive, or
  default a number from store state (`.counter`, folder enumeration, or any
  other local input), and the creation-time divergence warning (#2723) SHALL
  remain in force.
- **R-2** — The tool's read-only validation sweep SHALL detect record-identity
  divergence: on a tracker-host store, `validate-yaml` SHALL report each
  record that (a) lacks a resolvable `remote_url`, or (b) carries a
  `remote_url` whose issue number disagrees with the record's folder number,
  or (c) carries a `remote_url` whose repository slug disagrees with the
  store's repository identity — each as a named error class in the existing
  machine-greppable report form; the check SHALL use only locally stored facts
  (host maps, origin, record fields) and SHALL NOT contact any remote
  issues-system API; the scoped `--number` form and the exit-code semantics
  SHALL follow the existing scan behavior (#2450).
- **R-3** — The issues card's §7 mirror-repair block SHALL state the
  reconciling disposition for already-diverged stores: local folders and
  in-record pointers are renumbered to the tracker-assigned number via the
  existing `renumber` command, pointer corrections (remote body via the
  platform CLI; local cross-references) are performed in the same
  reconciliation workflow, alias-keeping is not the disposition, and a
  collision at the target number is resolved from the records' identities —
  never silently overwritten.
- **R-4** — The issues card's §7 mirror-repair block SHALL state the
  identity-anchor doctrine making the anchor unmissable at the repair moment:
  the remote-assigned number is the record's identity anchor; the just-created
  correct record is never deleted in favor of a stored phantom folder; a
  stored pointer naming a different folder is the defect to repair, never the
  precedent to follow.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | `create` still requires an explicit `--number`, the source carries no store-state number-derivation input, and the #2723 creation-time divergence warning and its fork-consequence wording remain in the create path | structural | run `./.opencode/tools/local-issues create -h` — its argument list names `--number` required; read the create path's #2723 emission site — the warning and its wording present; sweep the tool source for store-state number-derivation symbols — none present |
| SC-2 | The validation sweep flags identity divergence and stays silent on consistent records: on a scratch store copy, a tracker-host record lacking `remote_url` and one carrying a `remote_url` naming a different issue number each produce a named error-class line, a mismatched repo slug produces one, and records whose stored identity agrees with their folder number produce none; the run needs no network | behavioral | seeded scratch-store run of `./.opencode/tools/local-issues validate-yaml` (executed offline), reading the emitted error-class lines and exit code |
| SC-3 | The issues card §7 mirror-repair block carries the diverged-store reconciliation disposition of R-3 (renumber to the tracker-assigned number, same-workflow pointer corrections, no alias disposition, collision resolution from identities) | structural | read/grep of `skills/issues/SKILL.md` §7 mirror-repair block |
| SC-4 | The issues card §7 mirror-repair block carries the identity-anchor doctrine of R-4 (the anchor statement, the anti-phantom-precedent prohibition, and the stored-pointer-is-the-defect rule) | structural | read/grep of `skills/issues/SKILL.md` §7 mirror-repair block |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `michael-conrad/.opencode#2774` (closed) | delivers the card-doctrine acquisition half this spec composes with; its Not-Included routes the tool-side residual here | satisfied |
| `.opencode#2723` (delivered) | creation-time warning surface R-1 preserves; its remote-API-contact boundary is the ground rejecting the refusal alternative | satisfied |
| `.opencode#2450` (delivered) | scoped `validate-yaml` semantics the detection inherits (scan form, scoped mode, exit codes) | satisfied |
| `.opencode#2755` (delivered) | the sweep's validator role and repair-flow contract the new error classes join | satisfied |
| `.opencode/tools/local-issues` source | the change's edit surface (sweep checks); present at the trunk tip | satisfied |
| `local-issues-host-maps.conf` | tracker-host fact source for the presence predicate | satisfied |
| `skills/issues/SKILL.md` §7 | the card block R-3/R-4 amend | satisfied |
| `skills/spec/references/remote-body-format.md` | remote-body shape for the reconciled record | satisfied |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1 |
| R-2 | SC-2 |
| R-3 | SC-3 |
| R-4 | SC-4 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Tool mints nothing; `--number` required | tool source + CLI | `.opencode/tools/local-issues` (create parser; zero `.counter` references anywhere in the 117k-char file) | grep sweep + `create -h` read, 2026-11-24 (this triage) |
| Read-only surfaces carry no identity check | tool source | `cmd_doctor`/`_doctor_repo_report` (branch-state, merge-base, worktree, classification markers) and `cmd_validate_yaml` (SC-05 taxonomy; docstring); `#2450` scoped mode | read, 2026-11-24 (this triage) |
| Identity-derivation mechanism absent from live tool | sibling spec | `.opencode/.issues/2774/spec.md` §7 (absence sweep incl. docstrings; mechanism located in attic task lists) | read 2026-11-24 (this triage); authored and delivered 2026-11-24 |
| Incident: counter-derived `2440/` vs tracker `issues/1` | filed records | `.opencode#2769` original body (commit `f30a11a`, 2026-09-18) and `.opencode#2770` forensic reproduction (commit inventory, API 404 for `issues/2440`) | read 2026-11-24; two independent filed records name the same store-commit SHAs; the host store itself is a foreign repo outside this session's target set, not re-opened here |
| Backwards repair: `1/` created then deleted 44s later | filed records | store history `c6c2dbd` → `c6fad10` (2026-11-23 11:22–11:26 EST), recorded in `.opencode#2769` body and `.opencode#2770` | read 2026-11-24 |
| Sibling delivered (card-doctrine half) | sibling record + card text | `.opencode/.issues/2774/` (closed 2026-11-25) and the live issues card §2 text carrying the acquisition recipe, prohibition, decidability sentence, agnostic spellings | read, 2026-11-24 |
| Live §7 mirror-repair text (the block R-3/R-4 amend) | deck card | `.opencode/skills/issues/SKILL.md` §7 | read, 2026-11-24 |
| `remote_url` field + `update --remote-url` surface | tool CLI | `update -h` flag inventory | read, 2026-11-24 (this triage) |
| `renumber` primitive exists | tool CLI | parser inventory (`renumber` subcommand) | read, 2026-11-24 (this triage) |
| Tracker-host fact source | store config | `local-issues-host-maps.conf` (committed host-maps) | file present in repo, 2026-11-24 |
| Pull-only classification handling | tool source | `_doctor_repo_report` pull-only branch (`#2667`) | read, 2026-11-24 (this triage) |

## 8. Cost Frame

- **SC-1 (structural, tool)** — acting: one CLI help read plus one grep sweep,
  seconds, offline. Skipping: the identity-anchor constraint rests on an
  unverified tool invariant while the change touches the same file — a
  regression to derivation would pass unnoticed at the write surface.
- **SC-2 (behavioral, sweep)** — acting: seeding a scratch store copy and one
  offline run, minutes. Skipping: the deliverable's entire tool-side gap — the
  2+ months of undetected divergence the incident showed — stays unverified,
  and the sweep's new classes could be present but wrong (silent on divergence,
  noisy on consistent records) with nothing to show it.
- **SC-3/SC-4 (structural, card)** — acting: one read/grep pass over the §7
  block, seconds, offline. Skipping: the repair doctrine stays un-guarded and
  the next diverged-store discovery repeats the phantom-precedent behavior the
  incident recorded.

## 9. Edge Cases

| # | Condition | Expected behavior | Resolution |
|---|-----------|-------------------|------------|
| 1 | Remoteless store (no tracker) | Identity checks skip entirely; counter-selection semantics unchanged; no sweep noise | none — behavior preserved (R-2 keys on tracker-host stores) |
| 2 | Pull-only repo (no store, #2667) | Sweep reports the same absent-by-design classification the health sweep uses; no false identity failure | mirrors existing `_doctor_repo_report` handling |
| 3 | Tracker-host record predating the `remote_url` field | Flagged under the missing-identity class; repaired agent-side via `update --remote-url` (hygiene), then clean | R-2(a) + issues card §2 pointer write |
| 4 | `remote_url` naming a different repo's slug | Flagged under the repo-slug mismatch class | R-2(c) |
| 5 | Tool run with no network | Detection unaffected — every predicate is a local fact; no remote contact occurs by design | boundary preserved (design constraint) |
| 6 | Mid-reconciliation pointer-correction failure (network/auth) | The remote body is never left carrying an unresolvable pointer — reconciliation BLOCKs at the failure per the existing blocking rule | issues card §7 + spec card rule 5 flow |
| 7 | Renumber target number occupied by another local record | Identities (per-record sweep classes) decide which record is misnumbered; renumber proceeds only after the target is free; a genuine two-ticket collision is escalated as a judgment case, never silently overwritten | R-3's collision clause |
| 8 | Record stores a plausible but wrong tracker identity (sweep-clean, live-tracker-divergent) | Out of the sweep's reach by the remote-API-contact boundary; caught in agent workflows (tracker read, audit dispatch) the boundary already governs | design constraint stated in Key Design Decisions |

## 10. Completion gate

Every success criterion (SC-1 through SC-4) passes before the deliverable is
complete; partial implementation is not permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
