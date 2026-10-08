<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557 — SC-15 currency-pass record; live-source research dispatch, session 2026-10-07 -->

# Currency Pass — Restored Recommended-Packages Table (.opencode#2557 SC-15)

Verification date: **2026-10-07** (all fetches live this session). Source table:
`.opencode#2249` three-tier recommended-packages table as preserved in
`attic/guidelines/082-python-standards.md` §Dependency Injection (generic mandate).

Method: scoped research dispatch; primary sources (PyPI, official docs, GitHub
releases) fetched and read; contested rows cross-checked. Search snippets never
trusted without page fetch. Gaps listed at the end.

## Per-row verdicts

| # | Ecosystem | `#2249` tier | Verdict | Current packages / notes | Sources (fetched 2026-10-07) |
|---|---|---|---|---|---|
| 1 | Python | Clear standard | confirmed | `dependency-injector` (container-based). Framework-native DI (FastAPI `Depends`) covers framework-internal wiring; `dependency-injector` remains the recommendation for container-style DI across frameworks. | pypi.org/project/dependency-injector; github.com/ets-labs/python-dependency-injector/releases |
| 2 | C#/.NET | Clear standard | confirmed | Built-in `Microsoft.Extensions.DependencyInjection`. | learn.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection (notes .NET 10 current) |
| 3 | Java | Clear standard | **corrected** | Was: "Spring; Dagger for GWT-style". The GWT phrase is mangled drift: GWT's historical DI was **Gin** (GWT INjection, a Guice subset) — officially deprecated, "not actively developed anymore and not recommended for new projects" (Vue GWT docs); Dagger 2 succeeded it in GWT-land (2017 migration articles). Current mainstream trio: **Spring / Guice / Dagger 2** (Spring 7.0.x current; Dagger 2.60.1 Jul 2026; Guice 7.0.0 stable/slow). GWT is niche in 2026 — at most a legacy footnote. | spring.io blog 2026-06-08; github.com/google/dagger/releases; github.com/google/guice/releases; vuegwt.github.io DI guide; g-widgets.com 2017-06-28; github.com/gwtplus/google-gin |
| 4 | Angular/Vue/Svelte | Clear standard | confirmed (phrasing precision) | Angular: built-in DI framework (angular.dev/guide/di). Vue/Svelte are NOT containers: Vue provide/inject; Svelte 5 Context API (`createContext`). Table should say "provide-inject / context pattern" so readers don't expect a container. | angular.dev/guide/di; vuejs.org provide-inject guide + API; svelte.dev/docs/svelte/context |
| 5 | Kotlin | Contested | confirmed | Koin 4.2 (runtime, Kotlin-Multiplatform, new compiler plugin for build-time graph checks) vs Hilt (Dagger-based, official Android guides) vs raw Dagger 2. No consolidation — split hardened along KMP (Koin) vs Android-official (Hilt) lines. | insert-koin.io/docs/intro/koin-vs-hilt/; pistack.xyz 2026-08-27 |
| 6 | Scala | Contested | confirmed (nuance) | MacWire 2.6.7 (compile-time, Scala 3, Sep 2025) / Guice (Play default) / ZIO's **built-in** ZLayer — ZIO's DI story is now "no external framework needed" (zio.dev DI reference). | github.com/softwaremill/macwire; zio.dev/reference/di/* |
| 7 | Dart/Flutter | Contested | confirmed (currency shift) | get_it 9.3.0 (Sep 2026, most popular pure service locator) / Riverpod 3.x (3.0 Sep 2025; 3.3.2 Jun 2026 — common recommendation for new apps) / provider 6.1.5+1 (Sep 2025, legacy/official-docs option). | pub.dev/packages/get_it; pub.dev/packages/provider; riverpod.dev |
| 8 | TypeScript | Contested | confirmed | tsyringe (Microsoft, 4.10.0 ~late 2025, maintained but slow) / InversifyJS (full-featured) / TypeDI; both majors still require experimentalDecorators/reflect-metadata — TS 5.x standard decorators keep the ecosystem unsettled, which is why it stays Contested. | npmjs.com/package/tsyringe; inversify.io; pistack.xyz 2026-07-21 |
| 9 | Go | Guidance-only | confirmed (strengthened) | Manual constructor injection idiomatic; opt-in: Uber Fx/dig, samber/do. Fresh drift: **google/wire re-archived Aug 25 2025** — completely unmaintained (pkg.go.dev warning); community fork wireinject/wire exists. Wire was the closest thing to a Go default, so this strengthens guidance-only. | github.com/wireinject; pkg.go.dev/github.com/google/wire; do.samber.dev migration guide |
| 10 | Rust | Guidance-only | confirmed | Trait objects + manual wiring idiomatic; niche crates (shaku, inject, nject, more-di) with none dominant. | lib.rs/crates/shaku; docs.rs/inject; lib.rs/crates/dependency-injector |
| 11 | C++ | Guidance-only | confirmed | Manual/constructor wiring idiomatic; boost-ext/di exists (header-only) but no ecosystem standard. | github.com/boost-ext/di |
| 12 | Swift | Guidance-only | confirmed | Manual DI / SwiftUI environment; opt-in containers fragmented: Factory (compile-time, rising), Swinject (runtime, waning — last push Sep 2025), Needle (Uber, compile-time). | github.com/Swinject/Swinject; swinject.com; pistack.xyz 2026-08-12 |
| 13 | Ruby | Guidance-only | confirmed | Plain constructor injection (Rails idiom — no standard container); dry-rb stack (dry-container / dry-auto_inject / dry-system) as opt-in. | github.com/dry-rb/dry-container; dry-rb.org dry-system docs |
| 14 | React / Web Components | Guidance-only | confirmed | Context + hooks (`createContext`/`useContext`) for dependency-style value passing; no DI container idiom. | react.dev/learn/passing-data-deeply-with-context |

## `dependency-injector` maintenance status (the spec's named check)

- **Maintained: yes.** Latest release 4.49.1, **Jun 18 2026** (PyPI + GitHub
  Releases + pepy.tech agree); prior 4.49.0 (Mar 22 2026) added Python 3.14
  support; steady cadence 4.45.0 → 4.49.1 over ~15 months; Pydantic-v2 settings
  support and Cython wiring improvements landed.
- **The 2022–2023-era maintenance-pause concerns are stale.** The package is
  current with the newest interpreter.
- **Verdict: keep as Clear standard** for container-style DI, with the
  framework-native note for web frameworks (row 1).

## Canonical tier table for the shared DI detail card (currency-passed)

| Tier | Languages / Frameworks |
|---|---|
| Clear standard | Python (`dependency-injector`; framework-native `Depends` for web frameworks), C#/.NET (built-in `Microsoft.Extensions.DependencyInjection`), Java (Spring / Guice / Dagger 2), Angular (built-in DI framework; Vue/Svelte: provide-inject / context pattern) |
| Contested | Kotlin (Koin/Hilt), Scala (MacWire/Guice/ZIO ZLayer), Dart/Flutter (get_it/provider/Riverpod), TypeScript (tsyringe/InversifyJS) |
| Guidance-only | Go, Rust, C++, Swift, Ruby, React (Context/hooks), Web Components |

Corrections applied vs `#2249` verbatim: Java row (drift fix, item 3); Angular/
Vue/Svelte phrasing precision (item 4); Go row gains the wire re-archival note in
the card's selection guidance context (item 9 — tier unchanged).

## Gaps (honest reporting)

- Gin's exact final release date (1.5.0) unverified live — mvnrepository.com
  returned HTTP 403. Gin's deprecation is well-attested (Vue GWT official docs +
  two independent migration articles + dormant community mirror); the Java-row
  correction stands regardless.
- Guice 7.0.0's release year not shown by the fetched GitHub releases page
  (GitHub omits year for >1-year-old releases); no newer release exists — stable/
  slow verdict is sound, exact date not re-verified.
- tsyringe 4.10.0 exact publish date not captured (npm showed relative "a year
  ago" ≈ late 2025).
- boost-ext/di (C++) recent maintenance activity not deeply checked; the tier
  placement does not depend on it.
- Guidance-only tier for Go/Rust/C++/Swift/Ruby verified via absence-of-evidence
  across searches (no new mainstream container emerged); considered adequate for
  an advisory tier.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
