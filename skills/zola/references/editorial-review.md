# Editorial-review reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), references/editorial-review.md; .opencode#2666 R-2/R-6 adaptations -->

Read this only for an explicit review of article quality in an existing Zola
site. It does not establish correctness, SEO performance, legal clearance, or
a house style that the repository does not contain.

## Inspect evidence and local rules

Read the requested page, its front matter, its rendered route where available,
and the repository's documented editorial conventions. Check that material
factual claims have supplied, attributable support or are clearly qualified;
that linked source URLs point to the cited resource; and that stated authorship
or AI-assistance disclosures are factual, explicit, and consistent with local
conventions.

Review readability through concrete observations: ambiguous references,
overlong or overloaded sentences, unexplained terms, mismatched headings, and
links whose purpose is unclear in surrounding prose. Apply a language, tone,
voice, SEO formula, rhetorical quota, or shortcode rule only when the target
repository documents it.

## Related review references

- Read [the modify/review reference](modify-review.md) for the required
  finding format.
- Read [the accessibility-review reference](accessibility-review.md) when
  review scope includes template accessibility alongside content.
- Read [the release-review reference](release-review.md) when content review
  accompanies a pre-release static-site review.

## Report bounded findings

Report each finding as:

`severity | path | evidence | impact | remediation | validation`

Use `blocker` for a factual error, unsupported claim, or broken content link;
`warning` for a readability or citation risk; and `note` for a bounded
improvement. Mark a claim as unverified when its source cannot be checked; do
not invent a source or rewrite an opinion as fact. Tie every finding to
repository evidence. Include passing checks and remaining limits, but do not
modify content during a review-only request. For an authorized revision,
preserve the article's observed front-matter and route unless the request
explicitly changes them.