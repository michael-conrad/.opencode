# Accessibility-review reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), references/accessibility-review.md; .opencode#2666 R-2/R-6 adaptations -->

Read this for an accessibility review of an existing Zola site's content,
templates, generated pages, media, CSS, or theme overrides. It supports
concrete static findings; it does not establish WCAG conformance, test
assistive technology, or authorize a redesign.

## Inspect source and generated output

1. Inspect the source and rendered pages in scope. Identify meaningful page
   regions using semantic elements where the page has navigation, main content,
   headers, or footers; do not add ARIA roles without a repository-specific
   need.
2. Check that headings describe the page's organization and follow a logical
   hierarchy. Report a skipped level only when the rendered structure makes the
   section relationship unclear.
3. Check each changed or in-scope image by purpose: informative images need a
   concise alternative that conveys essential information, decorative images
   need `alt=""`, and an image functioning as a link or button needs an
   alternative that describes that action.
4. Check that each in-scope link communicates its destination or action through
   its text or directly associated context. Do not call a short link defective
   when the rendered context demonstrably supplies its purpose.
5. For video/audio/iframes, check a descriptive iframe title, controls,
   captions, transcripts or equivalent alternatives, and a fallback when an
   external provider is unavailable. For CSS/theme changes, inspect focus,
   contrast, zoom/reflow, color independence, and reduced-motion behavior when
   the evidence permits.

## Report limits precisely

Use the review finding format from Read [the modify/review
reference](modify-review.md). Include the rendered path and exact markup as
evidence, plus the validation used after a repair. State which of keyboard
behavior, focus treatment, contrast, responsive layout, media alternatives,
assistive-technology behavior, and conformance level were not assessed unless
the request and evidence specifically cover them.

## Source boundary

Use the W3C WAI and WCAG rows in Read [the source-registries
reference](source-registry.md). Prefer native HTML and visible names before
ARIA; these sources support bounded checks, not a universal ARIA pattern or a
compliance certification.

Accessible structure and useful text alternatives can also improve
discoverability and user experience, but accessibility review is not an SEO
audit and must not be reduced to keyword or ranking advice.

## Related review references

- Read [the modify/review reference](modify-review.md) for the required
  finding format.
- Read [the release-review reference](release-review.md) when a template
  accessibility review accompanies a pre-release review.
- Read [the editorial-review reference](editorial-review.md) when review scope
  includes rendered article content alongside templates.