# Phase 5 — Remove comment-scanning for authorization

**Concern:** Eliminate all scanning of issue comments for authorization tokens; authorization is parsed from chat messages only.

**Files:**
- `.opencode/skills/audit/tasks/drift-detection-investigator.md`
- `.opencode/skills/issue-review/tasks/gather.md`
- `.opencode/skills/brainstorming/tasks/enforcement.md`
- `.opencode/skills/issue-operations-core/tasks/post-creation.md`
- `.opencode/skills/approval-gate/tasks/resolve-scope.md`
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/gh-cli/tasks/triage-issues.md`
- `.opencode/guidelines/067-context-completeness.md`
- `.opencode/guidelines/257-procedural-discipline-reference.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`

**SCs:** SC-15, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: local-first label reads established
- Phase 2 VbC passed
- Phase 4 may precede this phase where `operating-protocol.md` SC-17 (Phase 4) precedes SC-15/SC-17 edits on the same file

**Exit Conditions:**
- No task file, skill card, or guideline scans comments for "approved"/"go" or notes authorization in comments
- `resolve-scope.md` parses authorization from chat message only

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-15 | audit → drift-detection → Metadata Verification Extension (rows removed) |
| SC-18 | issue-review → gather → comment scan (removed) |
| SC-19 | brainstorming → enforcement → comment approval check (removed) |
| SC-20 | issue-operations-core → post-creation → Live Verification (comment scan removed) |
| SC-21 | approval-gate → resolve-scope → parse auth from chat (verb-prefix table) → not from comments |
| SC-22 | approval-gate → SKILL.md → comment references (removed) |
| SC-23 | gh-cli → triage-issues → comment auth noting (removed) |
| SC-24 | guideline → agent context completeness → comment-scanning language (removed) |
| SC-25 | guideline → procedural discipline → comment history example (removed) |
| SC-26 | issue-operations → gitbucket-api → comment fallback (removed) |

## Cross-Cutting SCs

SC-18 is cross-cutting: `gather.md` is shared with SC-12 (Phase 2 local-read change). This phase's SC-18 edit follows Phase 2's SC-12 edit to avoid same-file edit conflict. `drift-detection-investigator.md` (SC-15) and `operating-protocol.md` (SC-17) were also edited in Phase 2/Phase 4; this phase's edits follow.

## Interface Boundaries

- `approval-gate/SKILL.md → agent auth instructions` — BACKWARD-COMPATIBLE. Auth determination semantics unchanged (chat "approved"/"go"); only comment-scanning references removed.
- `resolve-scope.md → auth parsing` — BACKWARD-COMPATIBLE. Verb-prefix parsing table unchanged; only the message source narrowed to chat.
- `gitbucket-api/SKILL.md → label replacement` — BACKWARD-COMPATIBLE. Removes a fragile fallback; local `issue.yaml` now covers label state.

## State Transitions

| SC | From | To |
|----|------|----|
| SC-15 | `drift-detection-investigator.md` contains Authorization currency and Authorization author identity rows | no longer contains those rows |
| SC-18 | `gather.md` scans comments for "approved"/"go" patterns | no longer scans comments |
| SC-19 | `enforcement.md` checks comments for User approved design | no longer checks comments |
| SC-20 | `post-creation.md` Live Verification checks comments for approved/go | Live Verification no longer checks comments |
| SC-21 | `resolve-scope.md` parses auth from issue comments | parses auth from chat message only |
| SC-22 | `approval-gate/SKILL.md` references reading comments for authorization | no longer references reading comments |
| SC-23 | `triage-issues.md` notes authorization found in comments | no longer notes authorization in comments |
| SC-24 | `067-context-completeness.md` says authorization may live in a comment | no longer says that |
| SC-25 | `257-procedural-discipline-reference.md` includes Authorization verified via comment history example | no longer includes that example |
| SC-26 | `gitbucket-api/SKILL.md` uses label replacement via comment fallback | no longer uses comment fallback |

**Cost frame:** Verifying each comment-scanning removal costs one grep search (string SCs) or one clean-room sub-agent read (semantic SC-21). Skipping means agents still scan comments for "approved"/"go" — producing false positives from discussion language, or still parse authorization from stale, out-of-context issue comments.

---

- [ ] 67. **RED (**sub-agent**).** Run a grep assertion that `drift-detection-investigator.md` currently contains "Authorization currency". The assertion SHALL match (RED state) because the auth rows are present. **→ SC-15**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 68. **GREEN (**sub-agent**).** Remove the "Authorization currency" and "Authorization author identity" rows from the Metadata Verification Extension in `drift-detection-investigator.md`. **→ SC-15**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 69. **Verify (**clean-room**).** Grep `drift-detection-investigator.md` for "Authorization currency" and "Authorization author identity" — SHALL return no matches. **→ SC-15**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 70. **Checkpoint commit (**inline**).** Commit `drift-detection-investigator.md`. **→ SC-15**

- [ ] 71. **RED (**sub-agent**).** Run a grep assertion that `gather.md` currently contains "approved" or "go" comment-scanning patterns. The assertion SHALL match (RED state) because comment scanning is present. **→ SC-18**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 72. **GREEN (**sub-agent**).** Remove the scanning of comments for "approved"/"go" patterns from `gather.md`. **→ SC-18**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 73. **Verify (**clean-room**).** Run `grep -w approved` and `grep -w go` against `gather.md` — SHALL return no matches. **→ SC-18**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 74. **Checkpoint commit (**inline**).** Commit `gather.md`. **→ SC-18**

- [ ] 75. **RED (**sub-agent**).** Run a grep assertion that `enforcement.md` currently contains "User approved design". The assertion SHALL match (RED state) because the verification row is present. **→ SC-19**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 76. **GREEN (**sub-agent**).** Remove the "User approved design" verification row that checks comments for approval from `enforcement.md`. **→ SC-19**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 77. **Verify (**clean-room**).** Grep `enforcement.md` for "User approved design" — SHALL return no matches. **→ SC-19**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 78. **Checkpoint commit (**inline**).** Commit `enforcement.md`. **→ SC-19**

- [ ] 79. **RED (**sub-agent**).** Run a grep assertion that `post-creation.md` currently contains "comment-scanning". The assertion SHALL match (RED state) because the comment check is present in the Live Verification table. **→ SC-20**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 80. **GREEN (**sub-agent**).** Remove the "approved"/"go" check in comments from the Live Verification table in `post-creation.md`. **→ SC-20**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 81. **Verify (**clean-room**).** Grep `post-creation.md` for "comment-scanning" — SHALL return no matches. **→ SC-20**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 82. **Checkpoint commit (**inline**).** Commit `post-creation.md`. **→ SC-20**

- [ ] 83. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `resolve-scope.md` parses authorization from the chat message only, not from issue comments. The test FAILS because the file currently parses auth from issue comments. **→ SC-21**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 84. **GREEN (**sub-agent**).** Modify `resolve-scope.md` to parse authorization from the chat message only (verb-prefix table), removing parsing from issue comments. **→ SC-21**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 85. **Verify (**clean-room**).** Clean-room sub-agent reads `resolve-scope.md` and evaluates whether auth is parsed from chat only. **→ SC-21**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 86. **Checkpoint commit (**inline**).** Commit `resolve-scope.md` together with the behavioral test as one atomic slice. **→ SC-21**

- [ ] 87. **RED (**sub-agent**).** Run a grep assertion that `approval-gate/SKILL.md` currently contains "authorization may live in a comment". The assertion SHALL match (RED state) because the comment reference is present. **→ SC-22**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 88. **GREEN (**sub-agent**).** Remove the references to reading comments for authorization from `approval-gate/SKILL.md`. **→ SC-22**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 89. **Verify (**clean-room**).** Grep `approval-gate/SKILL.md` for "authorization may live in a comment" — SHALL return no matches. **→ SC-22**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 90. **Checkpoint commit (**inline**).** Commit `approval-gate/SKILL.md`. **→ SC-22**

- [ ] 91. **RED (**sub-agent**).** Run a grep assertion that `triage-issues.md` currently contains "authorization". The assertion SHALL match (RED state) because the auth-in-comment noting is present. **→ SC-23**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 92. **GREEN (**sub-agent**).** Remove the noting of authorization in comments from `triage-issues.md`. **→ SC-23**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 93. **Verify (**clean-room**).** Run `grep -w authorization` against `triage-issues.md` — SHALL return no matches. **→ SC-23**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 94. **Checkpoint commit (**inline**).** Commit `triage-issues.md`. **→ SC-23**

- [ ] 95. **RED (**sub-agent**).** Run a grep assertion that `067-context-completeness.md` currently contains "authorization may live in a comment". The assertion SHALL match (RED state) because the comment-scanning language is present. **→ SC-24**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 96. **GREEN (**sub-agent**).** Remove the "authorization may live in a comment, not the body" language from `067-context-completeness.md`. **→ SC-24**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 97. **Verify (**clean-room**).** Grep `067-context-completeness.md` for "authorization" — SHALL return no matches for comment-scanning language. **→ SC-24**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 98. **Checkpoint commit (**inline**).** Commit `067-context-completeness.md`. **→ SC-24**

- [ ] 99. **RED (**sub-agent**).** Run a grep assertion that `257-procedural-discipline-reference.md` currently contains "Authorization verified". The assertion SHALL match (RED state) because the comment-history example is present. **→ SC-25**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 100. **GREEN (**sub-agent**).** Remove the "Authorization verified via comment history" example from `257-procedural-discipline-reference.md`. **→ SC-25**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 101. **Verify (**clean-room**).** Grep `257-procedural-discipline-reference.md` for "Authorization verified" — SHALL return no matches. **→ SC-25**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 102. **Checkpoint commit (**inline**).** Commit `257-procedural-discipline-reference.md`. **→ SC-25**

- [ ] 103. **RED (**sub-agent**).** Run a grep assertion that `gitbucket-api/SKILL.md` currently contains "comment fallback". The assertion SHALL match (RED state) because the label-replacement fallback is present. **→ SC-26**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 104. **GREEN (**sub-agent**).** Remove the label replacement via comment fallback from `gitbucket-api/SKILL.md`. **→ SC-26**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 105. **Verify (**clean-room**).** Grep `gitbucket-api/SKILL.md` for "comment fallback" — SHALL return no matches. **→ SC-26**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 106. **Checkpoint commit (**inline**).** Commit `gitbucket-api/SKILL.md`. **→ SC-26**

#### Phase 5 VbC

- [ ] 107. **VbC (**clean-room**).** Verify no task file, skill card, or guideline in this phase scans comments for "approved"/"go" or notes authorization in comments; `resolve-scope.md` parses auth from chat only. **→ SC-15, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving comment-scanning removal → entering dead-file deletion (independent). No phase depends on Phase 5.
