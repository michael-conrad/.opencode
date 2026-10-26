---
name: zola
description: "Load when working in a Zola static-site repository — creating a minimal Zola site, authoring or editing a post, modifying or reviewing an existing site's content, templates, or configuration, diagnosing a Zola/Tera build, layout, template, configuration, or static multilingual (i18n) failure, overriding one bounded theme template, or running a bounded accessibility, editorial-quality, or pre-release review of a Zola site. Also load before any Zola/Tera file edit, however small, and when any Zola/Tera build, serve, or template behavior fails. Not for general writing, CMS work, backend code, SEO, or full theme authoring; never for deployment or publishing (site publish happens through CI after a human merge)."
license: MIT
provenance: adapted-from upstream CodeSigils/zola-skill, MIT, pinned v1.0.0 (commit 6b279b3), .opencode#2666
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: adapted from CodeSigils/zola-skill (MIT, https://github.com/CodeSigils/zola-skill), pinned v1.0.0 commit 6b279b3; deck adaptation .opencode#2666 — R-2 description rewritten in deck router dialect, R-3 semantics retargeted to the Zola 0.22.x/Tera-v1 line, R-4 deployment surface removed, R-5 root-agnostic scrub, R-6 Read-link conformance; upstream workflows tier merged one level deep into references/ -->

# Zola

Use this skill for minimal site creation, build/template diagnosis, static
multilingual work, post authoring, existing-site modification/review, and
bounded existing-theme template override — always for a Zola site already or
newly targeted by the developer's request. The deck's own workflow rules
(`implement`, `git-workflow-*`, `verify`) govern how changes, validation, and
PR boundaries happen; this card contributes only Zola-specific method.

The card is adapted for the Zola 0.22.x line with Tera v1 templates as default
semantics (the live pinned Zola in the consuming root is authoritative — check
its version first). Behavior introduced in Zola ≥ 0.23 is named only as
version-dependent with explicit as-of dating. Read [the source-registries
reference](references/source-registry.md) before relying on any
version-sensitive behavior.

## Diagnose first

1. Classify the request before touching files: diagnosis-only requests get a
   proposed patch, never an applied one; change requests get a minimal patch.
   Preserve auto-escaping: `safe` is not a generic fix.
2. Inspect the error and the repository evidence: `zola.toml` (or legacy
   `config.toml`), the involved templates/content, the theme relationship,
   existing validation commands, and the configured `output_dir`.
3. Run `zola --version`. If it is unavailable or differs from the version the
   reference content assumed, state that limitation and do not claim
   unverified version-specific behavior.
4. Read the matching reference:

   - Read [the minimal-site creation reference](references/create-site.md)
     for creating a new minimal site.
   - Read [the debug-build reference](references/debug-build.md) for a build,
     rendering, template, or configuration failure.
   - Read [the static-i18n reference](references/i18n.md) for language
     configuration, translated content, or language-aware URL failures.
   - Read [the post-authoring reference](references/author-post.md) for
     drafting or editing an explicit post.
   - Read [the modify/review reference](references/modify-review.md) for an
     existing-site change or review.
   - Read [the theme-override reference](references/theme-override.md) for one
     bounded template override in an installed theme.
   - Read [the content-model reference](references/content-model.md) for
     content-structure, front-matter, route, or co-located asset changes.
   - Read [the Tera template-context reference](references/tera-template-context.md)
     when interpreting a Tera construct, auto-escaping, or an
     undefined/missing variable.
   - Read [the editorial-review reference](references/editorial-review.md) for
     an explicitly requested article-quality review.
   - Read [the accessibility-review reference](references/accessibility-review.md)
     for a template/content accessibility review.
   - Read [the release-review reference](references/release-review.md) for an
     explicitly requested pre-release review.

5. Report the likely cause, concrete evidence, smallest safe repair, competing
   hypothesis where relevant, and the exact validation commands.

## Validation rules

Before any build, inspect project output handling; do not add `--force` by
default, and use `--output-dir` with a fresh empty directory for isolated or
fixture-like runs. Validate with `zola check --skip-external-links` and
`zola build`; state that the former omits external Markdown-link coverage.
Run a rendered-page smoke check for template changes when the repository makes
one feasible.

Preserve escaping: `safe` marks an expression as already-safe HTML — inspect
its provenance before recommending or adding it.

The workflow ends at the validated change report or the review-boundary
handoff the deck's own pipeline prescribes; publishing is never part of this
card — if asked to deploy, publish, or integrate a hosting provider, say that
mode is not implemented and stop at the build-validated deliverable.

## Refusal boundary

If invoked for theme selection, full theme authoring, automatic translation,
browser locale detection, search indexing, generic writing, CMS work, or
deployment/publishing, say that mode is not implemented; do not substitute
generic advice.