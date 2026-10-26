# Tera template-context reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), references/tera-template-context.md; .opencode#2666 R-3 Tera-v1 targeting, R-6 Read-links -->

Read this only when diagnosing a Tera template/rendering failure or reviewing
escaping or undefined-variable behavior in an existing Zola site's templates.
It supports interpreting the construct actually observed; it does not list
every Tera feature or teach theme authoring.

Semantics below are Tera v1 as served by the Zola 0.22.x line (deck default).
Zola ≥ 0.23 pairs with Tera v2 (as of 2026-10-24); construct behavior there is
version-dependent — recheck against live docs before relying on anything below
for such a pin.

## Interpret the observed construct

1. Recognize the three Tera delimiters: `{{ ... }}` renders an expression,
   `{% ... %}` is a statement or logic tag, and `{# ... #}` is a comment that
   produces no output. Text inside a `{% raw %}` block is emitted verbatim and
   is not rendered.
2. Distinguish a template error from a content error by reading the diagnostic.
   Tera reports the template/file and line; undefined-variable and filter-type
   failures name the expression. Do not edit a content file to fix a template
   diagnostic, or the reverse.
3. Before changing behavior, print the context with `{{ __tera_context }}` in
   the affected template to see exactly which variables are available to it,
   then remove that marker before build.

## Honor auto-escaping and `safe`

Tera v1 auto-escapes `.html`, `.htm`, and `.xml` templates; it does no
contextual escaping, so an unescaped value in an attribute or a script context
is not detected automatically. `safe` marks an expression as already-safe HTML
and is honored only when it is the last filter in the expression, so order
matters. Review every `| safe` use by its provenance: rendered Zola Markdown is
not the same as a configuration, data, or arbitrary value. Do not add `safe` to
suppress a rendering problem.

## Account for undefined and missing values

Accessing or rendering an undefined variable is an error, and a missing field
on a defined variable is also an error. Undefined variables are falsy in
`{% if %}` tests, so the standard presence test is
`{% if var %} ... {% else %} ... {% endif %}`. Tera has no built-in way to
render a template while ignoring missing variables, so a `{{ var }}` that must
be optional needs an explicit fallback such as
`{{ var | default(value="default") }}` or an `if` branch.

## Source boundary

Use the Tera row and the Zola template-overview row in Read [the
source-registries reference](source-registry.md), plus the relevant
template/page/section rows, for the constructs the workflows actually
exercise. Recheck them when the installed Zola version differs from the
version a row was verified against, and do not claim a Tera feature that is
not present in those sources.

## Related references

- Read [the modify/review reference](modify-review.md) for `| safe`
  provenance review and the finding format during template work.
- Read [the debug-build reference](debug-build.md) when a Tera diagnostic
  requires separating template errors from content or configuration errors.
- Read [the theme-override reference](theme-override.md) when interpreting a
  theme's `block`/`extends` or escaping in a bounded override.