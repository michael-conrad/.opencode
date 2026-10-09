#!/bin/bash
# Per-scenario fixture: Gradle Java project with SPI provider registration for
# 2557-sc2.
#
# Layout:
#   settings.gradle                     — root project
#   gradle.properties                   — pins the daemon JVM to java-21
#                                         (system gradle is 8.3; java 25 on
#                                         PATH is unsupported by it)
#   build.gradle                        — java-library + shadow plugin
#   src/main/java/...                   — Greeter + GreetingProvider SPI
#   src/main/resources/META-INF/services/...
#                                       — ServiceLoader registration
#   AGENTS.md                           — build manifest declaring
#                                         ./gradlew shadowJar / test
#
# A Gradle wrapper pinned to 8.14 is pre-generated on a minimal build file
# (before the shadow plugin is written) so `./gradlew` resolves a distribution
# that supports the daemon JVM and the current shadow plugin coordinate
# (com.gradleup.shadow). The first ./gradlew invocation downloads the
# distribution — network is available in the test environment.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc2() {
    local wd="$1"
    local java21="/usr/lib/jvm/java-21-openjdk-amd64"

    mkdir -p "$wd/src/main/java/com/example/greet"
    mkdir -p "$wd/src/main/resources/META-INF/services"
    mkdir -p "$wd/src/test/java/com/example/greet"

    # Minimal build file so `gradle wrapper` needs no plugin resolution.
    cat > "$wd/settings.gradle" <<'EOF'
rootProject.name = 'greeter-service'
EOF

    cat > "$wd/build.gradle" <<'EOF'
plugins {
    id 'java-library'
}
EOF

    cat > "$wd/gradle.properties" <<EOF
org.gradle.java.home=${java21}
org.gradle.daemon=true
EOF

    # Pre-generate the wrapper pinned to a modern distribution.
    if command -v gradle >/dev/null 2>&1; then
        (cd "$wd" && JAVA_HOME="$java21" gradle -q wrapper --gradle-version 8.14 >/dev/null 2>&1 || true)
    fi

    # Real build file: java-library + shadow, with an explicit version catalog
    # entry omitted for simplicity — the agent configures the fat jar.
    cat > "$wd/build.gradle" <<'EOF'
plugins {
    id 'java-library'
    id 'application'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.apache.commons:commons-lang3:3.14.0'
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

application {
    mainClass = 'com.example.greet.Greeter'
}

test {
    useJUnitPlatform()
}
EOF

    cat > "$wd/src/main/java/com/example/greet/GreetingProvider.java" <<'EOF'
package com.example.greet;

/**
 * SPI: providers registered under META-INF/services are discovered by the
 * JDK ServiceLoader at runtime.
 */
public interface GreetingProvider {
    String greet(String name);
}
EOF

    cat > "$wd/src/main/java/com/example/greet/EnglishGreetingProvider.java" <<'EOF'
package com.example.greet;

public class EnglishGreetingProvider implements GreetingProvider {
    @Override
    public String greet(String name) {
        return "Hello, " + name + "!";
    }
}
EOF

    cat > "$wd/src/main/java/com/example/greet/Greeter.java" <<'EOF'
package com.example.greet;

import java.util.ServiceLoader;

public class Greeter {
    public static void main(String[] args) {
        ServiceLoader<GreetingProvider> loader = ServiceLoader.load(GreetingProvider.class);
        for (GreetingProvider provider : loader) {
            System.out.println(provider.greet(args.length > 0 ? args[0] : "world"));
        }
    }
}
EOF

    cat > "$wd/src/main/resources/META-INF/services/com.example.greet.GreetingProvider" <<'EOF'
com.example.greet.EnglishGreetingProvider
EOF

    cat > "$wd/src/test/java/com/example/greet/GreeterTest.java" <<'EOF'
package com.example.greet;

import org.junit.jupiter.api.Test;
import java.util.ServiceLoader;
import static org.junit.jupiter.api.Assertions.*;

class GreeterTest {
    @Test
    void serviceLoaderFindsProvider() {
        ServiceLoader<GreetingProvider> loader = ServiceLoader.load(GreetingProvider.class);
        assertTrue(loader.iterator().hasNext(), "at least one provider registered");
    }
}
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# greeter-service — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Build — distributable fat jar (canonical) | `./gradlew shadowJar` |
| Test (canonical) | `./gradlew test` |

The commands above are the repository's canonical build and test commands.
The shadowJar output lands in `build/libs/`.
EOF

    # Colliding SPI provider: a prebuilt dependency jar that ALSO registers
    # providers for com.example.greet.GreetingProvider. In the fat jar the two
    # META-INF/services files for the same service collide — shadow's default
    # duplicate handling silently keeps only one jar's registration, losing the
    # other. SPI-preserving fat-jar configuration (mergeServiceFiles() or
    # equivalent) is REQUIRED for both providers to survive; the jar-outputs
    # verification must show both registrations.
    local extra_src="$wd/build-extra-src"
    mkdir -p "$extra_src/com/example/greet" "$extra_src/META-INF/services" "$wd/libs"
    cat > "$extra_src/com/example/greet/FrenchGreetingProvider.java" <<'EOF'
package com.example.greet;

public class FrenchGreetingProvider implements GreetingProvider {
    @Override
    public String greet(String name) {
        return "Bonjour, " + name + "!";
    }
}
EOF
    cat > "$extra_src/META-INF/services/com.example.greet.GreetingProvider" <<'EOF'
com.example.greet.FrenchGreetingProvider
EOF
    local java21="/usr/lib/jvm/java-21-openjdk-amd64"
    if command -v javac >/dev/null 2>&1 || [ -x "$java21/bin/javac" ]; then
        (cd "$extra_src" && JAVA_HOME="$java21" "$java21/bin/javac" -cp "$wd/src/main/java" com/example/greet/FrenchGreetingProvider.java \
            && "$java21/bin/jar" --create --file "$wd/libs/extra-providers.jar" -C "$extra_src" META-INF/services/com.example.greet.GreetingProvider -C "$extra_src" com/example/greet/FrenchGreetingProvider.class)
    fi
    rm -rf "$extra_src"

    # The extra jar rides the runtime classpath so shadowJar bundles it.
    python3 - "$wd/build.gradle" <<'PYEOF'
import sys
p = sys.argv[1]
text = open(p).read()
text = text.replace(
    "dependencies {\n",
    "dependencies {\n    implementation files('libs/extra-providers.jar')\n",
    1,
)
open(p, "w").write(text)
PYEOF

    git -C "$wd" add -A
    git -C "$wd" commit -q -m "chore: greeter service scaffolding" || true
}

setup_2557_sc2 "$1"
