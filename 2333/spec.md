> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2333/

## Problem

The spec-creation pipeline contradicts itself on analytical-artifact lifecycle. `skills/spec-creation/tasks/revise.md` Step 7 orders wholesale deletion of `{project_root}/{path}/.issues/{N}/artifacts/`, while `skills/spec-creation/tasks/validate.md` requires that same directory populated and cross-references its contents against the live spec. Revision therefore destroys state the same pipeline's validation gate depends on — and because `.issues/` is a pushed worktree on the `issues-data` branch, every execution commits a historical deletion that silently breaks spec-body citations until someone restores the files by hand (live data loss on #2327).

## Evidence (all independently re-verified 2026-08-26)

1. **Deletion instruction** — `skills/spec-creation/tasks/revise.md` Step 7 / item 7.1 (verbatim): "Delete all files in `{project_root}/{path}/.issues/{N}/artifacts/` to ensure stale artifacts from the previous spec version do not accumulate. Use `rm -rf {project_root}/{path}/.issues/{N}/artifacts/` …". Exit Criteria repeat it ("Stale analytical artifacts deleted from …").

2. **Conflicting validation requirements** — `skills/spec-creation/tasks/validate.md`:
   - Entry criterion (line ~16): "Analytical artifacts directory exists at `{project_root}/{path}/.issues/{issue_number}/artifacts/`".
   - Item 3.6 "Artifact cross-reference check": verifies blast-radius, concern-map, interface-compatibility, and testability-assessment alignment between spec and artifact contents; per-artifact checks include "The artifact file exists and is non-empty" and "The spec's claims are consistent with the artifact's findings".

3. **Live incident (michael-conrad/.opencode#2327)** — revision sync commit `a2b68f6b` deleted all 12 files under `.issues/2327/artifacts/` from the pushed `issues-data` tip while `2327/spec.md` still cited them (Dependencies table row "Dependency DAG in `decompose-output.yaml` … satisfied", Documentation Sources row "Analysis artifacts for this spec (12 files)", SC-7 verification method "post-copy contents"). Holistic validation returned aggregate PASS only via history-recovery warnings; restoration commit `cb0ea88b` re-added all 12 files verbatim from parent commit `19833392`.

4. **Systematic pattern predating the incident** — committed deletions inside range `19833392..HEAD` of the `issues-data` branch (verified via `git -C .opencode/.issues log --diff-filter=D --name-only`):
   - `ca8224ae` — all 8 files of `2319/artifacts/`
   - `c68a29b1` — all 8 files of `2322/artifacts/` **and** all 8 files of `2324/artifacts/`
   - `a2b68f6b` — all 12 files of `2327/artifacts/`
   - Older equivalents exist further back (`9e8b7d0e` #2318, `66e7d900` #2116, `7a4f0a47` #2254, `1c716d60` #2132, `ba7ec840` #2201).

### Conflict Parties

| Party | Position |
|---|---|
| `skills/spec-creation/tasks/revise.md` Step 7 | After any revision, artifacts directory MUST be empty (delete-all via `rm -rf`) |
| `skills/spec-creation/tasks/validate.md` entry + item 3.6 | Artifacts directory MUST exist and its contents MUST align with the current spec claims |
| Durable-anchor citation principle (`guidelines/065-verification-honesty.md`, extended by open #2327) | Specs may only cite durable anchors; pushed `issues-data` artifact paths qualify precisely when they are not deleted by later commits |
| Issue #2327's own subject matter | Persists per-SC verdict records into `.issues/{N}/artifacts/` as *analysis content* and cites them as durable evidence |

### Possible-Intent Counterpoint (addressed)

**Counterpoint:** artifacts are considered absorbed into the spec body after creation; post-revision they describe a superseded spec version, so deletion prevents stale-content confusion and backfill regenerates fresh ones at the next plan gate.

**Why it does not hold as written:**

1. If absorption were the convention, the spec text must stop citing the artifacts. It does not — #2327's spec cites `decompose-output.yaml` in its Dependencies table, lists all 12 files in Documentation Sources, and uses the artifacts directory as an SC-7 verification surface. Both conventions cannot simultaneously hold.
2. validate.md item 3.6 runs against the *current* spec and *existing* artifact files. Deleting them converts mandated alignment checks into no-op warnings, weakening the exact gate the pipeline imposes on every subsequent validation.
3. Deletion is committed to the pushed `issues-data` branch — the branch remote readers reach through the exec-summary blockquote link. A reader following the citation hits deleted paths; recovery required a manual restoration commit (`cb0ea88b`). This is silent breakage of the durable-anchor class the deck elsewhere treats as citable.

## Scope

- Reconcile `revise.md` Step 7 delete-all vs `validate.md` entry criterion + item 3.6 existence/alignment gates into ONE non-contradictory artifact-lifecycle model
- Define what a revision commits to the pushed `issues-data` branch so currently-cited artifact paths are never deleted downstream
- Provide a migration path for existing specs that cite artifacts (notably #2327)
- Add behavioral enforcement test coverage asserting no destructive artifact deletion during revise

**Out of scope:**
- Implementing #2327's durable-anchor persistence design itself (that issue owns it)
- #2330's sc-summary.yaml sibling-drift sweep proposal (separate, adjacent issue)
- Changes to backfill/artifact generation content or the 7 analytical artifact schemas

## Approach

Resolve the lifecycle contract explicitly in the spec phase — pick one coherent model and make both cards conform:

- **Keep-and-regenerate:** Step 7 stops deleting cited artifacts; revision marks them superseded (or regenerates via backfill inline), preserving validate.md 3.6 alignment checks and citation durability; or
- **Absorb-and-decite:** artifacts remain ephemeral, but validate.md must drop existence/alignment gates against them and specs must be forbidden from citing them (aligning with #2327's durable-anchor classes) — including a migration for existing citing specs like #2327 itself.

Additionally: whichever model wins must define what gets committed to the pushed `issues-data` branch, so revision never again pushes deletions of currently-cited evidence.

## Impact

**Top risks:**

1. Wrong model choice breaks the plan-gate backfill flow (artifacts feed writing-plans readiness gates) — mitigation: dry-run revise + validate on a scratch issue (SC-2) before rollout.
2. Historical pushed deletions leave permanently broken citations on `issues-data` for past revisions — mitigation: one-time audit/restoration sweep across affected issues (manual pattern already proven in restoration commit `cb0ea88b`).
3. Behavioral enforcement test depends on live model runs — mitigation: scope-limited behavioral test via the `with-test-home` harness per tests-v2 discipline.

**Dependencies:** #2327 (durable-anchor classes, open), #2330 (adjacent sweeping proposal, open), #2167 (closed — originated the Step 7 delete instruction).

**Call to action:** developer review needed to select the lifecycle model direction (keep-and-regenerate vs absorb-and-decite) before spec phase begins.

## Success Criteria

| ID | Criterion | Verification sketch |
|----|-----------|---------------------|
| SC-1 | revise.md and validate.md state one non-contradictory artifact-lifecycle model | Read both cards; no instruction ordering delete-all while another requires existence+alignment |
| SC-2 | Post-revision state satisfies validate.md entry + item 3.6 without manual restoration | Dry-run revise on a scratch issue; run validate; no missing-artifact warnings attributable to revision |
| SC-3 | Spec bodies' artifact citations survive revision (no pushed deletions of cited paths) | `git -C .opencode/.issues log --diff-filter=D -- '*{N}/artifacts/*'` empty for revisions performed under the fixed cards |
| SC-4 | Behavioral enforcement test asserts the agent does not execute rm -rf on cited artifacts during revise | opencode run via with-test-home; stderr trace shows no destructive artifact deletion |

## Related Issues

- #2167 (closed) — "[SPEC] Stale analytical artifacts after spec revision — auto-delete and backfill": ORIGIN of Step 7 (its SC-3 added the delete step). Solved staleness-by-confusion; did not consider citation integrity or validate.md's dependence on the files.
- #2330 (open) — "[BUG] spec-creation revise task omits sibling artifact drift sweep (sc-summary.yaml staleness)": treats Step 7's wholesale deletion as intended behavior and asks for MORE sweeping. This report instead challenges the deletion-vs-validation/citation contradiction itself. Different fix surface.
- #2327 (open) — the victim issue; proposes the durable-anchor rule but does not cover the revise/validate contradiction inside the spec-creation cards.

Dedup checked against michael-conrad/.opencode open+closed ("stale artifacts", "artifacts deleted", "revise step 7", "artifact lifecycle", "analytical artifacts"): no EXACT-DUPLICATE or NEAR-DUPLICATE; candidates above are RELATED-BUT-DISTINCT.

---

🤖 OpenCode (opencode/x-preview-f-free) ✅ created

## Validation Evidence Artifacts (pre-creation card, MANDATORY format)

```
Check: Title dedup gate for "[BUG] spec-creation self-contradiction..."
Tool: gh search issues --repo michael-conrad/.opencode <terms> --state open/closed (terms: stale artifacts, artifacts deleted, revise step 7, artifact lifecycle, analytical artifacts)
Result: 5 candidate families found (#2330 open, #2167 closed, #2327 open, #1645/#795/#1061/#1176 tangential, #2225/#2155/#1903/#1885/#2251 closed)
Classification: RELATED-BUT-DISTINCT (no EXACT/NEAR duplicate)
Action: proceed
```

```
Check: Overlap analysis vs #2330, #2167, #2327
Tool: gh issue view (bodies read in full for all three)
Result: #2167 originated Step 7 (closed, implemented); #2330 extends sweeping to sc-summary.yaml treating deletion as intended; #2327 defines durable-anchor citation rule but excludes spec-creation pipeline restructuring (its own Out-of-scope list)
Classification: INDEPENDENT scope on the revise/validate contradiction; PARTIAL-OVERLAP on topic keywords only
Action: proceed (cross-referenced in Related Issues)
```

```
Check: Staleness / live verification of claimed defects
Tool: editor find_text on revise.md + validate.md; git -C .opencode/.issues log --diff-filter=D --name-only 19833392..HEAD
Result: Step 7 text verbatim confirmed (revise.md line 55 re-verified at creation time); conflicting validate.md entry (line ~16) + item 3.6 (line ~81) confirmed; deletion commits ca8224ae (2319), c68a29b1 (2322+2324), a2b68f6b (2327×12 files) confirmed in range; restoration cb0ea88b confirmed
Classification: none (all claims verified live)
Action: proceed
```

```
Check: Genuinely-untracked status
Tool: dedup searches above + supplementary local worktree scan (git grep "artifact" over .opencode/.issues HEAD) — only already-classified candidates surfaced
Result: No open or closed issue addresses the revise-Step-7 vs validate-item-3.6 contradiction or the pushed-branch citation-breakage pattern
Classification: genuinely-untracked = YES
Action: proceed
```

### Creation Provenance

- Created via gh CLI v2.45.0 direct API fallback (task() dispatch and github_issue_write MCP unavailable in sub-agent context); reason logged as remote comment.
- Title prefix deviation note: card Step 1 table lists [SPEC]/[SPEC-FIX]/[SPEC-ENHANCEMENT]/[Task:]; [BUG] retained as validated by pre-creation and consistent with sibling bug-report issues (#2330).
