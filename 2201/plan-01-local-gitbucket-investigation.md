# Phase 1 — Local GitBucket Investigation

**Concern:** Produce a per-workflow applicability assessment against a local test GitBucket instance, determining which gh-cli workflows apply to gb, which need revision, and which are discarded.

**Files:**
- `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` (new)

**SCs:** SC-17

**Dependencies:** None

**Entry Conditions:**
- Spec #2201 is approved (`approved-for-for_pr` label present in `issue.yaml`)
- Feature branch exists
- `gb` CLI v0.6.1 installed and authenticated (`gb auth status` succeeds)
- Local test GitBucket instance available

**Exit Conditions:**
- `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` exists with per-workflow applicability assessment (APPLIES/REVISED/DISCARDED + rationale) for each gh-cli workflow
- gb-specific workflows identified (manage-milestones, manage-repo with fork/delete, api-requests)

---

## Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` | Created with per-workflow entries |

## Cross-Cutting SCs

| SC | Cross-Cutting Concern |
|----|----------------------|
| SC-17 | Investigation artifact — per-workflow applicability assessment (verification gate: pre-commit) |

## Interface Boundaries

| Boundary | Status |
|----------|--------|
| gh-cli reference template workflows | INPUT — each workflow assessed against gb equivalents |
| gb CLI v0.6.1 command surface | INPUT — commands run against local test instance |
| Phase 2 dispatch contracts | OUTPUT — applicability assessment determines SKILL.md Workflows section |

## State Transitions

| Entity | Before | After |
|--------|--------|-------|
| `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` | Does not exist | Exists with per-workflow applicability assessment |

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting the applicability assessment artifact does not yet exist. **→ SC-17**
- [ ] 2. **GREEN (**sub-agent**).** Run the investigation: for each gh-cli workflow, run the corresponding `gb` commands against the local test GitBucket instance and classify as APPLIES / REVISED / DISCARDED with rationale. Document gb-specific workflows (manage-milestones, manage-repo with fork/delete, api-requests). Write the assessment to `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml`. **→ SC-17**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify the artifact contains entries for each gh-cli workflow with APPLIES/REVISED/DISCARDED classification and rationale. **→ SC-17**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the investigation artifact.

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` exists with per-workflow entries and rationale. **→ SC-17**

**Cost frame:** Verifying the applicability artifact exists and contains per-workflow entries costs one read of the artifact file. Skipping means the Phase 2 SKILL.md Workflows section is built from unverified assumptions about which workflows apply — a structurally wrong skill card that fails audit at the next gate.

**Concern transition:** Leaving local GitBucket investigation → entering skill directory and SKILL.md creation. Phase 2 depends on Phase 1's applicability assessment to determine the dispatch contracts in the Workflows section.
