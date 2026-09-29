# Plan Input Verification Ledger — Issue #2471

Verified ONCE at plan-creation start; all downstream plan steps read THIS ledger, not the sources.

## Issue State + Labels

- Source: `.opencode/.issues/2471/issue.yaml` (read 2026-09-29)
- title: `[BUG] spec-creation/issue-operations body template stamps Approval Tracking comment-tracker note into every spec issue body — approval mechanism must not appear in spec bodies at all`
- status: open
- labels: `approved-for-pr`
- authorization_scope: `for_pr` (from `approved-for-pr` label); pr_strategy: `stacked`

## Spec Success Criteria (with evidence types)

The spec's Expected behavior defines one derivable SC (structure artifact confirms `sc_count: 1`):

- **SC1** — Spec issue bodies contain no approval-mechanism language; the deck normatively states the no-indicator rule (footer allowlist: Spec Reference Blockquote, Problem, body sections, Impact, byline footer only) in all three body-assembly task cards:
  - `.opencode/skills/spec-creation/tasks/create.md`
  - `.opencode/skills/issue-operations-core/tasks/creation.md`
  - `.opencode/skills/issue-operations/platforms/local/tasks/creation.md`
  - Evidence type: `string` (per structure.yaml item SC1-body-template)

## Structure Artifact Mappings

- Single phase: `phase-1` — "task-card footer allowlist rule", covers [SC1]
- Phase DAG: zero edges (`dependency_dag.edges: []`)
- SC→phase colocation: SC1 red/green/commit all in phase-1; `verified: true`
- Cross-phase dependencies: no violations; `verified: true`
- skill_selection: red → test-driven-development; green → test-driven-development; verify → verification-before-completion; commit → (orchestrator) commit-inline

## Per-Task Cycle Steps (from implementation-workflow reference card, read 2026-09-29)

Pre-implementation: `pre-regression` (test-driven-development), `pre-regression-verify` (verification-before-completion).
Per-item: `red` (test-driven-development) → `green` (test-driven-development) → `post-regression` (test-driven-development) → `verify` (verification-before-completion) → `commit-inline` (orchestrator, direct).
Post-implementation: `audit`, `z3-check` (orchestrator direct), `structural-checks` (finishing-a-development-branch), `pre-pr-gate` (verification-before-completion), `regression-check` (test-driven-development), `review-prep` (git-workflow-pr), `create-pr` (git-workflow-pr), `exec-summary` (completion-core).

## CLI Surface Flags Needed

- `.opencode/tools/local-issues update <repo>#<N> --labels <comma-list>` — label writes REPLACE the entire labels array; every write must include all existing labels plus new ones. Here: `update .opencode#2471 --labels approved-for-pr,spec-cleared`.

## Notes

- Repairs to already-created specs (#36/#1385) are out of scope — already applied by orchestrator 2026-09-29.
- The audit evidence mirror at `tmp/issue-36/spec-mirror/spec-36.md` retains the historical line intentionally — not touched.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
