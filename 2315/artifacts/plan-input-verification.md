# Plan-Input Verification Ledger — issue #2315

Written once by writing-plans/tasks/create (2026-09-30T03:00:17Z). Per task-card step 3a:
subsequent steps re-read THIS ledger, not the sources. Re-verifying settled inputs is
prohibited.

## Issue state

- Repo: michael-conrad/.opencode (remote issue 2315), platform github.com
- Local issue directory: .opencode/.issues/2315/
- Local issue.yaml labels (PRIMARY CANONICAL): [approved-for-pr, spec-cleared]
- `spec-cleared` is ALREADY present in the local labels array (verified 2026-09-30 by read
  of issue.yaml) — the task-card step-9 primary write is already satisfied; re-write is a
  no-op and not required. Remote `spec-cleared` already applied upstream. No label write
  will be performed (a replace-array write risks label loss).
- Comments: empty (comments.md contains only `---` separator; `local-issues read
  --number .opencode#2315 --type comments` returned an empty comment list)
- Prior plan state: plan.md + plan-01-configuration-registration.md +
  plan-02-documentation-work.md exist (2026-09-24), lifecycle-complete through
  `plan_created` 2026-09-24T13:35:19Z; plan approvals were REVOKED (2026-09-24T05:30:02Z)
  by the second-round spec revision, then the plan was regenerated (13:11:03Z) and
  remediated (13:28:11Z) against the REVISED SC set — validate-findings.yaml
  overall_status: PASS (2026-09-24T13:34:31Z). The context note designates plan.md as the
  artifact target: this task REGENERATES plan.md (and phase files) in place, preserving
  the full lifecycle-events table.

## SC list with evidence types (spec §4, authoritative)

| SC | Evidence type | Verify method (condensed) |
|----|--------------|---------------------------|
| SC-1 | behavioral | opencode launch; ragsync spawns + lists tools; JSONC valid, enabled |
| SC-2 | behavioral | network-monitored fastembed retrieval; no external embedding API |
| SC-3 | behavioral | cross-source search; no namespace leakage; §3.1 sections + namespaces |
| SC-4 | structural | checklist in .opencode tree; topics: 1 config section/§3.1 source, isolated namespaces, empty-source handling |
| SC-5 | behavioral | source-file modify + index-freshness observation; auto-sync per source |
| SC-6 | structural | docs file topics: service config, per-source §3.1 layout, usage, offline/cache path, validation |
| SC-7 | behavioral | runtime indexed-source enumeration; main repo + registered submodules covered; .issues/ worktrees excluded absent carveout |
| SC-8 | structural | §3.2 zero-match sweep; spot-check capability-only wording + fallback rows |
| SC-9 | behavioral | isolated opencode run; srclight-free tool selection; zero srclight_* calls |

Evidence distribution: 6 behavioral, 3 structural. SC-9 is the behavioral-variant item
(commit+push gate before its verify run; GREEN delivered by Item 8).

## Structure artifact mappings (artifacts/structure.yaml)

- phase_1 "RAGSync configuration and registration": SC-1, SC-2, SC-3, SC-4, SC-5, SC-7;
  item sequence item-01, 02, 03, 04, 05, 07
- phase_2 "Documentation and deck srclight purge": SC-6, SC-8, SC-9; item sequence
  item-06, 08, 09
- DAG: single edge phase_1 → phase_2 (z3.Implies(phase_2, phase_1)); solve re-verified
  2026-09-29: solve_model SAT, solve_check SAT, planner SOLVED_SATISFICING
  (run_p1 → run_p2)
- intra_phase_1: items in spec order on shared .opencode/ragsync-config.yaml
- intra_phase_2: SC-9 RED behavioral run PRE-purge (before Item 8 GREEN); SC-9 verify run
  only after Item 8 COMMIT+PUSH + fresh fetch remote-ref containment

## Skill+task dispatch strings (implementation-workflow reference card, verbatim)

- pre-regression: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- pre-regression-verify: `task(..., prompt: "execute verify task from verification-before-completion")`
- red: `task(..., prompt: "execute red task from test-driven-development")`
- green: `task(..., prompt: "execute green task from test-driven-development")`
- post-regression: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- verify: `task(..., prompt: "execute verify task from verification-before-completion")`
- commit-inline: orchestrator git add + commit (direct)
- audit: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` → validator → evaluator → arbiter
- z3-check: orchestrator `.opencode/tools/solve check --state-path ... --contract-path ...` (direct)
- structural-checks: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
- pre-pr-gate: `task(..., prompt: "execute verify task from verification-before-completion")`
- regression-check: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- review-prep: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- create-pr: `task(..., prompt: "execute create task from git-workflow-pr")`
- exec-summary: `task(..., prompt: "execute completion task from completion-core")`

## CLI surface flags needed

- `./.opencode/tools/local-issues update --number .opencode#2315 --labels <csv>` —
  replaces entire labels array (composition convention 11)
- Label decision: `spec-cleared` + `approved-for-pr` already both present; NO write needed
  (avoid risk of clobbering with a partial array). Exit-criteria step 9 is recorded as
  satisfied-by-verified-state. Re-verified at end of task: issue.yaml labels array reads
  [approved-for-pr, spec-cleared] — `spec-cleared` PRESENT (canonical local record
  satisfied; no write performed because `local-issues update --labels` replaces the whole
  array and both labels are already correct).

## Pinned composition conventions (plan-structure-standards.md §Composition Conventions)

- Frontmatter order: plan_schema_version, issue, title, authorization_scope, pr_strategy,
  phase_count, dispatch
- Phase-table columns: Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch
- Continuous step numbering 1..N; phase-table Step Range cell records slice
- Dispatch column summary style: `direct (a-b) + task-card (c-d)`
- No runtime timestamps in plan body; lifecycle event supplied by dispatch context
- Issue line: `- **Issue:** {issues_prefix}/2315/spec.md` — platform is github (remote
  exists); prior plan used the remote URL form; composition convention 6 pins the local
  relative form for local platform. The spec frontmatter records remote_issue 2315 with a
  github remote_url; the canonical issues store is LOCAL (`remote-first reservation
  mandate`; GitHub is a mirrored exec summary only). Plan-fidelity audit history accepted
  the URL line previously; this regeneration uses the pinned form
  `- **Issue:** .opencode/.issues/2315/spec.md` per convention 6.
- Exit criteria labeled C1..Cn; no machine-parseable IDs/JSON-YAML blocks in body;
  fenced code blocks: none (frontmatter sole YAML); phase-file Context blocks are the
  §3.4 free-form context — plan-structure-standards prohibits JSON/YAML code blocks in
  the BODY, so context is expressed as dash sub-bullet lists, not fenced YAML
- Pre-Flight Guard block: verbatim from guidelines/023-pre-flight-guard.md (copied, seen
  against canonical this session)
- Pre-implementation steps: coherence gate + baseline check once per plan
- Post-implementation steps once per plan (structural-checks, pre-pr-gate,
  regression-check, review-prep, create-pr, exec-summary appended after audit + z3-check;
  prior plan-02 omitted structural-checks/pre-pr-gate/regression-check/review-prep/
  create-pr/exec-summary — this regeneration completes the reference-card gate set)
- Pre-Flight Guard section and per-phase cost frames emitted in stage 3; cost-frame
  pattern dark-prose-007: `**Cost frame:** [action cost]. [skipping cost].`

## Regeneration decisions (pinned this session)

1. plan.md (index) + plan-01-configuration-registration.md + plan-02-documentation-work.md
   regenerated in place; lifecycle events table preserved and appended with one new
   `plan_created` event (timestamp: dispatched-context literal `2026-09-30T03:00:17Z`
   unavailable from dispatch context → using session UTC clock value 2026-09-30T03:00:17Z
   emitted by schema-version at ledger time; plan bodies carry no timestamps — the event
   table is metadata, existing rows unchanged).
2. Split-file format (multi-phase MUST split per plan-artifact-format §2).
3. Step numbering continuous 1..N across pre-implementation + both phases +
   post-implementation.
4. SC-9 ordering: RED behavioral run (step after Item 6, before Item 8 GREEN);
   verify behavioral run after Item 8 COMMIT+PUSH+fetch gate.
5. Post-implementation step set (full reference-card set): audit, z3-check,
   structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary.
6. Every step carries explicit `(**direct**)` or `(**task-card**)`.
7. Each item maps to exactly ONE SC (validation rule 16); no multi-SC items; commit-only
   items like Item 9 reference SC-9 only.
8. No fenced code blocks in body; context expressed as checkbox dash sub-bullets.