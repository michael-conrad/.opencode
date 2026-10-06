<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#169; sourced from .opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md Appendix D -->

# Publish discipline (detail card)

## Direct-publish means verify-before-push

A wiki push bypasses every review mechanism — no branch, no PR, no hook can
gate it. The review substitute happens **before** `git push`:

1. **Diff review** — read the actual `git diff` of everything staged for the
   push. Confirm every hunk is intended and scoped to the task.
2. **Rule-based checks** (from the layout-and-syntax card):
   - `[[...]]` targets resolve to real pages (no orphans, no broken links);
   - `_Sidebar.md`/`_Footer.md` updated or intentionally untouched;
   - no bare `---` frontmatter blocks (render as a horizontal rule on GitHub);
   - GitBucket sidebars contain only `[[...]]` or absolute links (gitbucket#2629);
   - rendering format matches the file extension actually used.

## Local preview — opportunistic, never a blocker

The official gollum Docker image approximates the render:

```
docker run --rm -p 4567:4567 -v "<wiki-checkout>":/wiki gollumwiki/gollum
# → http://localhost:4567
```

- Pin a version tag (e.g. `:6.1.0`) — the image ships no `latest` by design.
- Use it only when Docker is available; its absence never blocks a verified
  push.
- The approximation validates **structure, links, and sidebar/footer
  behavior** — gollum↔GitHub divergence is officially acknowledged (macros,
  transclusion, `[[_TOC_]]`, sanitization/emoji/autolink post-processing,
  kramdown-vs-commonmarker engine differences). The live page remains the
  final look.
- For GitBucket, the faithful local render is GitBucket itself
  (`java -jar gitbucket.war`, Java 17); gollum remains the structural
  approximation.

## After push

The pushed state is live immediately. If a defect slips through, fix forward
with a follow-up commit — never force-push, never rewrite published history.
