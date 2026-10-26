# Modify/review reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), workflows/modify-review.md; .opencode#2666 R-4 deployment removal, R-6 Read-links -->

Use this workflow for a small content/template/configuration change to an
existing Zola site, or a review of it. Do not use it to create a site, choose
a theme, or redesign a project.

## Inspect before changing

- Identify whether the request is a modification or review-only. Do not change
  files during a review-only request.
- Read the relevant `zola.toml` or `config.toml`, the affected content and
  templates, their extends/includes and theme relationship, existing commands,
  and output handling. Check `zola --version`.
- Preserve the project's architecture and content model. Read [the
  source-registries reference](source-registry.md) before relying on
  version-sensitive configuration, template, URL, or i18n behavior.

## Modification

Make the smallest change that satisfies the stated request. Keep generated URLs
through Zola helpers when a link points to content; preserve `base_url`, active
language behavior, and auto-escaping. Do not add a framework, browser runtime,
or unrelated reorganization.

For a content-structure, front-matter, route, or co-located asset change,
Read [the content-model reference](content-model.md) before changing a
filename, `_index.md`, `index.md`, `slug`, or `path`.

For an explicitly requested taxonomy or pagination change, verify the taxonomy
is declared at the top level of the host configuration, then inspect the
affected content front matter and taxonomy template. A taxonomy term has a
`paginator` only when its configured `paginate_by` is positive; do not add
search, feeds, or a new content model unless requested.

For a review of `| safe`, distinguish rendered Zola Markdown from arbitrary
configuration or data. When interpreting auto-escaping or an
undefined/missing variable, Read [the Tera template-context
reference](tera-template-context.md). Flag an unescaped `config.extra` or data
value unless its trusted-HTML provenance and need are explicit. Report the
expression and source as evidence; recommend removing `safe` or using a
deliberately vetted rendering path. Do not label every existing
`page.content | safe` use unsafe or claim a general security audit from one
template finding.

Validate with `zola check --skip-external-links`, an isolated `zola build`, and
an inspection of the affected generated page. State that external
Markdown-link coverage was skipped. Respect existing project commands and never
add `--force` by default. For an explicitly requested pre-release review, Read
[the release-review reference](release-review.md); it does not turn a template
review into a deployment, accessibility-compliance, or full security audit.
For an explicitly requested accessibility review of existing templates, Read
[the accessibility-review reference](accessibility-review.md) and report only
evidence visible in source or generated output.

## Review-only output

Report each finding as:

`severity | path | evidence | impact | remediation | validation`

Use `blocker` for a failure that prevents a required build or route, `warning`
for a concrete correctness/maintainability risk, and `note` for a bounded
improvement. Tie every finding to repository evidence; distinguish a verified
defect from an assumption. Include passing checks and remaining limits, but do
not claim a modification was made.