# Phase 2: Remediate — Apply DIRECT and PATTERN-MATCH Updates

**Chain:** `phase_1` (depends on audit log from Phase 1)
**Phase dependency:** `phase_1__complete`
**Concern transition:** Audit concerns complete → Remediation concerns begin

## Step 6: Apply DIRECT classification updates

**Chain:** `step_5` (depends on classification audit log)
**RED:** All DIRECT matches unchanged
**Action:** For every match classified as DIRECT in `1905/audit-log.md`, apply the corresponding update:

| Change # | Old Pattern | New Pattern |
|----------|-------------|-------------|
| 1 | Missing YAML frontmatter references | Add frontmatter notes referencing spec-creation/tasks/create.md format |
| 2 | Missing Goals/Non-Goals in section ordering | Update section order references to include Goals after Problem |
| 3 | Inline AI Agent Instructions | Update to gate-level enforcement reference |
| 4 | "Cards" heading | Replace with "Scope of Work" |
| 5 | Step 7r/7a/7b/7c references | Replace with Step 7.1/7.2/7.3/7.4 |
| 6 | Step 7r content references | Remove dangling references or update per new structure |
| 7 | Step 5 preamble location | Ensure consistent local-only preamble wording |
| 8 | Behavioral test old-format assertions | Update assertion patterns to match new format |

**Dispatch:** Sub-agent via `task()` per affected file (not per change — batch by file for atomicity).
**Procedure per file:**
1. Read file content
2. For each DIRECT match in that file: apply `edit_text` with old→new replacement
3. Verify change was applied correctly
4. Commit: `git -C .opencode add <file> && git -C .opencode commit -m ".opencode#1905: <file>: update DIRECT match for <change-description>"`
**Evidence:** `1905/remediation-log.md` listing every DIRECT match remediated.
**SC coverage:** SC-1, SC-2, SC-3, SC-4
**Verification:** After all updates, re-run grep patterns from Phase 1 — DIRECT matches should return 0 (or only remaining matches are in `create.md` itself, which was already updated in #1902).

## Step 7: Apply PATTERN-MATCH updates

**Chain:** `step_6`
**RED:** PATTERN-MATCH files still use old format structure
**Action:** For every match classified as PATTERN-MATCH, update the structural dependency:

Note: PATTERN-MATCH means the file depends on the old format structure (e.g., reads spec.md and parses old section order, or embeds a template matching old section positions). These are structured changes — not simple find-and-replace.

**Patterns to address:**
- Task files that reference spec section order (e.g., reads `## Problem` then `## Proposed Changes` without checking for `## Goals` in between)
- Task files that embed step templates referencing old numbering
- Behavioral tests that use old step-number assertions
- Any script or tool that parses spec.md and assumes old ordering

**Dispatch:** Sub-agent via `task()` per affected file.
**Evidence:** Updated `1905/remediation-log.md` with PATTERN-MATCH entries.
**SC coverage:** SC-1, SC-2, SC-3, SC-4, SC-5
**Verification:** Each PATTERN-MATCH update verified — the file's behavior with new format structure is correct.

## Step 8: Verify DOMAIN-DIFFERENT classifications

**Chain:** `step_7`
**RED:** Domain-different classifications not yet cross-checked
**Action:** For each DOMAIN-DIFFERENT classification, perform a manual cross-check:
1. Read the file context around the match
2. Confirm the term (e.g., "Cards" in a different domain like "skill cards" or "research cards") is genuinely unrelated to the spec format heading
3. Document the verification in the audit log

**Dispatch:** Sub-agent via `task()` — spot-check with read + confirmation.
**Evidence:** Annotated `1905/audit-log.md` — each DOMAIN-DIFFERENT entry stamped with `[VERIFIED-UNAFFECTED]`.
**SC coverage:** SC-1, SC-2, SC-3
**Verification:** No false negatives — no DOMAIN-DIFFERENT classification that should be DIRECT or PATTERN-MATCH.

## Step 9: GENERIC-PROSE documentation only

**Chain:** `step_8`
**RED:** Generic-prose matches not yet documented
**Action:** GENERIC-PROSE classifications require no action (they are not tied to format). Document count in `1905/audit-log.md` for completeness.
**Evidence:** Count and sample in audit log.
**SC coverage:** SC-1, SC-2, SC-3
**Verification:** No GENERIC-PROSE match affects format behavior.
