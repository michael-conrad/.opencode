---
name: correspondence
description: "Load when the agent decides where any agent-generated content goes — chat, the local issue store, an issue body, an issue comment, a pull-request body, a pull-request comment, a wiki page, a release note, or correspondence — and when drafting stakeholder content for any of those surfaces. The card owns the channel decision — which surface a piece of content belongs on — while the card that owns a surface owns that surface's form."
license: MIT
provenance: AI-authored, .opencode#2026; channel rule per .opencode#2662
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; channel rule per .opencode#2662 -->

# correspondence — the channel decision

## The channel rule

Each piece of agent-generated content goes to the surface this rule routes it
to. The agent applies the rule at the moment it decides where the content
goes — before it commits to publishing on any surface.

**Channel set.** The deck's surfaces divide into two sets.

Stakeholder surfaces — content the reader sees without the agent sitting
beside them:

1. an issue comment,
2. an issue body,
3. a pull-request comment,
4. a pull-request body,
5. a wiki page,
6. a release note,
7. correspondence.

Working surfaces — content that stays with the work:

1. chat — the live exchange between the agent and the developer,
2. the local issue store — the `issues-data` branch of the repository the
   work touches,
3. the artifacts under the issue's folder — the spec, the plan, and the
   other `{N}/` records the local store holds.

**Jurisdiction.** This card owns the channel decision — which surface a
piece of content belongs on. The card that owns a surface owns that
surface's form: the `git-workflow-pr` card owns the pull-request body's
form, the `issues` card and the deck's remote-body-format reference own the
issue body's form, the `release-promoter` card owns the release note's
composition, and `wiki-operations` owns the wiki page's form. The issue
tracker's labels and closure state are the `issues` card's surfaces, outside
this rule's scope.

**Stakeholder notice — the positive remote class.** Content goes to a
stakeholder surface only when it is a stakeholder notice: content whose
reader must take a specific action before the work can continue. The
qualifying kinds are: a decision the reader must act on, a scope change the
reader must act on, a finding — a specific, evidenced result the reader must
act on — and a status the reader must act on. The kinds outside this class
are the internal class named below; no content qualifies as a stakeholder
notice and falls in the internal class at once.

**Internal class — content that never reaches a stakeholder surface.** The
agent never chooses to publish, on a stakeholder surface, content of these
kinds:

- escalation reports,
- clarification requests,
- the agent's reasoning and analysis output,
- chat and session-transcript excerpts,
- pipeline state,
- progress narration ("working on it", "halfway done"),
- audit and verification verdicts.

The prohibition governs the content the agent chooses to publish on a
stakeholder surface. Content a surface's owning card mandates there is
outside the prohibition: the pull-request body's required `## Evidence`
section, which carries the fresh-context verify verdict, and the verdict the
`verify` card records in the pull-request description, are pull-request-body
content by mandate, not published working content.

**Default under uncertainty.** When classification is uncertain, the
content goes to a working surface. The asymmetry decides the tie: a
stakeholder notice can be added later, and published narration cannot be
withdrawn.

**Routes.** Each class of content has a route:

- Chat, for the live exchange — an escalation, a clarification request, a
  report to the developer.
- The local issue store, for the record — a working-content record goes
  through
  `.opencode/tools/local-issues comment --number <repo>#<N> --type internal`,
  and pipeline state goes through the
  `.opencode/tools/local-issues update --number <repo>#<N>` command's
  `--status` and `--phase` state fields. The store's comment type field is a
  record of the entry's kind — `internal` for working content, `stakeholder`
  for the record of a notice that was issued — not a publication channel.
- The artifacts under the issue's folder, for the durable trace.
- The artifact edited in place, for a correction — spec and plan content
  never moves to a comment.

**No read-back.** A tracker comment is never an answer, never an
authorization, and never a record the agent reads back.

**Class coverage.** Developer-directed content — an escalation, a
clarification request, a report to the developer, a consultation — reaches
the developer in chat, whichever card produces it. A card's own escalation
or halt rule names no channel of its own and takes this route.

**Pull-request surfaces.** A pull-request comment follows the same gate as
an issue comment. A pull-request body is a merge artifact whose form the
`git-workflow-pr` card owns, and it carries a notice by construction —
including the verify verdict its required `## Evidence` section carries,
which the internal class's prohibition does not reach.

## Stakeholder notice format

Stakeholder content is drafted deliberately or not at all. When the rule
qualifies content as a stakeholder notice, the notice itself
follows the disciplines below.

1. **Executive summary format.** Lead with the outcome; details follow in
   descending importance; active voice; no filler.
2. **Every URL verified** by the agent before it appears in the notice — a
   dead or fabricated link in a stakeholder notice is a credibility defect.
3. **Honest status.** Blockers and risks are stated plainly by the agent; a
   rosy-but-wrong status update is worse than an uncomfortable truth.
4. **Identity byline** on sent correspondence, applied by the agent per
   attribution rules.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)