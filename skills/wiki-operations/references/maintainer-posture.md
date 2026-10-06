<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#169; sourced from .opencode#169 spec Rev 3 (developer direction, 2026-10-06 design discussion) -->

# Maintainer posture (detail card)

The agent is the **primary maintainer** of any wiki it manages. That ownership
is bounded and asymmetric:

## What the agent owns

- **Styling and semantic structuring** — page organization, sidebar/footer
  structure, naming consistency, link hygiene, format correctness. Improve and
  normalize these within the footprint of the task being performed.

## What humans own

- **Content intent.** When a human has edited a page (web-UI edits are likely —
  check the log before editing), *adapt* means integrate-and-normalize: fold
  their change into the structure you maintain. **Never revert human meaning.**
  If a human edit conflicts with structure you would impose, the human's
  content wins and the structure adapts around it.

## Responsive only

Structure is maintained **within the footprint of the task being performed**.
While editing page X, normalizing X's links and its sidebar entry is in scope.
Structural debt elsewhere in the wiki is **not searched for** — no proactive
audits, no drive-by restructuring of unrelated pages. Debt encountered
incidentally can be noted, but the task's footprint bounds the edit.
