# Plan — Gmail MCP deny-by-default + dedicated email-ops subagent (.opencode#2568)

Spec: `.opencode/.issues/2568/spec.md`. Authorization: terminal-stage
(`approved for pr`, 2026-10-09) — carries the item through plan, implement, and
the PR boundary; merge remains human-only.

## Reference-currency remediations applied to the spec before planning

1. **Subagent directory path.** Spec Final-state item 2 and SC-5 name
   `.opencode/agent/email-ops.md`; the live deck's subagent directory is
   `.opencode/agents/` (existing cards: `vision-agent.md`,
   `visual-design-agent.md`). All path references in this plan use the live
   path `.opencode/agents/email-ops.md`; the spec file has been corrected in
   place to match.
2. **Stale premise in Final-state item 3.** The spec sentence "The detailed
   tool workflows it previously carried live in the card body" assumed the
   `email-management` card carries gmail tool workflows. The live card carries
   `tb` (thunderbird-cli) workflows for a desktop-profile pathway and has never
   carried gmail tool-handling text. No gmail workflow relocation exists to
   perform; the gmail tool-handling instructions are new content authored into
   the email-ops card body (Final-state item 2). Spec corrected in place.

## SC validation (against spec/references/validation-standards.md)

All seven criteria PASS. Notes on the two judgment calls:

- **SC-6** is well-defined as a target state (description states recognition,
  email-ops dispatch, and the authorization gate; no direct gmail
  tool-workflow text) even though its motivating premise was stale — the
  criterion itself is traceable to the developer's description-text and
  mechanism statements, testable by frontmatter inspection, and unambiguous.
- **SC-7**'s "documented `opencode.db` query protocol" resolves concretely:
  first assistant message of a main-agent (parentless) session, filtered to
  model `huggingface/zai-org/GLM-5.3-Flash`, `tokens.input` from the message
  JSON. Reproduced against the live db on 2026-10-09: n=115 first-turn records
  for that model since 2026-03, median **21,946** — the spec's ~22.0K
  baseline. Threshold: the post-change fresh-session measurement must be
  ≤ 20,446.

## Items

### Item 1 — SC-4 (structural): deck config deny rule

- **Deliverable:** `.opencode/opencode.jsonc` gains a `permission` block
  containing the rule `"gmail_*": "deny"`. No `mcp` entry is added, removed,
  or modified (out-of-scope constraint).
- **RED:** config inspection of current `main` shows no `permission` block at
  all; the gmail tools are reachable in every main-agent session (observable
  directly: the live session toolset carries the `gmail_*` family).
- **GREEN:** add the `permission` block with the single rule.
- **Instrument:** direct config inspection of the implementation diff.
- **Note:** confirm the exact permission-rule syntax against the opencode
  config schema (customize-opencode card) before editing.

### Item 2 — SC-5 (structural): email-ops subagent card

- **Deliverable:** `.opencode/agents/email-ops.md` with frontmatter
  `mode: subagent`; description ≤ 30 words containing the trigger vocabulary
  (email, gmail, inbox, draft, send); explicit permission entry
  `"gmail_*": "allow"`; body carrying gmail tool-handling instructions (the
  `gmail_*` tool family: list accounts/mailboxes, list metadata, read
  content, download attachments, mark read, move, delete, save draft, send)
  and the email rules inherited from the email-management card: drafts
  default to a dry run, and every outward-facing send requires explicit
  developer instruction in the session.
- **RED:** the file does not exist; no subagent can hold `gmail_*` allow
  permissions.
- **GREEN:** create the card.
- **Instrument:** file inspection plus description word count.

### Item 3 — SC-6 (structural, governed): email-management description becomes the email router

- **Deliverable:** `email-management/SKILL.md` frontmatter description states
  email-intent recognition, dispatch to the email-ops subagent, and the
  outward-send authorization gate; no direct gmail tool-workflow text.
- **RED:** the current description routes email intent into direct in-agent
  mail handling and never mentions the email-ops dispatch.
- **GREEN:** rewrite the frontmatter description only; the card body's `tb`
  CLI workflows stay untouched (the card remains the desktop-profile
  pathway).
- **Instrument:** file inspection of the skill frontmatter.
- **Governed:** `skills/` edit — the skill-creator admission gate runs before
  the edit.

### Item 4 — Final-state item 4 (structural, governed): task-card email routing lines

- **Deliverable:** the `issues` and `spec` task cards each carry a line
  routing mid-task email actions through the email-ops dispatch (these flows
  were observed sending email mid-task in session history).
- **RED:** neither card contains any email-routing instruction.
- **GREEN:** add the routing line to each card.
- **Instrument:** file inspection of both cards.
- **Governed:** `skills/` edit — the skill-creator admission gate runs before
  the edit. No dedicated SC in the spec (recorded there as a process
  obligation of the change); the deliverable itself is a Final-state item and
  is verified structurally.

### Item 5 — SC-1 (behavioral): main-agent toolset excludes gmail_*

- **RED:** a fresh main-agent session under the deck config exposes tools
  whose names start with `gmail_` (current behavior, observable in the live
  session toolset).
- **GREEN:** after Item 1, a fresh main-agent session's toolset contains no
  `gmail_*` tools.
- **Instrument:** behavioral run under the behavioral-testing card; session
  evidence shows the session toolset.

### Item 6 — SC-2 (behavioral): email-ops session reads the mailbox without a permission prompt

- **RED:** no `email-ops` subagent exists to dispatch to.
- **GREEN:** after Item 2, a session dispatched to `email-ops` has `gmail_*`
  tools available and completes a mailbox read (for example
  `gmail_list_mailboxes`) with no ask/permission stall.
- **Instrument:** behavioral run; the transcript shows the tool call
  succeeding.

### Item 7 — SC-3 (behavioral): email intent routes to email-ops

- **RED:** an email-intent request to the main agent does not dispatch to
  `email-ops` (the agent does not exist pre-change).
- **GREEN:** after Items 2 and 3, a developer request involving email (for
  example "check my inbox for X") produces a transcript showing a task
  dispatch naming `email-ops`.
- **Instrument:** behavioral run with the trigger phrasing.

### Item 8 — SC-7 (behavioral): first-turn token reduction

- **RED:** first-turn `tokens.input` for a minimal-prompt main-agent session
  on `huggingface/zai-org/GLM-5.3-Flash` sits at the ~21.9K–22.0K baseline
  (reproduced from the live db, median 21,946).
- **GREEN:** after Items 1–3, a fresh minimal-prompt main-agent session
  measures ≤ 20,446 first-turn `tokens.input` (≥ 1,500 below the measured
  baseline).
- **Instrument:** the `opencode.db` query protocol — first assistant message
  of the fresh session, same model profile as the baseline.

## Dependency order

Item 1 → Item 5 (toolset change before toolset evidence). Item 2 → Items 6, 7
(the dispatch target must exist). Item 3 → Item 7 (the router description
drives the dispatch). Items 5–8 run only after their supporting structural
items (1–4) are in place; Item 8 measures the landed deck and runs last.

## Execution constraints

- Items 3 and 4 are governed deck edits: skill-creator admission gate first.
- Items 5–8 execute under the behavioral-testing card — the tests-v2
  harness provisions the runs; never an ad-hoc `opencode run`.
- All file changes happen in the `.opencode` submodule on a feature branch
  created per git-workflow-branch before the first modification. The parent
  repo carries only the submodule pointer, which rides with real parent-repo
  changes per pointer discipline.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
