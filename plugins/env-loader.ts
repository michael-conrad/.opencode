/**
 * Env-Loader Plugin for OpenCode
 *
 * Reads project environment data and injects all key-value pairs into
 * every shell session via the `shell.env` hook. This is the SOLE provider
 * of bash environment variables — session-enforcement.ts owns LLM context.
 *
 * Sources (independently gathered, no cross-plugin coupling):
 * - .env file — all parsed key-value pairs including secrets
 * - input.worktree — WORKTREE_PATH for bash commands
 *
 * Hook: shell.env ONLY — no system.transform, no LLM output.
 *
 * Restored from commit f7555bd, extended per issue #712.
 *
 * Co-authored with AI: OpenCode (ollama-cloud/glm-5)
 */

import type { Plugin } from "@opencode-ai/plugin";
import fs from "fs";
import path from "path";

const ENV_FILE = ".env";



interface PluginDiagnostic {
  source: string;
  level: "error" | "warning" | "info";
  message: string;
  exitCode?: number;
}

const DIAGNOSTICS_PATH = path.join(".opencode", "tmp", "plugin-diagnostics.jsonl");

function writeDiagnostic(projectDir: string, diagnostic: PluginDiagnostic): void {
  const fullPath = path.join(projectDir, DIAGNOSTICS_PATH);
  const dir = path.dirname(fullPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  const line = JSON.stringify(diagnostic) + "\n";
  fs.appendFileSync(fullPath, line, "utf8");
}

interface ParseResult {
  env: Record<string, string>;
  warnings: string[];
}

function parseEnvFile(content: string): ParseResult {
  const env: Record<string, string> = {};
  const warnings: string[] = [];

  for (const rawLine of content.split("\n")) {
    const line = rawLine.trim();

    if (line === "" || line.startsWith("#")) {
      continue;
    }

    const eqIdx = line.indexOf("=");
    if (eqIdx === -1) {
      continue;
    }

    const key = line.slice(0, eqIdx).trim();
    let value = line.slice(eqIdx + 1).trim();

    if (!key) {
      continue;
    }

    // Strip inline comments before unquoting
    value = stripInlineComments(value);

    // Strip surrounding quotes
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (key in env) {
      warnings.push(`Duplicate key "${key}" — last value wins`);
    }

    env[key] = value;
  }

  return { env, warnings };
}

function stripInlineComments(value: string): string {
  // If value is quoted, don't strip inline comments — hashes inside quotes are literal
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value;
  }
  // For unquoted values, strip inline comments: `value # comment`
  const hashIdx = value.indexOf(" #");
  if (hashIdx !== -1) {
    return value.slice(0, hashIdx).trim();
  }
  return value;
}

function isEnvGitignored(projectDir: string): boolean {
  const gitignorePath = path.join(projectDir, ".gitignore");
  try {
    const content = fs.readFileSync(gitignorePath, "utf8");
    const lines = content.split("\n");
    for (const line of lines) {
      const trimmed = line.trim();
      if (trimmed === ".env" || trimmed === "/.env") {
        return true;
      }
    }
    return false;
  } catch {
    return false;
  }
}

export const EnvLoaderPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  const projectDir = directory || process.cwd();
  const envPath = path.join(projectDir, ENV_FILE);

  return {
    "shell.env": async (_input, output) => {
      // --- .env file values ---
      if (fs.existsSync(envPath)) {
        const content = fs.readFileSync(envPath, "utf8");
        const { env, warnings } = parseEnvFile(content);

        for (const [key, value] of Object.entries(env)) {
          output.env[key] = value;
        }

        // Flag non-gitignored .env
        if (!isEnvGitignored(projectDir)) {
          output.env["ENV_LOADER_SECURITY_WARNING"] =
            "SECURITY: .env file is NOT in .gitignore. Secrets may be committed to version control. Add '.env' to .gitignore immediately.";
          writeDiagnostic(projectDir, {
            source: "env-loader",
            level: "warning",
            message: ".env file is NOT in .gitignore — secrets may be committed to version control",
          });
        }

        if (warnings.length > 0) {
          console.error("[env-loader] " + warnings.join("; "));
          for (const w of warnings) {
            writeDiagnostic(projectDir, {
              source: "env-loader",
              level: "warning",
              message: w,
            });
          }
        }
      }

      // --- WORKTREE_PATH from PluginInput ---
      const worktreeDir = worktree || "";
      const mainRepoDir = directory || "";
      if (worktreeDir && worktreeDir !== mainRepoDir) {
        output.env["WORKTREE_PATH"] = worktreeDir;
      }


    },
  };
}


// Utility functions are intentionally not re-exported — the plugin system
// iterates over all named exports and tries to call each as a plugin function.
// Only the plugin function itself is exported.
// PluginDiagnostic type is intentionally not re-exported — see above.
