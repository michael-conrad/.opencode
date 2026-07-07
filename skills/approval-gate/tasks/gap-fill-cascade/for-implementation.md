<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Gap-Fill Checklist: `for_implementation` Scope

**Purpose:** State-verification checklist for `for_implementation` authorization scope. Walk items sequentially. Report the first missing state or that all states are verified.

**Context received:** `{ authorization_scope, issue_number, github.owner, github.repo }`

---

## Checklist Items

### Item 1: Spec exists and is approved

- **State:** Spec issue exists with `[SPEC]` label
- **Verify:** Read issue `{issue_number}` — check for `[SPEC]` label
- **If PASS:** Proceed to Item 2
- **If FAIL:** Report `next_action: spec-creation` with reason "No approved spec found for issue {issue_number}"

### Item 2: Plan exists and is faithful to spec

- **State:** Plan file exists at `*/.issues/{issue_number}/plan.md`
- **Verify:** Check if `*/.issues/{issue_number}/plan.md` exists and is non-empty
- **If PASS:** Proceed to Item 3
- **If FAIL:** Report `next_action: writing-plans` with reason "No plan found for issue {issue_number}"

### Item 3: Plan is approved

- **State:** Issue has `approved-for-plan` label (or scope >= `for_plan` auto-approves)
- **Verify:** Read issue `{issue_number}` — check for `approved-for-plan` label
- **If PASS:** Proceed to Item 4
- **If FAIL:** Report `next_action: apply-label` with reason "Plan for issue {issue_number} needs approval label"

### Item 4: Implementation complete (all SCs verified PASS)

- **State:** Verification artifacts exist for all SCs in spec
- **Verify:** Check `{project_root}/tmp/{issue_number}/artifacts/` for SC verification evidence
- **If PASS:** Report `all_states_verified: true` with summary "All states verified for for_implementation scope"
- **If FAIL:** Report `next_action: implementation-pipeline` with reason "Implementation not complete for issue {issue_number}"

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
