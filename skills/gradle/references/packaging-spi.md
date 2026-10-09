<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; plugin/transformer semantics verified against live GradleUp shadow docs 2026-10-07 -->

# Gradle packaging — fat jars and SPI preservation

How to assemble a dependency-bundling (fat) jar correctly with the shadow
plugin, and how to verify the artifact. Facts verified against the live
GradleUp shadow documentation (2026-10-07).

## Plugin

The current plugin id is **`com.gradleup.shadow`** (the old
`com.github.johnrengelman.shadow` id ended with the 8.x line — switch to the
new id). Match the plugin version to the project's Gradle version: 9.x needs
Gradle 8.11+ (9.3+ needs Gradle 9), 8.3.x is the first line under the new id
with a Gradle 8.3 floor.

## INCLUDE semantics — deciding what the jar contains

By default `shadowJar` bundles everything on the runtime classpath. Inclusion
and exclusion are controlled in the task's `dependencies {}` block:

```groovy
tasks.named('shadowJar', com.gradleup.shadow.ShadowJar) {
    dependencies {
        include(dependency('com.example.:.*'))
        exclude(dependency('org.slf4j:slf4j-nop:.*'))
    }
}
```

- Specs match group/artifact/version with regex; omitted fields are wildcards.
- If **any** `include` spec is present, only matching first-level dependencies
  are bundled — an include list is a whitelist, not an additive filter.
- `exclude` always wins over `include`.
- Dependency filtering does not cascade to transitive dependencies — verify the
  transitive closure lands in the jar when it matters.

## SPI preservation — `mergeServiceFiles()`

`META-INF/services/<ServiceName>` files are how the JDK `ServiceLoader` finds
implementations. In a fat jar, multiple dependencies may register providers for
the same service, and the jar's default duplicate handling will silently keep
only one jar's copy — **losing every other provider**.

`mergeServiceFiles()` (the `ServiceFileTransformer`) fixes this: it
concatenates every copy of each `META-INF/services/<ServiceName>` file into
one, deduplicates lines, and — critically — pushes the service file's name and
every class reference in it through the configured relocators. Therefore:

```groovy
tasks.named('shadowJar', com.gradleup.shadow.ShadowJar) {
    mergeServiceFiles()          // always, when SPI providers are in play
    relocate('com.example', 'shadow.com.example') {
        exclude('com.example.greet.*')   // example: scoped relocation
    }
}
```

- **`mergeServiceFiles()` is mandatory whenever `relocate()` is used** — the
  service-file content rewriting lives inside this transformer; without it the
  fat jar keeps pre-relocation package names and unrelocated file names, and
  ServiceLoader lookups break.
- Watch the duplicates strategy: shadow's default is `EXCLUDE`, which starves
  transformers of the duplicate files they exist to merge — set
  `duplicatesStrategy = DuplicatesStrategy.INCLUDE` on the task (optionally
  scoping dedupe back with `filesNotMatching('META-INF/services/**') {
  duplicatesStrategy = DuplicatesStrategy.EXCLUDE }`) so the transformer sees
  every copy.
- Groovy extension modules under `META-INF/services` need
  `mergeGroovyExtensionModules()` instead.

## Verifying the fat jar (the outputs check)

The build is not verified until the artifact is inspected:

```bash
jar tf build/libs/app-all.jar | grep 'META-INF/services/'   # registrations present
unzip -p build/libs/app-all.jar META-INF/services/com.example.Foo
# → merged provider lines; relocated FQCNs when relocation is configured
```

- Every service the runtime depends on must list its providers in the merged
  file — a missing or unrelocated registration is a defect the build did not
  catch.
- Assert the main class, the bundled dependency roots, and (under relocation)
  that no pre-relocation package names survive in service files.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
