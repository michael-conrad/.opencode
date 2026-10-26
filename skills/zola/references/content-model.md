# Content-model reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), references/content-model.md; .opencode#2666 R-2/R-6 adaptations -->

Read this only for an existing-site change involving content files, front
matter, routes, or co-located assets. Preserve the current content model; do
not use it to introduce a blog, search, feeds, a taxonomy, or a new
information architecture without an explicit request.

## Inspect before changing structure

1. Map the affected `content/` directory, its nearest `_index.md`, existing
   page/section templates, generated links, and any translated variants.
2. Treat `_index.md` as section content and metadata. Treat `index.md` as a
   page at its directory path; other Markdown files are pages at their file
   paths unless front matter changes the route.
3. Inspect `slug`, `path`, aliases, section sorting, and template settings
   before changing a filename or front matter. A page `path` overrides both its
   `slug` and the section-derived path, so it can change more than the filename
   suggests.

## Make the smallest route-preserving change

- Keep the existing page-versus-section role unless the request names a
  structural change. Do not replace `_index.md` with `index.md`, or the
  reverse, solely to make a route appear.
- For a page that needs co-located assets, use a dedicated directory with
  `index.md`; inspect existing relative asset links before moving it. Do not
  relocate unrelated content or assets.
- Preserve active language files, configured section behavior, generated URLs,
  and existing aliases. Propose a redirect/alias change only when the requested
  route move and the site's existing redirect policy justify it.

## Validate the requested result

Run the project's safe `zola check` and isolated `zola build` arrangement, then
inspect the affected generated route, links, and copied assets. State if
external Markdown-link checking was skipped. For a route or structure change,
report the old and new observed paths and any remaining redirect or translation
assumption.

## Authorship and AI-assistance disclosures

Treat authorship, provider, and AI-assistance fields as site-specific content
policy. Inspect comparable pages and documented conventions before preserving
or adding one. Record only a factual disclosure explicitly supplied by the
developer or already established by the repository; agent use alone does not
establish a disclosure, author, provider, date, or license. Preserve the
existing front-matter shape and validate the rendered page after the change.

## Source boundary

Use the content overview, page, and section rows in Read [the
source-registries reference](source-registry.md). Recheck them when the
installed Zola version differs from the verified version.

## Related review references

- Read [the modify/review reference](modify-review.md) for content-structure,
  front-matter, and route changes affecting generated output.
- Read [the release-review reference](release-review.md) when content-model
  changes affect a pre-release review scope.
- Read [the editorial-review reference](editorial-review.md) when content
  changes involve article-quality considerations or authorship disclosures.