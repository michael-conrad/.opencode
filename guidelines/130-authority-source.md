---
trigger_on: authority, authoritative, source of truth, code over doc
tier: 1
load_when: sub-agent
---

# Guideline 10: Code as Authoritative Source

## Principle

The current state of the filesystem (the code) is the only absolute source of truth. Documentation, plans, and session
history are secondary and potentially transient or outdated.

## Rules

1. **Code Priority**: If a discrepancy is found between the code (including filenames, structure, and logic) and any
   non-code source (plans, docs, user prompts referencing old states), the **code wins**.

2. **Check for Superseding Issues AND Staleness First**: Before implementing OR revising any spec, check for:

    **Superseding Issues**: Later GitHub Issues that may supersede, invalidate, or contradict the active spec.
    Implementation of a superseded spec is wasted work.

    - Query all open `[SPEC]` issues and check for conflicting/overlapping objectives
    - Look for `[SPEC-FIX]` or `[SPEC-ENHANCEMENT]` issues that may render the active spec obsolete
    - If a later issue exists, SILENTLY HALT and report the conflict — do NOT proceed with superseded spec

    **Staleness from Implemented Specs**: Other specs that were implemented while this spec was pending,
    making the active spec stale or partially obsolete.

    - Check for merged PRs that implemented related functionality
    - Check if referenced code locations have been modified since spec creation
    - Check if referenced dependencies/libraries have changed
    - Check if the problem statement still applies (may have been fixed by another implementation)
    - If staleness detected, REVISE the spec before implementation:
      1. Update problem statement if context changed
      2. Update affected files/lines if code locations changed
      3. Update success criteria if requirements shifted
      4. Update dependencies if integration points changed
      5. Report the revision and HALT — wait for approval before proceeding
    - NEVER implement a stale spec as-is — always revise first

    **Overlap Detection Checklist (MANDATORY when checking for superseding issues):**

    Title/objective comparison alone is insufficient. Before classifying overlap, perform the following checklist:

    - [ ] **File-level search:** Extract all file paths mentioned in the active spec's affected-files or file_references sections. For each open `[SPEC]`/`[PLAN]`/`[SPEC-FIX]` issue, compare file paths. Shared files → potential overlap.
    - [ ] **Symbol-level search:** Extract all function, class, and module names referenced in the active spec body. For each overlapping open issue, compare symbol names. Shared symbols → potential overlap.
    - [ ] **Concern boundary comparison:** Extract the concern area each phase addresses (what problem each phase solves). For each overlapping open issue, compare concern boundaries. Shared concerns → potential overlap.
    - [ ] **Four-tier classification:** Based on file, symbol, and concern overlap, classify using:
      - **FULL-SUPERSESSION:** Another spec's scope entirely covers this spec's scope → HALT, report full scope overlap, recommend using existing spec
      - **PARTIAL-OVERLAP:** Specs share files/symbols but have different core concerns → Surface to developer, suggest scoping to avoid overlap
      - **CONFLICT-RISK:** Same files modified with conflicting intent → HALT, suggest coordination
      - **INDEPENDENT:** No meaningful overlap → Proceed normally
    - [ ] **Evidence artifacts:** For each overlap classification, record: `{Check: overlap search, Tool: github_list_issues + srclight_get_dependents, Result: shared files/symbols/concerns, Classification: FULL-SUPERSESSION|PARTIAL-OVERLAP|CONFLICT-RISK|INDEPENDENT, Action: HALT|surface|surface|proceed}`

3. **Documentation Drift Protocol**:

   - When drift is detected, you MUST NOT "fix" the code to match the documentation or plan.
   - Instead, you MUST update the plan/documentation to reflect the reality of the code. Updating
     plan/documentation to reflect code reality is exempt from the approval gate (treated as a synchronization
     administrative action, not a code change).
   - **CRITICAL: This exemption applies ONLY to spec files in GitHub Issues. It does NOT apply
     to `.opencode/guidelines/` modifications — those require full spec-first workflow.**
   - After syncing the documentation, STOP and report the synchronization.

4. **Always Update Specs to Reflect Reality**: Specs must match current code/implementation state. If drift is detected:

   - Specs are secondary to code — code is the authoritative source
   - Update the spec to reflect reality (treating as administrative sync, not implementation)
   - Report the synchronization and HALT
   - **This exemption applies ONLY to spec/plan files, NOT to `.opencode/guidelines/`**

5. **Suppression of Reactive Remediation**:

   - Explicitly forbidden: Proposing or applying code changes solely to make the code conform to an expectation derived
     from a non-code source.
   - Remediation must only be driven by technical bugs, explicit architectural requests, or approved feature additions,
     never by documentation drift.

6. **Verification First**: Before using a filename or symbol from a plan or document in a tool call, command, or code
   edit, verify its existence using the appropriate tool (`ls`, `search_project`, etc.). If it does not exist, trigger
   the Drift Protocol. This does not apply when merely discussing or quoting a filename from a document.

7. **Deep Dive Before Declaring Missing**: When analysis identifies a seemingly missing component (e.g., email delivery,
   a utility class, a service integration), do NOT assume it is absent. Perform a thorough search of the codebase —
   using `srclight_search_symbols`, `grep`, and directory exploration — before concluding the component
   is missing. The component may already exist under a different name, module, or abstraction. Only after a genuine deep
   dive may you declare it missing and propose adding it.

8. **Plan Audit Requires Code Deep Dive**: When auditing or updating any plan, strictly follow the mandatory code deep
   dive and verification requirements defined in `docs/specs/how-to-write-good-spec-ai-agents.md`. Ground every plan
   audit finding in the actual filesystem and source code, not in remembered or stored state.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: authority-source-001
    title: "Code wins over documentation when discrepancy found"
    conditions:
      all:
        - "discrepancy_between_code_and_docs == true"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: []
    source: "130-authority-source.md §Rules 1"

  - id: authority-source-002
    title: "Check for superseding issues before implementing spec"
    conditions:
      all:
        - "action == 'implement_spec'"
        - "superseding_issues_checked == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [approval-gate, issue-operations]
    source: "130-authority-source.md §Rules 2"

  - id: authority-source-003
    title: "HALT when full supersession detected"
    conditions:
      all:
        - "overlap_classification == 'FULL-SUPERSESSION'"
    actions:
      - HALT
    conflicts_with: []
    requires: [authority-source-002]
    triggers: []
    source: "130-authority-source.md §Rules 2"

  - id: authority-source-004
    title: "Never implement stale spec as-is"
    conditions:
      all:
        - "staleness_detected == true"
        - "spec_revised == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [approval-gate]
    source: "130-authority-source.md §Rules 2"

  - id: authority-source-005
    title: "Never fix code to match documentation drift"
    conditions:
      all:
        - "documentation_drift_detected == true"
        - "proposed_action == 'fix_code'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "130-authority-source.md §Rules 3,5"

  - id: authority-source-006
    title: "Documentation drift sync exemption applies only to GitHub Issues"
    conditions:
      all:
        - "documentation_drift_detected == true"
        - "target == '.opencode/guidelines/'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [approval-gate]
    source: "130-authority-source.md §Rules 3,4"

  - id: authority-source-007
    title: "Verify file/symbol existence before using in tool call"
    conditions:
      all:
        - "about_to_use_filename_from_plan == true"
        - "existence_verified == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "130-authority-source.md §Rules 6"

  - id: authority-source-008
    title: "Deep dive before declaring component missing"
    conditions:
      all:
        - "component_appears_missing == true"
        - "exhaustive_search_performed == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "130-authority-source.md §Rules 7"
```
