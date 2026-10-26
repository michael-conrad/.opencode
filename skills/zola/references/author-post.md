# Post-authoring reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), workflows/author-post.md; .opencode#2666 R-2/R-4/R-5 adaptations -->

Read this only for an explicit request to draft, edit, or prepare a post in an
existing Zola repository. It is not a general writing, CMS, SEO, or publishing
workflow.

## Inspect conventions before writing

1. Confirm the target content root, requested page, and whether the request
   asks for a draft or an edit. Inspect `.gitmodules`, symlinks, and the
   resolved content/configuration paths before assuming the repository root
   owns the content.
2. Inspect comparable pages and their section `_index.md`, front matter,
   taxonomy values, language files, route-affecting fields, assets, shortcodes,
   draft convention, templates, and existing validation commands.
3. Preserve observed conventions. Ask for missing title, audience, facts,
   sources, disclosure, date, or publication intent rather than inventing
   metadata, citations, authorship, AI-use claims, licenses, or taxonomy terms.

## Make the bounded change

- Create or edit only the requested content and directly required local
  assets. Preserve the page/section role, route, aliases, translations, and
  established front-matter shape unless the request requires otherwise.
- Use a current timestamp only when the repository convention and request call
  for one; obtain it from the environment rather than guessing it. Do not set
  `published`, author, or disclosure fields without an explicit factual basis.
- Apply repository-specific editorial rules only after locating them. For an
  explicit article-quality review, Read [the editorial-review
  reference](editorial-review.md).
- Do not create branches, commit, push, or open a pull request under this
  card's own rules — the deck's `git-workflow-*` cards govern that surface.
  Report a validated, focused `git diff` as ready for the developer's pipeline.
  Publishing/deploying is not a mode of this card (R refusal in
  [the router](../SKILL.md)).

## Validate and report

Run the smallest safe project validation, normally `zola check
--skip-external-links` followed by an isolated `zola build`. Inspect the changed
generated route, generated links, and copied assets. State whether external
link coverage was skipped and report the exact metadata and assumptions that
remain developer-supplied.