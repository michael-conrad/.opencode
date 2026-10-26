# Theme-override reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), workflows/theme-override.md; .opencode#2666 R-6 Read-links -->

Use this workflow for a bounded override of a template block in a theme
already configured in a local Zola site, or for a review of that
relationship. Do not use it to select or install a third-party theme, copy a
theme example configuration, or author a complete theme.

## Inspect before changing

- Identify whether the request is a modification or review-only. Do not change
  files during a review-only request.
- Read the host `zola.toml` or `config.toml`, including the top-level `theme`
  value; the installed `themes/<theme>/theme.toml`; the exact upstream template
  and its named blocks; any existing host override; content rendered through
  that template; and output handling.
- Record the installed Zola version and the theme's revision/submodule state
  when available. A theme manifest's minimum version is not compatibility
  proof.
- Read [the source-registries reference](source-registry.md) theme
  installation/creation entries for Zola behavior. Treat the installed theme's
  templates and documentation as project evidence, not a reason to copy
  unrelated settings or tooling.

## Bounded override

Make the smallest host-side template change that overrides a verified named
block. Extend the installed template by its actual theme-qualified path; keep
the configured theme, `base_url`, content model, escaping, and the theme files
unchanged. Copy only a setting the observed template requires. When
interpreting the theme's `block`/`extends` or escaping, Read [the Tera
template-context reference](tera-template-context.md).

Do not replace the host configuration with an example file, add a CSS build
toolchain or browser JavaScript, or claim that the theme is generally
compatible beyond the checked version/revision.

## Validate

Run `zola check --skip-external-links`, then `zola build --output-dir
<fresh-dir>`. Inspect the affected generated page for both the overridden
output and an existing host behavior, such as a generated URL. State that the
first command skips external Markdown-link checking. For review-only work,
report findings as `severity | path | evidence | impact | remediation |
validation` without applying a patch.