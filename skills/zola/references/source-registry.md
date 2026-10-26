# Source-registries reference

<!-- Provenance: adapted from CodeSigils/zola-skill v1.0.0 (6b279b3), references/source-registry.md; .opencode#2666 R-3 version-targeting: verification columns retained per row with as-of dating; deck default target is the Zola 0.22.x line -->

Consult only the row needed for the active workflow. These sources support the
implemented Zola workflows; they are not a copied reference manual.

**Version targeting.** Each row records the Zola/Tera version the row's
behavior was verified against, with its verification date. The deck's default
semantics are the **Zola 0.22.x line with Tera v1** (the live consumption
target) — recheck a row against the version of `zola --version` in the consuming
site before relying on version-sensitive behavior. Rows verified on 0.23.4
were checked on the upstream line (as of the dated column) — behavior on 0.22.x
may differ; recheck against the matching live Zola version's documentation.
Zola ≥ 0.23 (currently 0.23.6, as of 2026-10-24) pairs with Tera v2 template
semantics; template-construct behavior there is version-dependent and must be
rechecked against live docs rather than assumed from Tera-v1 defaults.

| URL | Topic | Verified Zola | Verified date | Caveat |
| --- | --- | --- | --- | --- |
| https://www.getzola.org/documentation/getting-started/cli-usage/ | `init`, `check`, and `build`; `--output-dir` and `--force` semantics | 0.23.4 | 2026-09-10 | `init` prompts for initial choices; never `--force` an existing non-empty target without surfacing it to the developer. `check` fetches external Markdown links unless `--skip-external-links` is supplied. Recheck for other pins. |
| https://www.getzola.org/documentation/getting-started/configuration/ | `zola.toml`, legacy `config.toml` fallback, `base_url`, and `output_dir` | 0.23.4 | 2026-09-02 | Configuration options are version-sensitive; inspect the project's file before changing it. |
| https://www.getzola.org/documentation/content/overview/ | Content directory structure, `_index.md` sections, routes, and co-located assets | 0.23.4 | 2026-09-03 | `index.md` is a page while `_index.md` is a section; use a dedicated page directory for co-located assets. |
| https://www.getzola.org/documentation/content/page/ | Page filenames, `index.md`, `slug`, `path`, aliases, and front matter | 0.23.4 | 2026-09-03 | A page `path` overrides both `slug` and the section-derived path; inspect existing generated links before changing it. |
| https://www.getzola.org/documentation/content/section/ | Section `_index.md`, inherited page settings, sorting, and front matter | 0.23.4 | 2026-09-03 | Section settings can affect direct pages; preserve them unless the requested change requires an evidenced update. |
| https://www.getzola.org/documentation/content/linking/ | Markdown internal-link checking, `@/` links, and `link_checker.internal_level` | 0.23.4 | 2026-09-03 | Broken internal Markdown links are errors by default; lowering the level to `warn` can leave a broken link in generated output. |
| https://docs.rs/tera/1.20.0/tera/ | Tera v1 syntax, auto-escaping, `safe`, and error interpretation | Tera v1 | 2026-09-03 | `.html`, `.htm`, and `.xml` templates auto-escape by default (Tera v1); `safe` marks an expression unescaped, so inspect provenance before recommending it. The historical guide URL `keats.github.io/tera/docs` returns 404 (checked 2026-10-26) — docs.rs is the v1 source. Zola ≥ 0.23 pairs with Tera v2 (current 2.4.0, as of 2026-10-26) — recheck escaping/filter semantics there against `https://docs.rs/tera`. |
| https://www.w3.org/WAI/tutorials/page-structure/ | WAI page regions, meaningful elements, and logical heading structure | N/A | 2026-09-03 | Use for source/output observations only; it does not establish WCAG conformance or prescribe ARIA where semantic HTML suffices. |
| https://www.w3.org/WAI/tutorials/images/ | Purpose-based text alternatives for informative, decorative, and functional images | N/A | 2026-09-03 | Alternative text depends on the image's purpose in its rendered context; do not infer an alt text without inspecting it. |
| https://www.w3.org/TR/WCAG22/ | Text alternatives, time-based media, keyboard, visual presentation, and conformance terminology | N/A | 2026-09-09 | Use as a review baseline; a Zola build or static inspection does not certify WCAG conformance. |
| https://www.w3.org/WAI/media/av/ | Captions, transcripts, audio description, and accessible media players | N/A | 2026-09-09 | Apply according to media type and whether it is prerecorded or live; report provider and testing limits. |
| https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/ | Accessible names and preference for native semantics before ARIA | N/A | 2026-09-09 | Use ARIA only when native HTML or visible text cannot provide the required name. |
| https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-in-context.html | Link purpose from link text or programmatically determined context | N/A | 2026-09-03 | A short link is not necessarily a defect when directly associated context supplies its purpose. |
| https://www.getzola.org/documentation/content/multilingual/ | Language tables, translated filenames and routes, and translated-section index requirement | 0.23.4 | 2026-09-02 | A translated content language must be configured; a translated section has no fallback from `_index.md`. |
| https://www.getzola.org/documentation/templates/overview/ | Active `lang`, `trans`, and language-aware `get_url` | 0.23.4 | 2026-09-02 | Use the active language or an explicit configured code; generated URLs retain the configured `base_url`. |
| https://www.getzola.org/documentation/themes/installing-and-using-themes/ | Theme directory naming, top-level `theme` configuration, and theme-specific setup | 0.23.4 | 2026-09-02 | Inspect the installed theme's manifest and documentation; do not copy an example configuration wholesale. |
| https://www.getzola.org/documentation/themes/creating-a-theme/ | `theme.toml`, a buildable default site, and Tera blocks for customization | 0.23.4 | 2026-09-02 | A declared minimum version does not replace validation against the installed Zola version and selected theme revision. |
| https://www.getzola.org/documentation/content/taxonomies/ | Top-level taxonomy configuration, content terms, rendered term routes, and term pagination | 0.23.4 | 2026-09-03 | Taxonomy names must match content front matter; a configured `paginate_by` affects individual term pages. |
| https://www.getzola.org/documentation/templates/pagination/ | `paginator` context for paginated taxonomy terms and pager URLs | 0.23.4 | 2026-09-03 | `paginator` is undefined unless `paginate_by` is positive; inspect the relevant taxonomy term template. |