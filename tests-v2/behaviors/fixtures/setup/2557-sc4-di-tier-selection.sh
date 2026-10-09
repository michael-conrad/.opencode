#!/bin/bash
# Per-scenario fixture: TypeScript project with an existing service for
# 2557-sc4.
#
# TypeScript is the Contested tier (tsyringe / InversifyJS both idiomatic) —
# the tier table documents two or more idiomatic options, so the selection
# guidance (code analysis + requirements, combinations allowed) applies.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc4() {
    local wd="$1"

    mkdir -p "$wd/src"

    cat > "$wd/package.json" <<'EOF'
{
  "name": "orders-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "tsc",
    "test": "vitest run"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "vitest": "^2.0.0"
  }
}
EOF

    cat > "$wd/tsconfig.json" <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "strict": true,
    "outDir": "dist",
    "rootDir": "src",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": ["src"]
}
EOF

    cat > "$wd/src/catalog.ts" <<'EOF'
/** Catalog lookup (existing code). */
export class Catalog {
  priceFor(sku: string): number {
    return sku.length * 10;
  }
}

export class OrderService {
  private catalog: Catalog;

  constructor() {
    this.catalog = new Catalog();
  }

  total(skus: string[]): number {
    return skus.reduce((sum, sku) => sum + this.catalog.priceFor(sku), 0);
  }
}
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# orders-app — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Build (canonical) | `npm run build` |
| Test (canonical) | `npm test` |

The commands above are the repository's canonical build and test commands.
EOF

    git -C "$wd" add -A
    git -C "$wd" commit -q -m "chore: orders app scaffolding" || true
}

setup_2557_sc4 "$1"
