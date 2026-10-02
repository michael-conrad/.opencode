> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2489/

## Intent and Executive Summary

1. **Problem Statement:** Submodule pointer discipline regressed across the enforcement chain: the pre-commit hook Gate 2 (stale pointer check) enforces a pre-work-only invariant at commit time where it is legitimately false, the tag canon moved without repointing 15 dead references (6 to git-workflow/SKILL.md §Tag Convention, 7 to nonexistent AGENTS.md sections, 2 in pre-work.md), and 3 tag-format sites still document the unsuffixed `<parent-repo>/<issue-number>` form.

2. **Root Cause / Motivation:** Enforcement authority for submodule pointers drifted from the pre-commit stage to the PR/release stage (enforcement-gate Steps 0/0.5/0.75 per #2313/#2431, plus the release pointer check), and the documentation canon followed that authority without repointing its dependents. It must be solved now because one dead reference sits in Tier-1 always-loaded `000-critical-rules.md`, so every session loads a Read-link that resolves to nothing, and the commit-time gate habituates agents to `SKIP_STALE_POINTER_CHECK=1` while carrying a known false-positive bug (#2258).

3. **Approach Chosen:** Remove pre-commit hook Gate 2 entirely (gate + SKIP hatch) so the stacked-PR model is enforced where it is actually true (PR creation); consolidate all tag rules into the single canonical section `operating-protocol.md` "Tag Convention (Canonical)"; repoint every dead Read-link to its live target in inline Read-link form; correct the three unsuffixed format sites; add a standing reference-integrity enforcement check so future canon moves cannot silently strand references; retire the five dependent tests and record a ceremony-test retirement policy.

4. **Alternatives Considered & Why Discarded:** (a) Keep Gate 2 and fix its SHA-extraction false positive (#2258's approach) — discarded: the fix repairs a gate whose enforcement target is legitimately false mid-development; the gate's whole premise is wrong, and #2431/#2313 already own pointer freshness at PR time. (b) Keep the SKILL.md §Tag Convention section as a second canon copy — discarded: two canonical homes is what caused the drift; the 5-way skill split moved the section and partial duplicates rotted.

5. **Key Design Decisions:** (a) Full deletion of Gate 2 rather than disable-by-default — tradeoff: commit-time stale-pointer defense is lost, accepted because PR-time gates are the sole authoritative freshness site and their tests are kept. (b) Single canonical tag section in `operating-protocol.md` — tradeoff: agents must Read-link to it instead of finding the rules inline in each skill, accepted for single-source-of-truth. (c) Repaired references keep the inline `Read [Text](path)` form — grounded in the cross-reference-form-comparison research card (inline form has the highest access rate). (d) Ceremony-test policy (user directive 2026-10-02) — tradeoff: fewer assertions overall, accepted because every retained test must catch a real defect.

6. **User Intent / Original Prompt:** "Holistic submodule pointer discipline: remove pre-commit stale-pointer gate, consolidate tag canon, repair dead references" (.opencode#2477 root request, dispatched as spec-creation create for the pointer-discipline-fix analysis artifacts; brainstorm finalized 2026-10-02 with user confirmation "yes, proceed" and "full deletion").

## Not Included

- **hooks/pre-push Gate 2 (submodule-only push blocker)** — different concern; the submodule-only push gate stays per the pre-push hook mandate.
- **pr-creation enforcement-gate Steps 0/0.5/0.75 content changes** — these are the PR-time freshness authority (#2313/#2431); their tests remain unmodified.
- **create-pr.md release pointer check** — release-path gate untouched.
- **trunk-tip-verification.md 7-step pre-work gate** — pre-work-time invariant owner untouched.
- **session-enforcement.ts installer changes** — no pointer gate exists in the installer; removal propagates through it on next session start (verification only).
- **#2258 awk-substr false-positive fix** — the fix target (Gate 2 code) is deleted by this spec; #2258 is superseded instead.
- **Migration of the historical malformed tag `opencode-config/1059-.opencode`** — out of scope; it is evidence of raw-basename ambiguity, not a migration target.
- **Modification of existing 191 suffixed tags or any tag migration** — no migration; existing tags remain valid.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The pre-commit hook contains no Gate 2 stale-pointer check (no `SKIP_STALE_POINTER_CHECK` env hatch, no stale-pointer loop, no Gate 2 BLOCK message); a behavioral run commits a submodule pointer at an unmerged feature-branch SHA in a feature branch without the hatch and the commit succeeds with no hook block, while a trunk-branch commit is still blocked (Gate 1 contract unchanged). | behavioral | Behavioral test run via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` with hook-exit inspection; grep for absence of `SKIP_STALE_POINTER_CHECK` in the hook |
| SC-2 | The five dependent gate tests (test-2264-sc3-different-trunk-submodule.sh, test-2264-sc4-shared-trunk-submodule.sh, test-2264-sc6-two-submodule-verification.sh, test-2264-sc7-bug-only-override-uses.sh, behaviors/2219-sc16-stale-pointer-block.sh) no longer exist and the tests-v2 directory lists no orphaned runners referencing them. | structural | File-existence check (`ls`) + tests-v2 index scan |
| SC-3 | `git-workflow-branch/tasks/pre-commit-pointer-check.md` advisory text contains no stale-pointer-gate or SKIP-hatch wording and references the PR-time freshness gates (enforcement-gate Steps 0/0.5/0.75). | string | grep of the advisory file |
| SC-4 | All tag rules are present in `operating-protocol.md` "Tag Convention (Canonical)" and zero references to `git-workflow/SKILL.md` §Tag Convention, zero references to nonexistent AGENTS.md sections (§Tag Layers, §Tag-Based Hash Permanence, §Idempotent Tag-if-Untagged, §Skipping Git Pre-Check, enforcement/halt-conditions.md) remain; each repaired link uses inline `Read [Text](path)` form. | string | grep for dead-target patterns + reference-integrity check run on the repaired repo |
| SC-5 | The three tag-format sites (pre-work.md Step 3 tag creation, pre-work.md Step 4 commit message, provenance/trunk-push-provenance.md) use the suffixed `<parent-repo>/<issue-number>-<submodule>` form with no unsuffixed variant remaining. | string | grep of the three sites for the unsuffixed pattern |
| SC-6 | A reference-integrity enforcement check exists in `.opencode/tools/` that, executed against the live repository, fails on a deliberately introduced broken Read-link (points at a section absent from the target file) and passes on the repaired repository. | behavioral | Test execution: run the check against a deliberate broken probe and against the repaired repo; inspect exit codes and report lines |
| SC-7 | The ceremony-test retirement policy is recorded in the retire path (test card header / tests-v2 AGENTS note): a test survives only if a real defect would escape without it, and every new test SC MUST justify its verification cost against the defect it catches. | string | Policy audit: read the recorded policy text and confirm both clauses are present |
| SC-8 | Issue #2431 carries a comment recording the commit-time semantics handover (SKIP hatch removed; PR-time scope untouched) and issue #2258 carries a superseded-with-rationale annotation. | semantic | API read of both issue threads; clean-room sub-agent evaluates the annotations against the handover/supersession criteria |

### Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Requirements

1. R-1. The pre-commit hook SHALL NOT contain the Gate 2 stale-pointer check, its `SKIP_STALE_POINTER_CHECK` environment hatch, or its Gate 2 BLOCK message; Gate 1 trunk-branch protection SHALL remain unchanged (exit 1 on trunk commit, exit 0 otherwise).
2. R-2. The five tests whose assertions target the removed Gate 2 behavior (test-2264-sc3, sc4, sc6, sc7, and behaviors/2219-sc16) SHALL be deleted, and no orphaned runners referencing them SHALL remain in the tests-v2 directory.
3. R-3. The `pre-commit-pointer-check.md` advisory text SHALL reference the PR-time freshness gates and SHALL NOT reference the removed hook stale-pointer gate or SKIP hatch.
4. R-4. The single canonical home for all tag rules SHALL be `operating-protocol.md` "Tag Convention (Canonical)"; every tag rule currently duplicated or stranded elsewhere SHALL be consolidated there.
5. R-5. Every dead reference to `git-workflow/SKILL.md` §Tag Convention, to nonexistent AGENTS.md sections (§Tag Layers, §Tag-Based Hash Permanence, §Idempotent Tag-if-Untagged, §Skipping Git Pre-Check, enforcement/halt-conditions.md), and to the dead SKILL.md Tag Convention target in the git-workflow-cleanup path SHALL be repointed to the correct live target in inline `Read [Text](path)` form.
6. R-6. The three tag-format sites (pre-work.md Step 3, pre-work.md Step 4 commit message, trunk-push-provenance.md) SHALL use the suffixed `<parent-repo>/<issue-number>-<submodule>` form per the #950 canonical rule.
7. R-7. A standing reference-integrity enforcement check SHALL exist in `.opencode/tools/` that validates agent-facing Read-links resolve to sections contained in their target files.
8. R-8. The commit-time semantics handover SHALL be recorded on issue #2431 and the supersession (with rationale) SHALL be recorded on issue #2258; #2313 SHALL be left unaffected.
9. R-9. The ceremony-test retirement policy SHALL be recorded: a test survives only if a real defect would escape without it, and every new test SC SHALL justify its verification cost against the defect it catches (no string-grep documentation-phrasing checks).
10. R-10. Gate 2 removal evidence SHALL be behavioral (the removal changes runtime behavior and auto-uplifts per critical-rules-BEH-EV); no structural or string substitute MAY be reported as PASS for SC-1.

## Items

### Item 1 (SC-1): Remove Gate 2 + SKIP hatch from pre-commit hook

- RED: Behavioral test commits a submodule pointer at an unmerged feature-branch SHA in a feature branch without setting the hatch — the current hook blocks (RED); after the change the commit succeeds with no hook block, and a trunk-branch commit is still blocked (Gate 1 contract preserved).
- GREEN: Delete the hook lines implementing Gate 2 — the `SKIP_STALE_POINTER_CHECK` env hatch, the stale-pointer loop with SHA extraction, and the Gate 2 BLOCK message.
- verify: Behavioral run + grep for absence of `SKIP_STALE_POINTER_CHECK` and stale-pointer remnants in the hook.
- commit: One commit containing the hook edit and its behavioral test.

### Item 2 (SC-2): Retire dependent gate tests (including performative ones)

- RED: File-existence check — the five test files exist before deletion (RED for the retirement state); after deletion they are gone and the tests-v2 index lists no orphaned runners.
- GREEN: Delete test-2264-sc3-different-trunk-submodule.sh, test-2264-sc4-shared-trunk-submodule.sh, test-2264-sc6-two-submodule-verification.sh, test-2264-sc7-bug-only-override-uses.sh, and behaviors/2219-sc16-stale-pointer-block.sh.
- verify: File-existence check + tests-v2 index scan.
- commit: One commit.

### Item 3 (SC-3): Update pre-commit-pointer-check.md advisory text

- RED: grep of the advisory file for stale-pointer-gate / SKIP-hatch wording returns matches before the edit.
- GREEN: Rewrite the advisory text to reference the PR-time freshness gates.
- verify: grep returns zero stale-pointer/hatch matches; referenced target section exists.
- commit: One commit.

### Item 4 (SC-4): Consolidate tag rules into canonical home and repoint dead references

- RED: grep finds the 6 dead refs to git-workflow/SKILL.md §Tag Convention, the 7 refs to nonexistent AGENTS.md sections, and the 2 dead refs in pre-work.md — all targeting absent content.
- GREEN: Confirm `operating-protocol.md` "Tag Convention (Canonical)" holds the complete tag rules; repoint all 15 dead references to it or their correct live targets, each in inline `Read [Text](path)` form.
- verify: grep for dead-target patterns returns zero; the new reference-integrity check passes on the repaired repo.
- commit: One commit.

### Item 5 (SC-5): Correct 3 unsuffixed tag-format sites

- RED: grep of the three sites for the unsuffixed `<parent-repo>/<issue-number>` pattern returns matches.
- GREEN: Append the `-<submodule>` suffix in pre-work.md Step 3, pre-work.md Step 4 commit message, and trunk-push-provenance.md per the canonical rule.
- verify: grep for the unsuffixed pattern returns zero at all three sites.
- commit: One commit.

### Item 6 (SC-6): Standing reference-integrity enforcement check

- RED: The check, run on the current (unrepaired) repository, reports failure on the known-broken references.
- GREEN: Implement the check in `.opencode/tools/` validating that agent-facing Read-links resolve to sections contained in the target files; wire it into the enforcement workflow note.
- verify: Run the check against a deliberately introduced broken Read-link (must fail) and against the repaired repo (must pass).
- commit: One commit.

### Item 7 (SC-7): Ceremony-test policy for the subsystem

- RED: The policy text is absent from the retire path before the edit.
- GREEN: Record the performative-test retirement policy (survival = a real defect would escape without it; new test SCs must justify cost vs catch; no documentation-phrasing string checks) in the test card header / tests-v2 AGENTS note.
- verify: Policy audit — read the recorded text and confirm both clauses.
- commit: One commit.

### Item 8 (SC-8): Issue-graph coordination (#2431 handover note, #2258 supersession)

- RED: No handover or supersession annotations exist on the #2431 / #2258 threads.
- GREEN: Post non-substantive coordination comments — #2431: commit-time semantics hand-over (SKIP hatch removed; PR-time scope untouched); #2258: superseded with rationale (fix target deleted); confirm both branch states.
- verify: API read of both threads showing the annotations.
- commit: No code commit (API-only evidence).

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| .opencode#2431 | Stacked-PR ordering gate owns PR-time freshness; its "SKIP semantics unchanged" no-ripple assumption is invalidated by SC-1 — handover comment required (SC-8) | open |
| .opencode#2313 | Merged-commit reachability gate (enforcement-gate Step 0) is the PR-time authority — unaffected, must stay green | open |
| .opencode#950 | Tag format canon (suffixed `<parent>/<issue>-<submodule>` rule) — SC-5 implements its already-canonical rule | satisfied |
| .opencode#2258 | Superseded by this spec (its fix target, Gate 2, is deleted) — supersession annotation required (SC-8) | open |
| cross-reference-form-comparison research card (`.opencode/.issues/research-cards/`) | Governs the repair form: inline `Read [Text](path)` — highest access rate | satisfied |
| session-enforcement.ts hook installer | Propagates hook removal to installed `.git/hooks/` copies on next session start — verify overwrite behavior during verification | satisfied |

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-4 | Item 4 |
| R-6 | SC-5 | Item 5 |
| R-7 | SC-6 | Item 6 |
| R-8 | SC-8 | Item 8 |
| R-9 | SC-7 | Item 7 |
| R-10 | SC-1 | Item 1 |

Dependency ordering (DAG): SC-6 → SC-4 → SC-5; SC-1 → SC-2, SC-3, SC-8; SC-2 → SC-7. Acyclic; no cycles.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| pre-commit hook Gate 2 / SKIP hatch | code | `.opencode/hooks/pre-commit` | grep verified: SKIP at lines 34-35, BLOCK at 60-68 |
| Canonical tag section | code | `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md` "Tag Convention (Canonical)" | read verified (section present) |
| Dead references inventory | code | `.opencode/commands/submodule-tag-prework.md`, `.opencode/guidelines/000-critical-rules.md`, provenance/trunk-push-provenance.md, submodule-sync.md, branch-cleanup.md, pre-work.md | grep verified per blast-radius artifact |
| Tag format canon (#950) | issue | https://github.com/michael-conrad/.opencode/issues/950 | read (issue thread) |
| PR-time freshness authority | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` Steps 0/0.5/0.75 | read verified (unmodified in this spec) |
| Research card | research | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read verified |
| Dependent tests | code | `.opencode/tests-v2/test-2264-sc{3,4,6,7}-*.sh`, `.opencode/tests-v2/behaviors/2219-sc16-stale-pointer-block.sh` | file listing verified |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral commit test costs minutes of execution time — the defect (a gate that blocks every legal mid-development commit) is caught at the earliest gate, fix cost zero downstream. Skipping costs the full rework cycle every time an agent hits the block mid-development — habituated SKIP bypasses, wrong-action remediation messages, and a shipped false-positive all compound per stacked-PR commit.
- SC-2: Running the file-existence and index scan costs seconds — orphaned runners are surfaced before they poison the next test run. Skipping costs a failing test suite that asserts deleted behavior, discovered only when the suite next runs against the removed gate.
- SC-3: Verifying the advisory grep costs seconds — a wrong advisory is caught before any agent follows it. Skipping costs hours-to-days of agents acting on an advisory that instructs interacting with a gate that no longer exists.
- SC-4: Running the reference-integrity check costs seconds-to-minutes — dead Read-links are caught before the next session loads them. Skipping costs every agent session (including Tier-1 always-loaded 000-critical-rules.md) resolving a dead link at the tag-decision point — days-to-weeks of silently wrong tag decisions.
- SC-5: Verifying the format grep costs seconds — format rot is caught before the next tag is created unsuffixed. Skipping costs the next pre-work tag being created in a format that matches zero of 191 existing tags, discovered at tag lookup time.
- SC-6: Building and running the integrity check costs minutes of execution time — the recurrence guard is in place the same change. Skipping costs the entire defect class recurring: the next canon move silently strands its dependents again, and the dead-link backlog regrows at 1000× the check's cost.
- SC-7: Recording and auditing the policy costs one read — ceremony tests are prevented from re-accumulating. Skipping costs every future change in this subsystem re-accumulating performative tests that slow development and burn tokens with no defect-catching value — exactly the failure the user directive targeted.
- SC-8: Reading the two threads costs one API read each — cross-issue coordination is verified before the branches collide. Skipping costs a mid-flight conflict between this spec and #2431's assumptions, discovered at PR-creation time when both gates run against contradictory semantics.

## Edge Cases

- **Condition:** Installed `.git/hooks/pre-commit` copies still carry old Gate 2 after the source hook is edited.
  **Expected behavior:** session-enforcement.ts re-installs hooks at session start, overwriting stale copies.
  **Resolution:** Verify installer overwrite behavior during Item 1 verification; report any install gap as a finding, do not hand-edit installed copies.
- **Condition:** An agent sets `SKIP_STALE_POINTER_CHECK=1` after removal.
  **Expected behavior:** The env var has no consumer and no effect; commits proceed identically.
  **Resolution:** No action — the variable is dead by design (interface-compatibility artifact).
- **Condition:** A trunk-branch commit with any submodule pointer state.
  **Expected behavior:** Gate 1 still blocks (exit 1) — trunk branch protection is unchanged.
  **Resolution:** Covered by SC-1 behavioral verification (trunk-branch block assertion).
- **Condition:** A PR is created with a genuinely stale submodule pointer (parent not containing the submodule commit).
  **Expected behavior:** enforcement-gate Steps 0/0.5/0.75 still block the PR — freshness authority is intact.
  **Resolution:** Covered by the kept test-2431-*/test-2434-* suites (unmodified).
- **Condition:** The reference-integrity check encounters a target file that exists but lacks the referenced section heading.
  **Expected behavior:** The check reports the link as broken with file path and missing-section name.
  **Resolution:** The agent repairs the link or the section per SC-4/SC-6 procedure.
- **Condition:** #2258 or #2431 work is mid-flight on a feature branch when the supersession/handover lands.
  **Expected behavior:** Coordination comments record the state change; branch states are confirmed before annotation.
  **Resolution:** SC-8 verification includes confirming branch states of both issues.
- **Condition:** The reference-integrity check itself runs on a repo with deliberately malformed input (empty file, no headings).
  **Expected behavior:** The check fails closed (reports broken) rather than passing vacuously.
  **Resolution:** Covered by SC-6 behavioral verification with the deliberate broken probe.
