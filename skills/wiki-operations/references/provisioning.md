<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#169; sourced from .opencode#169 spec Rev 3 (developer direction, 2026-10-06 design discussion) -->

# Checkout provisioning & currency (detail card)

## Default arrangement: ignored sub-repo

A wiki checkout is a **foreign clone of `<derived>.wiki.git` at a deterministic
fixed in-tree path, gitignored** — never registered as a submodule.
`git submodule add` against a wiki is forbidden. The ignore entry **exists
before the clone lands** so the clone never shows up as untracked noise or gets
committed by accident.

## Lazy provisioning — detection ladder

Provision only when a wiki operation is actually needed and no checkout exists.
Walk the ladder in order and stop at the first hit:

1. **Inherited submodule** — a `.gitmodules` entry already wires the wiki:
   operate it in place (below).
2. **Existing sub-repo** — a checkout already sits at the known path: use it.
3. **Probe availability** — does a wiki exist at all? (`gh api repos/{owner}/{repo}`
   → `has_wiki`; `gb` equivalent.) No wiki and none requested → stand down.
4. **Provision** — add the ignore entry, clone `<derived>.wiki.git` to the
   fixed path.
5. **Stand down** — no wiki exists and none is requested: do nothing; do not
   create wikis speculatively.

The sub-repo is **kept after use** — cleaning it up guarantees you must
re-provision and re-sync next time and throws away local context.

## Checkout currency

- **Sync before edit.** Pull before any page change; resolve conflicts against
  the remote tip. The remote is the rendered state of record.
- **Commit and push immediately after editing.** A dirty wiki checkout is a
  stale-publish hazard: the next agent or human to touch it publishes your
  half-done work or collides with it.
- **Never force-push** a wiki.
- **Never discard remote edits wholesale.** Human web-UI edits are likely;
  `git reset --hard`/checkout-away of the remote tip destroys real content.
  Adapt remote changes under the maintainer-posture rules
  ([maintainer-posture.md](maintainer-posture.md)).

## Inherited submodule wikis

If `.gitmodules` already maps a wiki path, operate that submodule in place
under the same currency rules above. It is **observed state**: never created,
never converted, never removed as a side effect of other work. Conversion to
the ignored sub-repo arrangement is a directed remediation —
[remediation-submodule-to-subrepo.md](remediation-submodule-to-subrepo.md).
