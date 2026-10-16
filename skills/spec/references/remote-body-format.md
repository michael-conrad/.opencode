<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2622 (remediation of .opencode#2620); admission evidence: #2620 defect record, NewsRxUI#64 and ProcessFinishedNotify#36 owner verdicts, stranded-guide-verbiage finding -->

# remote-body-format — the remote issue body mandate

This reference defines what the remote issue body must contain. `spec`
and `issues` point here instead of carrying their own body-format rules;
the local store stays authoritative for full agent-ingest detail.

## Trigger rule

The body mandate binds to **every remote issue that has a matching
issues-data `{N}/` folder** in the repo's issue store, and to no remote
issue without one. Issues filed first gain the mandate at reconciliation,
when their folder comes to exist. The trigger is folder existence —
fact-decidable, no issue-type taxonomy.

## Sizing doctrine

The remote body is a **fuller but still exec summary-style** document —
self-sufficient, so a developer reading only the remote body can
understand and judge the spec or issue without opening the local store.
It is not a two-line pointer, and it is not a mirror of the local spec:
the full agent-ingest detail (exhaustive traceability, edge cases,
evidence) stays local-authoritative in `.issues/{N}/`.

## Universal minimum — every folder-backed filing

Every remote issue body backed by a `{N}/` folder carries:

1. **Problem** — what is wrong or missing and why it matters.
2. **Scope** — what the change requires.
3. **Requirements** — R-x SHALL statements.
4. **Impact** — consumers, risk, blast radius.

## Spec-filing extension

Spec filings add, on top of the universal minimum:

1. **Success criteria** — each classified behavioral or structural and
   each carrying a verification instrument (a check an agent can run —
   never prose recall).
2. **Success-criteria table** — ID / criterion / class / instrument.
3. **Out of scope** — named exclusions.
4. **Approach** — the chosen design path.
5. **Plan-shaped sections — required once a plan exists**: Items
   RED/GREEN, Dependencies, Traceability, Documentation Sources,
   Enforcement Gate, Cost Frame, Edge Cases, Not Included.

## Blockquote convention

Every folder-backed remote body closes with the blockquoted artifacts
link, present at filing and reconciled on every remote-body edit:

```
> Full spec and plan artifacts: <url>
```

- Build the URL with `local-issues url --number repo#N --artifacts`
  (emits `tree/issues-data/N/`). When the tool cannot produce it, derive
  the platform URL manually from the repo facts (ssh-to-https conversion
  of the origin, or the session-init repo table's url field) — the
  mandate never blocks on the tool.
- Adjacent to the closing blockquote, include the AI-facing
  relative-path artifacts pointer line naming `{issues_prefix}{N}/`.
- **No hardcoded file lists.** The remote body never enumerates the
  store's files — agents discover content by globbing
  `{issues_prefix}{N}/`. `{issues_prefix}` is the repo entry's `issues:`
  field, never a hardcoded value.

## Local `{N}/` record set

A folder-backed issue's store folder holds `spec.md` plus the
tool-managed record set — `issue.yaml`, `comments.yaml`, `links.yaml` —
and artifact subdirectories (plan, research, designs, audit as the work
produces them), consistent with the `local-issues-cli.md` store
semantics. `.issues/{N}/spec.md` remains the authoritative full spec;
the remote body is a structured summary of it.
