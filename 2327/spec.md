---
title: '[SPEC] Durable-anchor citation rule: specs must not reference ephemeral artifacts'
remote_issue: 2327
remote_url: https://github.com/michael-conrad/.opencode/issues/2327
promoted_at: '2026-08-26T03:40:32+00:00'
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Full spec and artifacts: [`.opencode/.issues/2327/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2327/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2327/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Durable-Anchor Citation Rule — Specs Must Not Reference Ephemeral Artifacts

## Intent and Executive Summary

| Field | Content |
|-------|---------|
| **Problem Statement** | Agent-facing documents cite filesystem paths as evidence locations that are ephemeral by design — gitignored tmp trees, isolated test homes, lock files — so citations break silently when cleanup runs or directories accrete unmanaged, and no validation mechanism can detect the breakage because standard tooling is blind to gitignored targets. |
| **Root Cause / Motivation** | Three compounding defects: (a) three mutually incompatible documented conventions for behavioral-evidence locations disagree with the one actual harness output shape; (b) audit-cycle evidence chains write to ephemeral tmp stores whose citations die at merge cleanup; (c) retention/cleanup contracts pair classes with mismatched mechanisms — file globs cannot match extensionless directories. This must be solved now because every behavioral test run adds unmanaged accretion and every audit verdict written today becomes unauditable after the next merge cleanup. |
| **Approach Chosen** | Canonicalize the harness directory layout as the single documented behavioral-evidence convention; author a durable-anchor citation rule distinguishing evidentiary claims from procedural writes; steer spec templates toward durable anchors; insert a deterministic reference-classifier gate into the audit cycle using repo-aware queries only; persist durable per-SC verdict records into the issues-data artifact store; wire retention policies for every ephemeral class into the cleanup contract; close the loop by running the classifier against the fix spec itself. |
| **Alternatives Considered & Why Discarded** | Reshape harness output to match documents — discarded: harness layout is ground truth asserted by a passing test; changing it invalidates a passing test. Filesystem-presence validation of cited paths — discarded: tmp trees and issues worktrees are gitignored, making glob/read existence checks blind to cited targets by construction. New standalone guideline file for the citation rule — discarded: the verification-honesty guideline already governs what counts as evidence; extending it keeps a single evidence-honesty home. Retro-deletion of accumulated tmp state — discarded: one-time purge is a plan-phase policy decision; forward policy only. |
| **Key Design Decisions** | Claim-vs-procedure distinction — writing TO ephemeral paths stays fully legal; CITING them as durable evidence becomes prohibited (tradeoff: temp-file workflow freedom retained, unauditable claims forfeited). Single definition site — path-class vocabulary defined once; all consumers reference, never redefine (tradeoff: one authoritative location over local convenience). Verdict records classified as analysis content — satisfies the metadata-only constraint on the issues-data artifact store without amending it (tradeoff: classification discipline over schema whitelist). Merge-gated deletion timing preserved — retention adds owned classes without moving the only authorized deletion point (tradeoff: evidence outlives strict necessity). |
| **User Intent / Original Prompt** | Issue #2327: specs and agent-facing documents cite ephemeral artifact paths that vanish by design, breaking citations; three conflicting documented conventions exist versus actual harness output; the fix makes specs cite only durable anchors. |

## Not Included

- **Retro-deletion of accumulated tmp state** — purging existing behavior-test and behavioral-evidence directories is a plan-phase execution decision; this spec defines forward policy only.
- **Harness output reshaping** — the behaviors helper output layout and test-home isolation mechanics are ground truth; canonicalization adopts them unchanged.
- **Spec-creation pipeline restructuring** — template steering changes content consumed BY the pipeline; pipeline mechanics stay untouched.
- **Parent-repo text edits** — the parent repository holds runtime data (tmp trees, ignore rules); governed, not edited; all rule text lands in the `.opencode` submodule.
- **observe/* discard-mandate changes** — already correctly enforced; listed as precedent never-citable class only.
- **Dangling `spec-auditor` concept reference in the issue-operations-core completion card** — a distinct defect class (dangling concept name); flagged for separate filing, not bundled here.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1a | Exactly one canonical behavioral-evidence output convention — extensionless directories under `{project_root}/tmp/behavioral-evidence-<scenario>-<phase>-<model>/` produced by `behavior_run()` — is documented across all four agent-facing surfaces (the Temp Files & Cleanliness section of the tool-usage guideline; the Evidence Storage section of the VbC collection card; the layout section of the tests-v2 AGENTS guide; the artifact-path row of the finishing checklist), with zero residual conflicting spellings | hybrid — structural for completeness + behavioral for compliance | Automated grep invariant asserting the single pattern across all four surfaces with zero residual conflicting spellings, plus an isolated opencode run whose session.yaml trace asserts an agent citing an evidence location produces the canonical form | `behavior_run()` storage base in `tests-v2/behaviors/helpers.sh`; layout section of `tests-v2/AGENTS.md`; convention-reconciliation entry of the testability-assessment artifact |
| SC-1b | The verification-before-completion working-copy pattern is renamed away from the behavioral-evidence prefix so VbC working copies under `{project_root}/tmp/` can no longer collide with harness-produced behavioral-evidence directories | behavioral | Isolated opencode run via with-test-home; session.yaml trace asserts working copies stage under the renamed prefix and no behavioral-evidence-prefixed path is written outside harness production | Evidence Storage section of `skills/verification-before-completion/tasks/collect.md`; behavioral-evidence exemption rows in the Temp Files & Cleanliness section of `guidelines/060-tool-usage.md` |
| SC-2 | A durable-anchor citation rule exists in the verification-honesty guideline defining citable anchor classes (committed tracked trees in either repo, API-readable GitHub issues, artifacts pushed to the issues-data branch) and never-citable classes (gitignored tmp trees, isolated test homes, lock files, observe/* branches), explicitly permitting procedural writes to ephemeral paths while prohibiting their citation as durable evidence | behavioral | Isolated opencode run via with-test-home; session.yaml trace asserts the agent anchors claims to durable classes and treats ephemeral paths as non-citable for claims while still writing to tmp procedurally | What COUNTS as Evidence section in `guidelines/065-verification-honesty.md`; Cross-Reference Standards section in `guidelines/080-code-standards.md` |
| SC-3 | Spec templates steer evidence-location fields toward durable anchors: steering language referencing the SC-2 class definitions is present in both the template guideline and the examples guideline | behavioral | Grep presence check across the expected sections of both template files, plus behavioral assertion that a spec created from the updated template cites durable anchors in its evidence fields | Content Coverage Checklist and Self-Containment Rules sections in `guidelines/143-planning-spec-templates.md`; `guidelines/144-planning-spec-examples.md` |
| SC-4 | The audit cycle includes a deterministic reference-classifier check that flags planted ephemeral citations, passes planted durable citations, passes legitimate procedural mentions of tmp paths, and resolves validity exclusively through repo-aware queries — per-repo tracked-tree membership, GitHub API reads, pushed issues-data membership — never filesystem presence checks on cited paths | behavioral | Fixture spec carrying planted bad, durable, and procedural citations run through the audit cycle; session.yaml asserts absence of glob/grep-on-cited-path calls and presence of repo-aware query calls | DiMo chain context parameters in `skills/audit/SKILL.md`; tmp and .issues entries in the parent `.gitignore` |
| SC-5 | A verification-before-completion run produces a durable per-SC verdict record under `.issues/{N}/artifacts/` whose entries cite session.yaml by content hash plus scenario/phase/model coordinates, while tmp working copies remain present | behavioral | Live VbC run via the with-test-home wrapper with a timeout of at least 600 seconds and stale-lock pre-clear, inspecting both stores post-run | Evidence Storage section of `skills/verification-before-completion/tasks/collect.md`; metadata-only store constraint in the spec-creation create card |
| SC-6 | The cleanup contract covers every ephemeral class with directory-aware removal gated behind merge confirmation, and no deletion fires during verification or review-prep stages | behavioral | Deterministic shell fixture tree containing every ephemeral class executed through cleanup, plus a timing-ordering negative-case assertion | Step 2.9 deletion procedure of `skills/git-workflow-cleanup/tasks/cleanup.md`; NEVER list of the Temp Files & Cleanliness section in `guidelines/060-tool-usage.md` |
| SC-7 | Executing the SC-4 reference-classifier against this spec returns zero flags; every path cited herein resolves to a durable anchor class | behavioral | Classifier execution against the final spec body with zero-flag output inspection | This spec body; `.opencode/.issues/2327/artifacts/` post-copy contents |

## Requirements

- R-1. Agent-facing documents SHALL document exactly one canonical behavioral-evidence output convention, matching the harness-produced extensionless-directory layout, and SHALL remove all conflicting spellings within the same change set.
- R-2. The verification-honesty guideline SHALL define a durable-anchor citation rule distinguishing evidentiary claims from procedural writes: citing ephemeral paths as durable evidence SHALL be prohibited; writing to ephemeral paths procedurally SHALL remain permitted.
- R-3. Citable and never-citable path-class definitions SHALL have exactly one definition site; every other surface SHALL reference that site through inline Read [Text](path) links rather than restating definitions.
- R-4. Spec templates SHALL steer evidence-location fields toward durable anchor classes by referencing the R-2 rule.
- R-5. The audit cycle SHALL include a deterministic reference-classifier check that resolves cited-path validity exclusively through repo-aware queries and the path-class vocabulary; filesystem presence checks on cited paths SHALL NOT be used.
- R-6. Verification-before-completion SHALL persist per-SC verdict records into `.issues/{N}/artifacts/` classified as analysis content, each entry citing session.yaml by content hash plus scenario/phase/model coordinates; tmp working copies SHALL be retained.
- R-7. The cleanup contract SHALL assign every ephemeral class an owner, a removal mechanism, and a timing; removal SHALL be directory-aware; deletion SHALL remain gated behind PR-merge confirmation.
- R-8. The preservation-until-merge invariant for behavioral evidence SHALL remain intact: PR-merge cleanup stays the only authorized deletion point for preserved evidence.
- R-9. This spec SHALL cite only durable anchors: every referenced path resolves to a committed tracked tree, an API-readable issue, or a pushed issues-data artifact.

## Items

Item numbering follows the dependency DAG recorded in `decompose-output.yaml`: the foundation convention decision precedes every consumer of that spelling; self-application runs last.

### Item 1 (SC-1a): Canonicalize behavioral-evidence path convention across documentation surfaces

- RED: automated grep invariant fails pre-change — conflicting spellings exist across the four documents
- GREEN: exactly one canonical pattern documented in all four documents; zero residual conflicting spellings
- verify: automated grep invariant, the behavioral agent-citation check from the isolated run (session.yaml asserts a citing agent produces the canonical form), and the existing harness-artifact exit-0 test still passing (harness untouched)
- commit: single atomic commit 'canonicalize behavioral-evidence artifact convention'

### Item 2 (SC-1b): Rename VbC working-copy pattern away from the behavioral-evidence prefix

- RED: behavioral — a verification-before-completion run stages working copies under the behavioral-evidence prefix, colliding with the harness evidence namespace
- GREEN: behavioral — working copies stage under the renamed prefix; session.yaml shows no behavioral-evidence-prefixed writes outside harness production
- verify: session.yaml tool-trace assertions from the isolated opencode run
- commit: single atomic commit 'rename VbC working copies out of the behavioral-evidence namespace'

### Item 3 (SC-2): Durable-anchor citation rule text

- RED: behavioral — an agent asked to record verification evidence cites a tmp path unflagged; session.yaml shows no anchor-class reasoning
- GREEN: behavioral — the agent anchors claims to durable classes and treats ephemeral paths as non-citable for claims while still writing to tmp procedurally; rule text uses inline Read [Text](path) links to the canonical definitions
- verify: session.yaml tool-trace assertions from the isolated opencode run
- commit: single atomic commit 'add durable-anchor citation rule'

### Item 4 (SC-3): Spec-template evidence-field steering

- RED: templates contain zero evidence-anchor guidance; a spec produced from them anchors evidence claims nowhere durable
- GREEN: steering language referencing the SC-2 class definitions present in the expected sections of both template files; a spec created from the updated template cites durable anchors
- verify: grep presence checks plus the downstream spec-creation behavioral assertion
- commit: single atomic commit 'steer spec-template evidence fields to durable anchors'

### Item 5 (SC-4): Reference-classifier gate inside the audit cycle

- RED: a fixture spec with a planted bad citation passes audit unflagged; no classifier exists
- GREEN: planted bad citation flagged; planted durable citation passes; legitimate procedural mention passes; session.yaml shows repo-aware queries and absence of filesystem glob/grep on cited paths
- verify: session.yaml tool-call-trace assertions against the fixture matrix
- commit: single atomic commit 'add deterministic reference-classifier gate to audit cycle'

### Item 6 (SC-5): Durable VbC verdict records

- RED: a VbC run leaves no verdict record under `.issues/{N}/artifacts/`; tmp working copies are the only record
- GREEN: post-VbC a verdict record exists under `.issues/{N}/artifacts/` with per-SC entries citing session.yaml by content hash plus scenario/phase/model coordinates; tmp copies still present; the metadata-only constraint honored via the analysis-content classification stated in this spec
- verify: live VbC run via with-test-home with a timeout of at least 600 seconds and stale-lock pre-clear, inspecting both stores
- commit: single atomic commit 'persist durable VbC verdict records'

### Item 7 (SC-6): Retention and cleanup policy wiring

- RED: a fixture tmp tree containing every ephemeral class survives cleanup unchanged
- GREEN: cleanup removes exactly policy-covered classes through directory-aware removal; preserved-evidence deletion stays gated behind merge confirmation; no deletion fires during verification or review-prep stages
- verify: deterministic shell fixtures plus the timing-ordering negative-case assertion
- commit: single atomic commit 'wire ephemeral-class retention policies into cleanup contract'

### Item 8 (SC-7): Fix-spec self-compliance

- RED: the classifier run against the draft spec flags at least one ephemeral citation
- GREEN: the classifier run against the final spec returns zero flags; brainstorm-stage analysis artifacts landed in `.issues/2327/artifacts/` through the create-task copy step, durable by construction
- verify: the SC-4 classifier applied to this spec body — cheapest dogfooding check available
- commit: rides with the final spec revision commit (no separate code change)

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Dependency DAG in `decompose-output.yaml` (`.opencode/.issues/2327/artifacts/`) | Item ordering follows the DAG — the canonical-spelling decision strictly precedes all consumers of that spelling | satisfied — acyclic, verified during analysis |
| Research cards `cross-reference-lobotomization.md` and `cross-reference-form-comparison.md` (pushed issues-data branches) | Incorporated findings mandate inline Read [Text](path) link form for all rule cross-references | satisfied — confidence 0.85 and 0.95, above threshold |
| Existing harness-artifact exit-0 test (`tests-v2/test-sc4-exit0-artifact.sh`) | Constrains the canonical choice to adopt the harness layout; SHALL keep passing after Items 1–2 | satisfied — currently passing |
| local-issues push machinery (`_push_orphan_if_needed` targeting the issues-data branch) | Provides durability of the issues-data artifact store; cited, not changed | satisfied |
| Approval-gate observe/* rules (approval-gate and go-prohibitions guidelines) | Precedent for the never-citable scratch-branch class; unchanged | satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1a | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-2 | Phase 2 |
| R-4 | SC-3 | Phase 2 |
| R-5 | SC-4 | Phase 2 |
| R-6 | SC-5 | Phase 2 |
| R-7 | SC-6 | Phase 2 |
| R-8 | SC-1b, SC-6 | Phases 1–2 |
| R-9 | SC-7 | Phase 3 |

Phase structure: Phase 1 foundation (Items 1–2); Phase 2 surface changes (Items 3–7); Phase 3 self-application (Item 8). SC identifiers here renumber the analysis-phase identifiers into dependency order; the mapping is deterministic from the DAG in `decompose-output.yaml`.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `behavior_run()` storage base in the behaviors helper | code | `.opencode/tests-v2/behaviors/helpers.sh` | read directly during analysis |
| Layout section of the tests-v2 AGENTS guide | doc | `.opencode/tests-v2/AGENTS.md` | grep plus read |
| Temp Files & Cleanliness section of the tool-usage guideline | guideline | `.opencode/guidelines/060-tool-usage.md` | read verbatim |
| Evidence Storage section of the VbC collection card | skill task | `.opencode/skills/verification-before-completion/tasks/collect.md` | read verbatim |
| Artifact-path row of the finishing checklist | skill task | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` | read verbatim |
| DiMo chain context parameters in the audit skill card | skill | `.opencode/skills/audit/SKILL.md` | read plus grep |
| Step 2.9 deletion procedure of the cleanup card | skill task | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | read verbatim |
| Cross-Reference Standards section of the code-standards guideline | guideline | `.opencode/guidelines/080-code-standards.md` | read |
| What COUNTS as Evidence section of the verification-honesty guideline | guideline | `.opencode/guidelines/065-verification-honesty.md` | full read |
| Template guideline and examples guideline | guideline | `.opencode/guidelines/143-planning-spec-templates.md`, `.opencode/guidelines/144-planning-spec-examples.md` | grep confirming zero evidence references |
| Metadata-only store constraint in the spec-creation create card | skill task | `.opencode/skills/spec-creation/tasks/create.md` | read verbatim |
| Parent-repo ignore rules for tmp and issues trees | config | `.gitignore` | read |
| Analysis artifacts for this spec (12 files) | artifacts | `.opencode/.issues/2327/artifacts/` | full read during assembly; copied from staging by this create task |
| Research cards consulted | research | pushed issues-data branches (parent and submodule) | read with confidence scores 0.85 and 0.95 |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a:** Running the single-pattern grep invariant costs seconds. Skipping means four documents keep contradicting each other about where evidence lives, and every cleanup or citation built on a wrong spelling silently no-ops — discovered weeks later when preserved evidence cannot be found post-merge.
- **SC-1b:** The session.yaml trace assertion costs minutes of bounded execution. Skipping means VbC working copies keep colliding with harness evidence directories — cleanup and audit tooling cannot distinguish durable evidence from disposable staging, discovered at the first merge-cleanup pass.
- **SC-2:** The behavioral test costs minutes of model inference. Skipping means agents keep citing paths that die at merge cleanup, and every verification claim anchored to them becomes unauditable — discovered days to months later at the first cross-session audit.
- **SC-3:** The template grep plus downstream behavioral assertion costs minutes. Skipping means new specs anchor evidence nowhere durable, propagating this defect class into every future pipeline run — compounding with each spec created.
- **SC-4:** The fixture-based classifier tests cost minutes. Skipping means ephemeral citations sail through audits unflagged — the death spiral: structural PASS on a behavioral defect ships broken citations into every audited spec, escalating discovery cost by orders of magnitude.
- **SC-5:** The live VbC run costs minutes of bounded execution. Skipping means verdicts exist only in tmp and vanish at merge — audit cross-validation becomes impossible post-cleanup, discovered months later when an auditor needs the record.
- **SC-6:** The shell fixtures cost seconds. Skipping means unowned classes accrete indefinitely and the file-glob mechanism keeps silently matching nothing — storage rot plus false-clean signals discovered weeks to months later.
- **SC-7:** One classifier pass over the spec body costs seconds. Skipping means the fix spec violates its own rule — self-refutation discovered by the first auditor who attempts to resolve its citations.

## Edge Cases

**Input boundaries**

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Empty tmp tree at cleanup time | Directory-aware removal no-ops cleanly on zero matches; policy-table rows for absent classes produce no error | Idempotent removal semantics specified in Item 7 |
| Spec citing zero evidence paths | Classifier returns zero flags — nothing cited, nothing violated | Positive empty-input case included in Item 5 fixture matrix |
| Spec citing hundreds of anchors | Classifier scales linearly without any filesystem calls | Repo-aware query batching per Item 5 mechanism |

**State transitions**

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Issues-data worktree not yet pushed | Durability is conditional; treating an `.issues/{N}/artifacts/` anchor as citable requires verifying push state | Verify-push-state qualifier written into the R-2 rule text; never assume |
| Stale lock file present mid-cleanup | Sweep removes the lock only when no flock holder exists | Holder check precedes removal in Item 7 |

**Failure modes**

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Push skipped for remotes lacking credential helpers | Push machinery skips silently; unpushed worktree membership is a soft gap | Rule text treats push state as verified-when-checked, never assumed |
| Cleanup file-glob silent no-op (pre-existing defect) | Replaced by directory-aware removal in the same change set | Item 7 GREEN covers the replacement mechanism |

**Concurrency**

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Two sessions executing cleanup concurrently | Removal operations idempotent; duplicate removal attempts no-op | Idempotency stated in Item 7 fixtures |
| Concurrent behavioral test runs contending for the lock | Existing flock acquisition semantics preserved unchanged | Harness untouched per Not Included |

**Recovery**

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Stale lock after a killed run | Formalized stale-lock sweep in the cleanup contract replaces manual-only recovery | Item 7 wires the sweep; manual rm remains an interim lever until then |
| Orphaned test homes accumulating | Purge-on-next-run-start or cleanup-task ownership assigned per class; manual clean levers remain | Item 7 retention table assigns the owner |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-26 | Decomposed SC-1 into SC-1a (documentation canonicalization across the four surfaces; hybrid structural+behavioral typing: grep invariant plus behavioral agent-citation check) and SC-1b (VbC working-copy rename away from the behavioral-evidence prefix; behavioral typing via session.yaml traces); inserted Item 2 for SC-1b and renumbered subsequent Items to 3–8; updated phase membership (Phase 1: Items 1–2; Phase 2: Items 3–7; Phase 3: Item 8), Dependencies (exit-0 guard now after Items 1–2), Traceability (R-1 → SC-1a; R-8 → SC-1b, SC-6), Edge Case item references, Cost Frame, and sc-summary.yaml (sc_count 8). All other SCs untouched. | Validation iteration 1 aggregate FAIL localized to SC-1: compound_scs plus decomposition_atomicity/decomposition_single_deliverable (SC-1 bundled documentation convergence with a runtime working-copy rename — distinct deliverables in distinct subsystems) and testability/evidence_type_method_crosscheck EVIDENCE_TYPE_MISMATCH (declared behavioral while method was grep invariant plus pre-existing exit-0 regression test, omitting the agent-citation behavioral check prescribed by the testability-assessment artifact) | Spec-validation pipeline remediation via spec-creation revise task under for_analysis scope |

---

Co-authored with AI: OpenCode (opencode/x-preview-f-free)
