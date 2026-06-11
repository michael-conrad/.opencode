# Implementation Plan — Issue Comment Churn Regression

## Authorization Context

```
authorization_scope: for_pr
halt_at: pr_created
pr_strategy: stacked
pipeline_phase: plan-creation
```

## Dependency Order

Phase 2 → Phase 1 (completion-core needs channel-routing table)
Phase 3 → Phase 2 (post instructions need updated completion template)
Phase 4 → Phase 1 (same file: 000-critical-rules.md)
Phase 5 → Phase 4 (same file section)
Phase 6 → Phase 3 (behavioral test verifies the fix)
Phase 7 (SC-7) → Phase 3 (020-go-prohibitions.md parallel to file edits)
Phase 8 (SC-8) → Phase 2 (caller-side gate depends on completion template)

However, Phases 1-5 and 7 are all text edits in different files/sections, which means they can be parallelized in practice. Phase 6 (behavioral test) must come after all changes are made. Phase 8 is a behavioral design change that can be done with Phase 2.

Actual parallel groups:
- Group A (parallel): Phase 1, Phase 4, Phase 5 (all 000-critical-rules.md but different sections)
- Group B (parallel): Phase 2, Phase 3, Phase 7 (different skill files + 020-go-prohibitions.md)
- Group C (after A+B): Phase 6, Phase 8 (behavioral test + caller gate logic)

---

## Phase 1: Restore Channel-Routing Table in 000-critical-rules.md (SC-1)

**Why:** The channel-routing table from #608 was the primary enforceable rule mapping actions to chat vs. issue. Its removal in commit `ab2350fa` directly caused agents to post non-substantive status updates as issue comments. Without this table, the only remaining rule ("Issue comments are for substantive information only") is too abstract to prevent status-spam.

**What:** Restore the 10-row Action→Channel mapping table, the bold-rule "Progress executive summaries go to chat ONLY, not GitHub Issue comments", and the accompanying yaml+symbolic rule.

**File:** `.opencode/guidelines/000-critical-rules.md`

**Location:** After the last Tier 2 rule in the "Rules by Tier" section, before the yaml+symbolic block that follows.

**Content to restore (from git history, pre-ab2350fa):**

```markdown
### Channel-Routing Table — Issue Comments vs. Chat Output

**Progress executive summaries go to chat ONLY, not GitHub Issue comments.**

| Action | Channel |
|--------|---------|
| Progress executive summaries | Chat only |
| Review-prep / verification status | Chat only |
| Substantive spec revision | Chat + Issue comment |
| PR created | Issue comment |
| Issue blocked | Issue comment |
| Bug discovered during implementation | Issue comment |
| User question response | Issue comment |
| Issue closure | Issue comment |
| Agent completes implementation task | Chat only |
| Spec-audit findings | Internal only |
```

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-1.1 | RED | Write grep test that confirms the channel-routing table is absent from 000-critical-rules.md | `grep -c "Channel-Routing Table" 000-critical-rules.md` → 0 |
| GREEN-1.1 | GREEN | Restore the table and bold-rule at the correct location | `grep -c "Channel-Routing Table" 000-critical-rules.md` → 1 |
| REFACTOR-1.1 | REFACTOR | Verify no duplicate entries; verify table renders correctly | Quick visual scan |

**Success criteria:**
- SC-1: Channel-routing table present with 10 rows. **Evidence type: behavioral** — verified by clean-room agent read + grep confirming table and bold-rule exist.

**Dependencies:** None (independent file edit)

**What could go wrong:** Wrong placement in file (before/after wrong section); symbol rule entry not added in yaml+symbolic block; table formatting broken.

---

## Phase 2: Fix completion-core/tasks/completion.md Step 3 (SC-2)

**Why:** Step 3 is the PRIMARY regression vector — it mandates "Post a progress comment to the issue" with a specific template (Phase/Implemented/Verified/Remaining) as an exit criterion. This is the template callers use to generate non-substantive status updates. The fix changes Step 3 to route through `issue-operations -> comment` substantive gate instead of mandating a post.

**File:** `.opencode/skills/completion-core/tasks/completion.md`

**Location:** Step 3 (lines 71-95)

**Changes:**
1. Replace Step 3 heading from "Post Completion Comment" to "Route Completion Comment Through Substantive Gate"
2. Remove the Phase/Implemented/Verified/Remaining template
3. Replace the fixed template with: route to `issue-operations -> comment -> substantive gate` — the gate decides whether posting is warranted
4. Remove the "Post a progress comment to the issue summarizing:" language
5. Update the exit criterion from "Issue/PR comments posted with summary" to "Completion comment routed through substantive gate"

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-2.1 | RED | Confirm Step 3 still contains "Post a progress comment" | grep match → present |
| GREEN-2.1 | GREEN | Edit Step 3 to route through substantive gate, remove fixed template | grep → "Post a progress comment" absent, "substantive gate" present |
| REFACTOR-2.1 | REFACTOR | Update Exit Criteria; update Idempotency Summary | Verify SC-2 exit criterion mentions gate, not posting |

**Success criteria:**
- SC-2: Step 3 changed from "post a progress comment" to "route through issue-operations -> comment (substantive gate)". **Evidence type: string** — grep for old pattern absent, new pattern present.

**Dependencies:** None (independent file edit)

**What could go wrong:** Breaking callers that expect an `comment_posted: true` result contract field. The Idempotency Summary must be updated to reflect the gate-based flow.

---

## Phase 3: Audit and Change All 9 Mandatory "Post to Issue" Instructions (SC-3)

**Why:** The codebase contains approximately 9 mandatory instructions telling agents to post content to GitHub Issues. These outnumber the substantive gate 9:1. Each must be changed to route through `issue-operations -> comment` substantive gate.

**Files (9 mandatory post instructions to audit and fix):**

| # | File | Instruction | Change |
|---|------|-------------|--------|
| 1 | `.opencode/skills/completion-core/completion-core.md` §3 | "Post Status Comment" | Add substantive gate reference; remove "post" mandate, replace with "route through gate" |
| 2 | `.opencode/skills/finishing-a-development-branch/tasks/completion.md` line 25 | "Post status comment on issue (with idempotency check)" | Route through substantive gate |
| 3 | `.opencode/skills/finishing-a-development-branch/tasks/completion.md` line 62 | "Status comment posted" verification | Change to "comment routed through gate" verification |
| 4 | `.opencode/skills/git-workflow/tasks/completion.md` line 31 | "Post status comment on issue" | Route through substantive gate |
| 5 | `.opencode/skills/git-workflow/tasks/cleanup/verify-merge.md` line 100 | "MUST be posted as a comment on the issue" | Route through substantive gate before closure |
| 6 | `.opencode/skills/approval-gate/tasks/completion.md` | Post authorization result comment | Route through substantive gate |
| 7 | `.opencode/skills/approval-gate/tasks/verify-already-implemented.md` | "Post a verification comment" | Route through substantive gate |
| 8 | `.opencode/skills/issue-review/tasks/completion.md` | "durable outcomes posted to issue" | Route through substantive gate |
| 9 | `.opencode/skills/issue-review/tasks/qa.md` | "Exec summary posted to issue" | Route through substantive gate |

**Change pattern for all 9:** Replace "post X to issue" → "route through issue-operations -> comment substantive gate. If the gate passes, post with byline. If the gate skips, output to chat only."

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-3.1 | RED | Confirm all 9 instructions contain "post" mandate (compiled list from phase intro) | grep each for "post" + "comment"/"issue" |
| GREEN-3.1 | GREEN | Change all 9 instructions to route through substantive gate | grep each for "post" → succeed but in gate context |
| REFACTOR-3.1 | REFACTOR | Verify no remaining "post X to issue" mandates remain (excluding read-comment and byline-standalone rules) | `grep -r "post.*comment.*issue\|post.*status.*issue\|MUST.*post.*comment"` → only gate-routed references remain |

**Success criteria:**
- SC-3: All 9 mandatory post-to-issue instructions changed. **Evidence type: string** — grep confirms old pattern absent, new gate-routing pattern present.

**Dependencies:** None (independent file edits across multiple skill files)

**What could go wrong:** Missing some of the 9 instructions (need thorough grep), or over-fixing by changing instructions that reference `read-comments` or existing-comment checks.

---

## Phase 4: Restore FORBIDDEN/REQUIRED Structure in 000-critical-rules.md (SC-4)

**Why:** Commit `ab2350fa` collapsed all structured `### 🚫 FORBIDDEN` / `### ✅ REQUIRED` subsections into compressed one-line bullet ranges. The structured format (subsections with "Why This Matters" consequence tables) creates behavioral friction that prevents agents from skipping enforcement steps. Compressed bullets are easily ignored.

**File:** `.opencode/guidelines/000-critical-rules.md`

**Scope:** The following critical violation entries are affected (currently one-liner bullets):

1. Worktree Bypass (line: near top, compressed to `- 🚫 FORBIDDEN: ...`)
2. Skipping Git Pre-Check (compressed)
3. Relative File Paths in Worktree Context (compressed)
4. Implementing Without Verifying Against Live Documentation (compressed)
5. Verification Dishonesty (compressed)
6. Non-Idempotent API Mutations (compressed)
7. Secret Exfiltration (compressed)
8. Any other bullet-range violations that were previously FORBIDDEN/REQUIRED sections

**Restore format for each:**

```markdown
### [critical-rules-XXX] CRITICAL VIOLATION — Title

Description of the violation in bold.

#### 🚫 FORBIDDEN

- Forbidden action 1
- Forbidden action 2

#### ✅ REQUIRED

- Required action 1
- Required action 2

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Pattern 1 | Consequence 1 |
```

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-4.1 | RED | Count current one-liner bullet violations | `grep -c "^### \[critical-rules\]"` → count; `grep -c "^### 🚫"` → 0 |
| GREEN-4.1 | GREEN | Restore FORBIDDEN/REQUIRED structure for each compressed entry | `grep -c "^### 🚫"` → restored count > 0 |
| REFACTOR-4.1 | REFACTOR | Verify no remaining one-liner bullet-only critical violation entries | Each violation has subsections or is single-line-by-design |

**Success criteria:**
- SC-4: FORBIDDEN/REQUIRED structure and "Why This Matters" tables restored. **Evidence type: string** — grep for structured subsections present.

**Dependencies:** None (same file as Phase 1 but different sections)

**What could go wrong:** Over-restoring content that was intentionally simplified (some one-liners may be correct for simple entries). Must diff against pre-ab2350fa content to identify what was compressed vs. intentionally simplified.

---

## Phase 5: Restore Spec-Audit Findings Leak Prohibition (SC-5)

**Why:** Two rules were deleted in commit `ab2350fa`:
1. "⚠️ Posting spec-audit findings as GitHub comments is FORBIDDEN."
2. "Audit findings from spec-auditor are internal agent guidance — equivalent to linter output."

Without these rules, an agent might interpret audit results as substantive stakeholder content and post them to issues.

**File:** `.opencode/guidelines/000-critical-rules.md`

**Location:** In the Tier 2 section, near the "Audience Separation" rule (around line 202).

**Change:** Restore the two deleted rules as a standalone entry:

```markdown
### [critical-rules-XXX] Posting Spec-Audit Findings as Issue Comments

**⚠️ Posting spec-audit findings as GitHub comments is FORBIDDEN.**

Audit findings from spec-auditor are internal agent guidance — equivalent to linter output. They must be posted to chat only.

- 🚫 FORBIDDEN: Posting audit findings (spec audits, plan fidelity checks, cross-validate results) as GitHub Issue comments
- 🚫 FORBIDDEN: Treating audit output as stakeholder-facing content
- ✅ REQUIRED: Audit findings go to chat only. Spec revisions (not audit results) go to issue comments when substantive.
```

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-5.1 | RED | Verify the spec-audit findings leak prohibition is absent | `grep -c "spec-audit findings"` → 0 |
| GREEN-5.1 | GREEN | Add the prohibition entry | `grep -c "spec-audit findings"` → 1 |
| REFACTOR-5.1 | REFACTOR | Verify placement is correct (near Audience Separation rule) | Quick visual scan |

**Success criteria:**
- SC-5: Spec-audit findings leak prohibition restored. **Evidence type: string** — grep confirms rule present.

**Dependencies:** None (same file, different section)

---

## Phase 6: Add Behavioral Enforcement Test (SC-6)

**Why:** Per `080-code-standards.md` §Enforcement Test Mandate, every behavioral rule change requires a behavioral enforcement test. SC-6 verifies that when an agent receives a "phase complete" prompt (the pattern that caused the regression), the agent does NOT post it as an issue comment.

**File:** `.opencode/tests/behaviors/comment-churn-regression.sh`

**Test design:**

```bash
#!/bin/bash
# Behavioral test for issue #1106 — agent must NOT post non-substantive status updates to issues
source "$(dirname "$0")/helpers.sh"

# SC-6: Agent does not post "phase complete" as issue comment
# Send a prompt that would trigger a completion comment in the broken state
run_test "SC-6" \
  "prompt: 'complete the current phase and report' (with mock issue context)" \
  "assert_stderr_pattern_absent 'github_add_issue_comment|add-comment' '#1106: agent should not post status update as issue comment'" \
  "assert_stderr_pattern_present 'chat only|substantive' '#1106: agent should route non-substantive to chat'"

cleanup
```

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-6.1 | RED | Write behavioral test that sends a "phase complete" prompt with issue context — test MUST FAIL because current agent posts the comment | Run test: expects no `github_add_issue_comment` but current agent posts → test fails |
| GREEN-6.1 | GREEN | (Implemented by all prior phases — the codebase changes make the agent route through substantive gate) | Re-run test: agent does NOT post, routes to chat only → test passes |
| REFACTOR-6.1 | REFACTOR | Run scope-limited behavioral suite | `bash .opencode/tests/test-enforcement.sh --tag comment-churn` |

**Success criteria:**
- SC-6: Behavioral enforcement test exists that sends a "phase complete" prompt and verifies the agent does NOT post it as an issue comment. **Evidence type: behavioral** — test execution via `opencode-cli run` produces PASS.

**Dependencies:** Phases 1-5 complete (the test must pass against the fixed codebase)

**What could go wrong:** Test environment needs clean issue context; the mock must provide enough context to trigger the posting path without actually posting.

---

## Phase 7: Fix 020-go-prohibitions.md Authorization-Free Rule (SC-7)

**Why:** Line 186 of `020-go-prohibitions.md` lists "Posting progress comments to GitHub — always permitted" as an authorization-free action. This contradicts the fix — progress comments should go through the substantive gate, not be blanket-permitted.

**File:** `.opencode/guidelines/020-go-prohibitions.md`

**Location:** Around line 186, in the "Authorization-Free Actions" list.

**Change:** Replace:

```
- Posting progress comments to GitHub — always permitted
```

With:

```
- Posting progress comments to GitHub — permitted only through issue-operations -> comment substantive gate. Non-substantive progress (status updates, "phase complete", "implemented X") goes to chat only, never to issue comments.
```

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-7.1 | RED | Confirm line 186 says "always permitted" | `grep` → match present |
| GREEN-7.1 | GREEN | Replace with qualified permission routing through substantive gate | `grep` → "always permitted" absent, "substantive gate" present |
| REFACTOR-7.1 | REFACTOR | Verify no other "always permitted" for progress comments in the file | grep for other instances |

**Success criteria:**
- SC-7: `020-go-prohibitions.md` "progress comments always permitted" removed or qualified. **Evidence type: string** — grep confirms change.

**Dependencies:** None (independent file edit, parallel with Phase 2 and 3)

---

## Phase 8: Fix comment.md Substantive Gate Evaluation (SC-8)

**Why:** The current design has callers (completion-core Step 3, finishing-a-development-branch, git-workflow) that **mandate posting** before ever routing to the substantive gate. The gate says "status update → SKIP" but it's too late — the caller already committed to posting. The fix: callers evaluate the gate BEFORE deciding to post, not after.

**Files:**
1. `.opencode/skills/issue-operations/tasks/comment.md` — ensure the substantive gate (Step 1) is clearly an early-evaluation gate that callers invoke BEFORE committing
2. `.opencode/skills/completion-core/tasks/completion.md` — already fixed in Phase 2 to route through gate before posting
3. `.opencode/skills/completion-core/completion-core.md` §3 — already fixed in Phase 3 to evaluate gate first

**Change to comment.md:** Add caller guidance (Step 0) that makes explicit: "This gate MUST be evaluated by callers BEFORE the caller commits to posting." This ensures the design intent is clear regardless of specific caller implementation.

### TDD Items

| Item | Phase | Action | Verification |
|------|-------|--------|-------------|
| RED-8.1 | RED | Verify no Step 0 caller-guidance exists in comment.md | Check for "BEFORE the caller commits" language → absent |
| GREEN-8.1 | GREEN | Add Step 0 caller guidance to comment.md | grep → "BEFORE the caller commits" present |
| REFACTOR-8.1 | REFACTOR | Verify that all 9 post instructions (Phase 3) and completion-core (Phase 2) now evaluate gate BEFORE posting | Cross-reference changes from Phases 2-3 |

**Success criteria:**
- SC-8: The substantive gate is evaluated by callers BEFORE the caller commits to posting, not after. **Evidence type: behavioral** — clean-room agent sub-agent reads comment.md and verifies the gate is positioned as pre-commit evaluation for callers.

**Dependencies:** Phase 2 (completion-core fix), Phase 3 (all 9 post instructions fixed)

---

## Summary

| Phase | SC | File(s) | Evidence Type | Depends On | Parallel Group |
|-------|-----|---------|---------------|------------|----------------|
| 1 | SC-1 | `guidelines/000-critical-rules.md` | behavioral | None | A |
| 2 | SC-2 | `skills/completion-core/tasks/completion.md` | string | None | B |
| 3 | SC-3 | 9 skill task files | string | None | B |
| 4 | SC-4 | `guidelines/000-critical-rules.md` | string | None | A |
| 5 | SC-5 | `guidelines/000-critical-rules.md` | string | None | A |
| 6 | SC-6 | `tests/behaviors/comment-churn-regression.sh` | behavioral | 1-5 | C |
| 7 | SC-7 | `guidelines/020-go-prohibitions.md` | string | None | B |
| 8 | SC-8 | `skills/issue-operations/tasks/comment.md` | behavioral | 2, 3 | C |

**Execution order:**
1. Parallel Group A (Phases 1, 4, 5): All three 000-critical-rules.md edits — can be done in any order since they touch different sections
2. Parallel Group B (Phases 2, 3, 7): Skill task files and 020-go-prohibitions.md — independent of each other
3. Sequential Group C (Phase 6, then Phase 8): Behavioral test after all code changes; SC-8 after caller changes in Phases 2-3