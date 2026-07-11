/**
 * Session Enforcement Plugin for OpenCode
 *
 * Injects session context into the LLM system prompt and enforces
 * runtime guards: evidence gate, git config
 * mutation watchdog, protected branch edits, secret redaction, session triggers,
 * and plugin diagnostics.
 *
 * Hook: system.transform — pushes English prose context (from session-init
 *   and PluginInput augmentations) into the LLM system prompt.
 * Hook: chat.messages.transform — injects runtime enforcement blocks and
 *   validation gates into user messages.
 *
 * Source attribution:
 * - Session init pattern adapted from existing session-init.ts (project-internal)
 * - Skill enforcement injection adapted from obra/superpowers
 *   https://github.com/obra/superpowers/blob/main/.opencode/plugins/superpowers.js
 * - Red-flags rationalization table adapted from obra/superpowers writing-skills
 *   https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 * - CSO (Content Search Optimization) principles adapted from obra/superpowers
 *   https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 *
 * Co-authored with AI: OpenCode (ollama-cloud/glm-5)
 */

import type { Hooks, PluginInput } from "@opencode-ai/plugin";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { execSync } from "child_process";

const CACHE_TTL_MS = 5 * 60 * 1000;

interface GitConfigBaseline {
  configHash: string;
  localConfigHash: string;
  remotes: string[];
  remoteCount: number;
  capturedAt: number;
}

const SECURITY_RELEVANT_KEY_PATTERNS: RegExp[] = [
  /^remote\./,
  /^url\./,
  /^http\.proxy$/,
  /^core\.sshCommand$/,
  /^http\.sslVerify$/,
  /^http\.sslCAInfo$/,
  /^credential\.helper$/,
  /^credential\.username$/,
  /^protocol\..*\.allow$/,
  /^core\.hooksPath$/,
  /^init\.templateDir$/,
];

const EXEMPT_KEY_PATTERNS: RegExp[] = [
  /^user\.name$/,
  /^user\.email$/,
  /^core\.autocrlf$/,
  /^core\.filemode$/,
  /^push\.default$/,
  /^submodule\./,
  /^branch\./,
];

function isSecurityRelevantKey(key: string): boolean {
  return SECURITY_RELEVANT_KEY_PATTERNS.some(p => p.test(key));
}

function isExemptKey(key: string): boolean {
  return EXEMPT_KEY_PATTERNS.some(p => p.test(key));
}

function sha256(data: string): string {
  return crypto.createHash("sha256").update(data, "utf8").digest("hex");
}

function captureGitConfigBaseline(projectDir: string): GitConfigBaseline | null {
  try {
    const gitDir = resolveGitDir(projectDir);
    const configContent = gitDir
      ? fs.readFileSync(path.join(gitDir, "config"), "utf8")
      : "";
    const configHash = sha256(configContent);

    let localConfigOutput = "";
    try {
      localConfigOutput = execSync("git config --local --list", {
        cwd: projectDir,
        encoding: "utf8",
        input: "",
        timeout: 5000,
        stdio: ["pipe", "pipe", "pipe"],
      }).trim();
    } catch {
      // No local config or git unavailable
    }
    const localConfigHash = sha256(localConfigOutput);

    let remoteOutput = "";
    try {
      remoteOutput = execSync("git remote -v", {
        cwd: projectDir,
        encoding: "utf8",
        input: "",
        timeout: 5000,
        stdio: ["pipe", "pipe", "pipe"],
      }).trim();
    } catch {
      // No remotes or git unavailable
    }

    const remotes = remoteOutput
      ? [...new Set(remoteOutput.split("\n").map(l => l.split(/\s+/)[0]).filter(Boolean))]
      : [];

    return {
      configHash,
      localConfigHash,
      remotes,
      remoteCount: remotes.length,
      capturedAt: Date.now(),
    };
  } catch {
    return null;
  }
}

function extractChangedSecurityKeys(oldLocalConfig: string, newLocalConfig: string): string[] {
  const oldKeys = new Set(
    oldLocalConfig.split("\n").filter(Boolean).map(l => l.split("=")[0].trim())
  );
  const newKeys = new Set(
    newLocalConfig.split("\n").filter(Boolean).map(l => l.split("=")[0].trim())
  );

  const changed: string[] = [];
  for (const key of newKeys) {
    if (!oldKeys.has(key) && isSecurityRelevantKey(key) && !isExemptKey(key)) {
      changed.push(key);
    }
  }
  for (const key of oldKeys) {
    if (!newKeys.has(key) && isSecurityRelevantKey(key) && !isExemptKey(key)) {
      changed.push(key);
    }
  }

  return changed;
}

let gitConfigBaseline: GitConfigBaseline | null = null;
let baselineLocalConfig: string = "";

function buildGitConfigMutationBlock(changedKeys: string[]): string {
  const keyList = changedKeys.map(k => `- \`${k}\``).join("\n");
  return `### Git Configuration Mutation Warning

**Warning:** Security-relevant git configuration was mutated during this session!

Changed keys:
${keyList}

This is a Tier 1 mandate violation unless explicitly authorized by the developer. HALT and verify the mutation was authorized before proceeding. See 000-critical-rules.md for details on Git Configuration and Destructive Command Authorization.`;
}

// buildNoVerifyBlockedBlock() REMOVED per SPEC-FIX #823 — see removal comment above.

function isModeSwitchSynthetic(text: string): boolean {
  return text.includes('Your operational mode has changed from')
      || text.includes('# Plan Mode - System Reminder');
}

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

function collectDiagnostics(projectDir: string): PluginDiagnostic[] {
  const fullPath = path.join(projectDir, DIAGNOSTICS_PATH);
  if (!fs.existsSync(fullPath)) {
    return [];
  }
  try {
    const content = fs.readFileSync(fullPath, "utf8");
    const diagnostics: PluginDiagnostic[] = [];
    for (const line of content.split("\n")) {
      const trimmed = line.trim();
      if (!trimmed) continue;
      try {
        diagnostics.push(JSON.parse(trimmed));
      } catch {
        // Skip malformed lines
      }
    }
    // Clear the file after reading
    fs.writeFileSync(fullPath, "", "utf8");
    return diagnostics;
  } catch {
    return [];
  }
}

function buildDiagnosticBlock(diagnostics: PluginDiagnostic[]): string {
  if (diagnostics.length === 0) return "";

  const entries = diagnostics.map(d => {
    let line = `- [${d.level.toUpperCase()}] ${d.source}: ${d.message}`;
    if (d.exitCode !== undefined) {
      line += ` (exit code ${d.exitCode})`;
    }
    return line;
  }).join("\n");

  const hasErrors = diagnostics.some(d => d.level.toUpperCase() === "ERROR");

  if (hasErrors) {
    const actions = diagnostics
      .filter(d => d.level.toUpperCase() === "ERROR")
      .map(d => `- Investigate and resolve the ${d.source} ERROR before proceeding`)
      .join("\n");

    return `### Plugin Diagnostics

**Warning:** The following plugin diagnostics were collected during session startup:

${entries}

**Must not proceed:** ERROR-level diagnostics detected. HALT immediately and resolve these errors.

**Mandatory actions:**
${actions}

Do NOT continue with any operations until ALL ERROR-level diagnostics are resolved.`;
  }

  return `### Plugin Diagnostics

**Warning:** The following plugin diagnostics were collected during session startup:

${entries}

Review these diagnostics. For errors, investigate the source script. For warnings, assess whether action is needed.`;
}

/**
 * Process-scoped set of session IDs that are sub-agent sessions
 * (sessions with a parentID). Populated in system.transform by
 * querying client.session.get() for parentID. Used in messages.transform
 * to gate first-turn-only injections for sub-agent sessions.
 *
 * REQ-5: No disk persistence — the set is rebuilt from live API queries
 * on each process restart, never written to disk.
 */
const subAgentSessions = new Set<string>();

/**
 * Process-scoped set of session IDs that have already received their
 * first-turn injections. Survives context reload (new process = empty
 * Set = fires again correctly). Keyed by sessionID from the user
 * message info in messages.transform.
 *
 * SC-1: Replaces userMessages.length === 1 heuristic.
 * SC-2: session.created event fires before messages.transform,
 *       so sessionID is available for Set-based detection.
 */
const injectedFirstTurnSessions = new Set<string>();

/**
 * In-memory cache mapping sessionID → parentID, populated by the
 * session.created event handler. Used as the PRIMARY detection source
 * in messages.transform because input.client is unavailable in that
 * hook context. The session.created event fires synchronously before
 * messages.transform and carries parentID directly in its payload.
 *
 * Fallback: subAgentSessions Set (populated via input.client.session.get()
 * in system.transform) is used when the cache misses.
 *
 * SC-1: Cache populated before messages.transform fires.
 * SC-2: Cache is primary source, API fallback on cache miss.
 */
const sessionParentCache = new Map<string, string>();

function resolveGitDir(projectDir: string): string | null {
  try {
    const result = execSync("git rev-parse --git-dir", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
    if (path.isAbsolute(result)) return result;
    return path.resolve(projectDir, result);
  } catch {
    return null;
  }
}

function ensureHooksInstalled(projectDir: string): void {
  const hooksSourceDir = path.join(projectDir, ".opencode", "hooks");
  if (!fs.existsSync(hooksSourceDir)) {
    console.error("[session-enforcement] .opencode/hooks/ directory missing — repo integrity problem");
    writeDiagnostic(projectDir, {
      source: "session-enforcement",
      level: "error",
      message: ".opencode/hooks/ directory missing — repo integrity problem",
    });
    return;
  }

  const gitDir = resolveGitDir(projectDir);
  if (!gitDir) {
    console.error("[session-enforcement] Could not resolve .git directory for hooks installation");
    writeDiagnostic(projectDir, {
      source: "session-enforcement",
      level: "error",
      message: "Could not resolve .git directory for hooks installation",
    });
    return;
  }

  const hooksTargetDir = path.join(gitDir, "hooks");
  fs.mkdirSync(hooksTargetDir, { recursive: true });

  const sourceEntries = fs.readdirSync(hooksSourceDir);
  for (const hookName of sourceEntries) {
    const sourcePath = path.join(hooksSourceDir, hookName);
    if (!fs.statSync(sourcePath).isFile()) continue;
    if (hookName.endsWith(".sample")) continue;

    const targetPath = path.join(hooksTargetDir, hookName);
    let needsCopy = false;

    if (!fs.existsSync(targetPath)) {
      needsCopy = true;
    } else {
      const sourceContent = fs.readFileSync(sourcePath, "utf8");
      const targetContent = fs.readFileSync(targetPath, "utf8");
      if (sourceContent !== targetContent) {
        needsCopy = true;
      }
    }

    if (needsCopy) {
      fs.copyFileSync(sourcePath, targetPath);
      fs.chmodSync(targetPath, 0o755);
    }
  }
}

function runSessionInit(projectDir: string): string {
  try {
    const stdout = execSync("./.opencode/tools/session-init", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    return stdout;
  } catch (err: any) {
    const stdout = err?.stdout?.toString().trim() ?? "";
    const stderr = err?.stderr?.toString().trim() ?? "";
    const exitCode = err?.status ?? 1;

    const isTimeout = err?.killed || err?.signal === "SIGTERM";

    if (!stdout || stdout.length === 0) {
      const errorMsg = isTimeout
        ? `session-init timed out after 30s — likely git credential prompt, lock contention, or submodule hang`
        : (stderr || "Script returned empty output");
      console.error(`[session-enforcement] session-init: ${errorMsg}`);
      writeDiagnostic(projectDir, {
        source: "session-init",
        level: "error",
        message: errorMsg,
        exitCode: isTimeout ? undefined : exitCode,
      });
      if (stderr && !isTimeout) {
        writeDiagnostic(projectDir, {
          source: "session-init",
          level: "error",
          message: stderr,
          exitCode,
        });
      }
      return "";
    }

    if (stderr) {
      writeDiagnostic(projectDir, {
        source: "session-init",
        level: "warning",
        message: stderr,
        exitCode,
      });
    }

    return stdout;
  }
}

let cachedTriggersOutput: string | null = null;
let triggersCacheTimestamp = 0;

async function runSessionContextTriggers(projectDir: string): Promise<string> {
  if (cachedTriggersOutput && Date.now() - triggersCacheTimestamp < CACHE_TTL_MS) {
    return cachedTriggersOutput;
  }

  try {
    const stdout = execSync("./.opencode/scripts/session_context_triggers.py", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    cachedTriggersOutput = stdout;
    triggersCacheTimestamp = Date.now();

    return stdout;
  } catch (err: any) {
    const stdout = err?.stdout?.toString().trim() ?? "";
    const stderr = err?.stderr?.toString().trim() ?? "";
    const exitCode = err?.status ?? 1;

    const isTimeout = err?.killed || err?.signal === "SIGTERM";

    if (exitCode !== 0) {
      const errorMsg = isTimeout
        ? `session_context_triggers.py timed out after 30s`
        : (stderr || "Script exited with non-zero code");
      console.error(`[session-enforcement] session_context_triggers.py exited with code ${exitCode}: ${errorMsg}`);
      writeDiagnostic(projectDir, {
        source: "session_context_triggers.py",
        level: "error",
        message: errorMsg,
        exitCode: isTimeout ? undefined : exitCode,
      });
      return "";
    }

    if (!stdout || stdout.length === 0) {
      if (stderr) {
        writeDiagnostic(projectDir, {
          source: "session_context_triggers.py",
          level: "warning",
          message: stderr,
          exitCode,
        });
      }
      return "";
    }

    if (stderr) {
      writeDiagnostic(projectDir, {
        source: "session_context_triggers.py",
        level: "warning",
        message: stderr,
        exitCode,
      });
    }

    cachedTriggersOutput = stdout;
    triggersCacheTimestamp = Date.now();

    return stdout;
  }
}


/**
 * Build a formatted guidelines index block from INDEX.md for system prompt injection.
 * Reads the INDEX.md file and formats it as a compact routing reference.
 * Returns empty string if INDEX.md is missing or unreadable.
 */
function buildGuidelinesIndex(projectDir: string): string {
  const indexPath = path.join(projectDir, ".opencode", "guidelines", "INDEX.md");
  if (!fs.existsSync(indexPath)) return "";

  try {
    const content = fs.readFileSync(indexPath, "utf8");
    // Strip the heading and intro lines, keep only the table
    const tableMatch = content.match(/\|.*\|.*\|.*\|.*\|\n\|[-| ]+\|\n([\s\S]*)/);
    if (!tableMatch) return "";

    const tableBody = tableMatch[1].trim();
    return `### Guidelines Index (Progressive Disclosure)

Full guideline bodies are loaded on-demand by sub-agents when enforcement gates fire.
The orchestrator holds only this routing index. To load a specific guideline in a sub-agent,
use \`./.opencode/tools/guidelines read <filename>\`.

| Guideline | Tier | Trigger Pattern | Load When |
|-----------|------|-----------------|-----------|
${tableBody}`;
  } catch {
    return "";
  }
}

/**
 * Extract trigger patterns from a SKILL.md description field.
 * Descriptions contain "Triggers on:" followed by comma-separated keywords.
 */
function extractTriggerPatterns(description: string): string[] {
  const match = description.match(/Triggers\s+on:\s*([^]*?)(?:\n|$)/i);
  if (!match) return [];
  return match[1].split(",").map(t => t.trim()).filter(Boolean);
}

/**
 * Build a formatted skill index block for system prompt injection.
 * Reads all SKILL.md files, extracts name + description + trigger patterns.
 * Returns empty string if skills directory is missing.
 */
function buildSkillIndex(skillsDir: string): string {
  const { skills, errors } = loadSkillDescriptions(skillsDir);
  // Build a compact skill index table (name, description, trigger patterns)
  const skillRows = skills.map(s => {
    const triggers = extractTriggerPatterns(s.description);
    const triggersStr = triggers.length > 0 ? triggers.slice(0, 5).join(", ") : "—";
    return `| \`${s.name}\` | ${s.description} | ${triggersStr} |`;
  }).join("\n");

  if (skillRows.length === 0) return "";

  return `### Skill Index

| Skill | Description | Trigger Keywords |
|-------|-------------|------------------|
${skillRows}`;
}

function buildWorktreeBlock(input: PluginInput): string {
  const mainRepoDir = input?.directory || "";
  const worktreeDir = input?.worktree || "";

  if (worktreeDir && worktreeDir !== mainRepoDir) {
    return `worktree.path: ${worktreeDir}\nAll file operations (read, edit, write, glob, grep) MUST use paths prefixed with worktree.path. Relative paths resolve to the main repo, not the worktree.`;
  }

  return "";
}

/**
 * Extract and strip YAML frontmatter from SKILL.md content.
 * Adapted from obra/superpowers/plugins/superpowers.js
 */
function extractFrontmatter(content: string): {
  frontmatter: Record<string, string>;
  body: string;
} {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { frontmatter: {}, body: content };

  const frontmatterStr = match[1];
  const body = match[2];
  const frontmatter: Record<string, string> = {};

  for (const line of frontmatterStr.split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim();
      const value = line.slice(colonIdx + 1).trim().replace(/^["']|["']$/g, "");
      frontmatter[key] = value;
    }
  }

  return { frontmatter, body };
}

interface FrontmatterError {
  skillDir: string;
  issues: string[];
}

/**
 * Load skill descriptions from YAML frontmatter in SKILL.md files.
 * Adapted from obra/superpowers/plugins/superpowers.js skill discovery pattern.
 *
 * Description format: noun phrase identity with embedded "Dispatch when" clause.
 * See .opencode/reference/skill-card-schema.md for the canonical schema.
 *
 * Returns { skills, errors } where errors collects frontmatter validation issues.
 * See #601 for the original bug that motivated frontmatter validation.
 */
function loadSkillDescriptions(skillsDir: string): {
  skills: Array<{ name: string; description: string }>;
  errors: FrontmatterError[];
} {
  const skills: Array<{ name: string; description: string }> = [];
  const errors: FrontmatterError[] = [];

  try {
    const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillPath = path.join(skillsDir, entry.name, "SKILL.md");
      if (!fs.existsSync(skillPath)) continue;

      try {
        const content = fs.readFileSync(skillPath, "utf8");
        const validationIssues: string[] = [];

        const hasOpeningDelimiter = /^---\s*\n/m.test(content);
        const { frontmatter } = extractFrontmatter(content);

        if (!hasOpeningDelimiter) {
          validationIssues.push("Missing `---` opening delimiter");
        } else if (Object.keys(frontmatter).length === 0) {
          validationIssues.push("Delimiters present but no key:value pairs parsed (format error)");
        }

        if (hasOpeningDelimiter && !frontmatter.name) {
          validationIssues.push("Missing `name` field");
        }

        if (hasOpeningDelimiter && !frontmatter.description) {
          validationIssues.push("Missing `description` field — skill will be invisible to enforcement");
        }

        if (validationIssues.length > 0) {
          errors.push({ skillDir: entry.name, issues: validationIssues });
        }

        const name = frontmatter.name || entry.name;
        const description = frontmatter.description || "";
        if (description) {
          skills.push({ name, description });
        }
      } catch {
        // Skip unreadable skill files
      }
    }
  } catch {
    // Skills directory may not exist in all contexts
  }

  return { skills, errors };
}

/**
 * Build a structured warning string for frontmatter validation errors.
 * Returns empty string if no errors, so the caller can skip injection.
 * References #601 as the example bug that motivated this validation.
 */
function buildFrontmatterWarning(errors: FrontmatterError[]): string {
  if (errors.length === 0) return "";

  const perSkillListing = errors
    .map(e => `- **${e.skillDir}**: ${e.issues.join("; ")}`)
    .join("\n");

  return `### Frontmatter Validation

**Warning:** The following SKILL.md files have frontmatter issues that may make skills invisible to enforcement:

${perSkillListing}

**Fix template:** every SKILL.md MUST start with YAML frontmatter with name and description fields. See https://opencode.ai/docs/skills for the complete schema. See #601 for the original bug that motivated frontmatter validation.`;
}




/**
 * Secret patterns for redaction.
 * These regexes match secret values in various formats while preserving key names.
 */
const SECRET_PATTERNS: Array<{ pattern: RegExp; type: string }> = [
  { pattern: /\b(TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|API_KEY|PRIVATE_KEY|ACCESS_TOKEN)\s*[=:]\s*["']?([^\s"']+?)["']?(?=\s|$|[^\w])/gi, type: "assignment" },
  { pattern: /:\/\/([^:]+):([^@]+)@/g, type: "url_password" },
  { pattern: /\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}/g, type: "github_token" },
  { pattern: /\bglpat-[A-Za-z0-9\-]{20,}/g, type: "gitlab_token" },
];

/**
 * Redact secrets from text, replacing values with [REDACTED:TYPE] markers.
 * Key names are preserved — only secret values are replaced.
 *
 * Co-authored with AI: OpenCode (ollama-cloud/glm-5)
 */
function redactSecrets(text: string): string {
  let result = text;

  // URL-embedded passwords: user:password@ → user:[REDACTED:PASSWORD]@
  result = result.replace(/:\/\/([^:]+):([^@]+)@/g, (_match, user: string, _password: string) => {
    return `://${user}:[REDACTED:PASSWORD]@`;
  });

  // GitHub tokens
  result = result.replace(/\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}/g, "[REDACTED:TOKEN]");

  // GitLab tokens
  result = result.replace(/\bglpat-[A-Za-z0-9\-]{20,}/g, "[REDACTED:TOKEN]");

  // Assignment patterns: KEY=value, KEY="value", KEY='value'
  // Matches keys that end with or are exactly one of the secret keywords
  // e.g., GITBUCKET_TOKEN=value, MY_SECRET=value, PASSWORD=abc, API_KEY="xyz"
  result = result.replace(
    /((?:\w*(?:TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|API_KEY|PRIVATE_KEY|ACCESS_TOKEN))\s*[=:]\s*)(["']?)([^\s"'#]+?)\2/gi,
    (_match, prefix: string, quote: string, _value: string) => {
      const keyMatch = prefix.match(/(\w+)\s*[=:]/);
      const keyName = keyMatch ? keyMatch[1].toUpperCase() : "";
      let typeLabel: string;
      if (keyName === "PASSWORD" || keyName === "CREDENTIAL") {
        typeLabel = keyName;
      } else if (keyName.endsWith("PASSWORD")) {
        typeLabel = "PASSWORD";
      } else if (keyName.endsWith("CREDENTIAL")) {
        typeLabel = "CREDENTIAL";
      } else {
        typeLabel = "TOKEN";
      }
      return `${prefix}${quote}[REDACTED:${typeLabel}]${quote}`;
    }
  );

  return result;
}

export default async function sessionEnforcementPlugin(input: PluginInput): Promise<Hooks> {
  // Determine skills directory and project directory
  const projectDir = input?.directory || process.cwd();
  const skillsDir = path.join(projectDir, ".opencode", "skills");

  // Pre-load skill descriptions and frontmatter validation at plugin startup
  const { errors: frontmatterErrors } = loadSkillDescriptions(skillsDir);

  // Ensure git hooks from .opencode/hooks/ are installed into .git/hooks/
  ensureHooksInstalled(projectDir);

  // Capture git config baseline for mutation watchdog
  gitConfigBaseline = captureGitConfigBaseline(projectDir);
  if (gitConfigBaseline) {
    try {
      baselineLocalConfig = execSync("git config --local --list", {
        cwd: projectDir,
        encoding: "utf8",
        input: "",
        timeout: 5000,
        stdio: ["pipe", "pipe", "pipe"],
      }).trim();
    } catch {
      baselineLocalConfig = "";
    }
  }

  return {
    // --- Sub-agent detection via event hook with event.type discrimination (SC-1) ---
    // The session.created event fires synchronously before messages.transform
    // and carries parentID directly in its payload. This populates the
    // sessionParentCache Map so messages.transform can detect sub-agents
    // without relying on input.client (which is unavailable in that hook).
    event: async (eventInput) => {
      if (eventInput?.event?.type !== "session.created") return;
      const sessionID = eventInput?.event?.properties?.info?.id;
      const parentID = eventInput?.event?.properties?.info?.parentID;
      if (sessionID && parentID) {
        sessionParentCache.set(sessionID, parentID);
        subAgentSessions.add(sessionID);
      }
    },

    // Inject session context into system prompt (from session-init + PluginInput augmentations)
    "experimental.chat.system.transform": async (sysInput, output) => {
      // --- Sub-agent session detection (REQ-1/REQ-5) ---
      // Query client.session.get() for parentID; if present, this session
      // is a sub-agent. Register in process-scoped Set for later use in
      // messages.transform. Graceful degradation: on failure, assume
      // primary session (REQ-4).
      const sessionID = sysInput?.sessionID;
      if (sessionID) {
        try {
          const sessionResult = await input.client.session.get({
            path: { id: sessionID },
          });
          if (sessionResult.data?.parentID) {
            subAgentSessions.add(sessionID);
          } else {
            subAgentSessions.delete(sessionID);
          }
        } catch {
          // REQ-4: Graceful degradation — assume primary session on API failure
          subAgentSessions.delete(sessionID);
        }
      }

      const scriptOutput = runSessionInit(projectDir);
      if (scriptOutput) {
        output.system.push(scriptOutput);
      }

      // Inject worktree context when session is operating in a worktree
      const worktreeBlock = buildWorktreeBlock(input);
      if (worktreeBlock) {
        output.system.push(worktreeBlock);
      }

      // Inject guidelines index (INDEX.md) instead of full guideline bodies
      const guidelinesIndex = buildGuidelinesIndex(projectDir);
      if (guidelinesIndex) {
        output.system.push(guidelinesIndex);
      }

      // Inject skill index (name + description + trigger patterns from SKILL.md frontmatter)
      const skillIndex = buildSkillIndex(skillsDir);
      if (skillIndex) {
        output.system.push(skillIndex);
      }

      // Inject frontmatter validation warning if any skills have broken frontmatter
      const warning = buildFrontmatterWarning(frontmatterErrors);
      if (warning) {
        output.system.push(warning);
      }

    },

    // Inject enforcement content into first user message (adapted from obra/superpowers)
      // AND detect bare #N issue references in last user message
      // AND inject trigger warnings into first user message
      // AND inject plugin diagnostics block into first user message
      //
      // FIRST-TURN GUARD: EXTREMELY_IMPORTANT, SESSION_TRIGGERS, and
      // PLUGIN_DIAGNOSTICS are injected ONLY on the first turn of PRIMARY
      // sessions (isFirstTurn && !isSubAgent). Sub-agent sessions inherit
      // context from their parent, so these blocks are redundant and waste
      // context window space (REQ-1/REQ-2).
      //
      // Per-turn behaviors (unchanged, unconditional per REQ-3/REQ-6):
      // - Bare issue pipeline detection on lastUser
      // - Secret redaction on all assistant messages
      // - Protected branch edit warning
      "experimental.chat.messages.transform": async (_input, output) => {
        if (!output.messages || !output.messages.length) return;

        const userMessages = output.messages.filter(m => m.info?.role === "user");
        if (!userMessages.length) return;

        const firstUser = userMessages[0];
        const firstUserSessionID = firstUser?.info?.sessionID;
        const isFirstTurn = firstUserSessionID ? !injectedFirstTurnSessions.has(firstUserSessionID) : (userMessages.length === 1);

        // --- Sub-agent detection (SC-1, SC-2) ---
        // Determine if this session has a parentID (is a sub-agent session).
        // Uses a two-tier detection strategy:
        //   1. PRIMARY: sessionParentCache (populated by session.created event handler)
        //   2. FALLBACK: subAgentSessions Set (populated by system.transform API call)
        // REQ-5: No disk persistence — both caches are process-scoped only.
        // REQ-4: Graceful degradation — if sessionID is unavailable, assume
        // primary session (isSubAgent = false) so full injections are applied.
        const sessionID = firstUser?.info?.sessionID;
        let isSubAgent = false;
        if (sessionID) {
          if (sessionParentCache.has(sessionID)) {
            isSubAgent = true;
          } else if (subAgentSessions.has(sessionID)) {
            isSubAgent = true;
          }
        }

        // --- First-turn-only PRIMARY sessions: Skip all first-turn injections
        //     for sub-agent sessions (isFirstTurn && !isSubAgent required) ---
        // REQ-2: Sub-agent sessions inherit parent context, making these blocks
        //         redundant. Gating them saves significant context window space.
        const shouldInjectFirstTurn = isFirstTurn && !isSubAgent;

        if (shouldInjectFirstTurn) {
          // --- First-turn-only: Trigger warnings ---
          const triggersOutput = await runSessionContextTriggers(projectDir);

          // Per spec #426: extract NESTED_OPENCODE_FATAL from triggers output
          // and inject it as a SEPARATE block (not inside Session Triggers)
          let triggerOutputForSessionBlock = triggersOutput || "";
          let nestedOpencodeBlock = "";
          const nestedFatalMatch = triggerOutputForSessionBlock.match(/### NESTED_OPENCODE_FATAL[\s\S]*?(?=\n### |\n\n### |\n*$)/);
          if (nestedFatalMatch) {
            nestedOpencodeBlock = nestedFatalMatch[0].trim();
            // Remove the nested opencode block from the session triggers output
            triggerOutputForSessionBlock = triggerOutputForSessionBlock.replace(nestedFatalMatch[0], "").trim();
          }
          // Also match if it's the only/last section (no trailing ###)
          if (!nestedOpencodeBlock) {
            const nestedFatalOnlyMatch = triggersOutput?.match(/### NESTED_OPENCODE_FATAL[\s\S]*/);
            if (nestedFatalOnlyMatch) {
              nestedOpencodeBlock = nestedFatalOnlyMatch[0].trim();
              triggerOutputForSessionBlock = triggerOutputForSessionBlock.replace(nestedFatalOnlyMatch[0], "").trim();
            }
          }

          const triggerBlock = triggerOutputForSessionBlock ? `### Session Triggers\n\n${triggerOutputForSessionBlock}` : "";

          const echoParts: string[] = [];
          if (triggerBlock) {
            echoParts.push(triggerBlock);
          }
          if (echoParts.length > 0 && firstUser.parts?.length) {
            firstUser.parts.unshift({ id: crypto.randomUUID(), sessionID: firstUser.info.sessionID, messageID: firstUser.info.id, type: "text", text: echoParts.join("\n\n") });
          }

          // Per spec #426 SC-10: Inject NESTED_OPENCODE_FATAL as a separate block
          // AFTER all other content in the first user message (not inside Session Triggers)
          if (nestedOpencodeBlock && firstUser.parts?.length) {
            firstUser.parts.push({ id: crypto.randomUUID(), sessionID: firstUser.info.sessionID, messageID: firstUser.info.id, type: "text", text: nestedOpencodeBlock });
          }

          // --- First-turn-only: Plugin diagnostics injection ---
          const diagnostics = collectDiagnostics(projectDir);
          const diagnosticBlock = buildDiagnosticBlock(diagnostics);
          if (diagnosticBlock && firstUser.parts?.length) {
            firstUser.parts.push({ id: crypto.randomUUID(), sessionID: firstUser.info.sessionID, messageID: firstUser.info.id, type: "text", text: diagnosticBlock });
          }

        }

        // --- Mark session as injected for first-turn detection ---
        // After all first-turn injections are applied, register the sessionID
        // so the Set-based isFirstTurn check returns false on subsequent turns.
        // Survives context reload because each new process starts with an empty Set.
        if (firstUserSessionID && isFirstTurn) {
          injectedFirstTurnSessions.add(firstUserSessionID);
        }

      // --- Per-turn: Strip synthetic mode-switch messages ---
      // Unconditional stripping: if text matches mode-switch boilerplate, set to "".
      const currentUser = output.messages.findLast(m => m.info?.role === 'user');
      if (currentUser) {
        for (const part of currentUser.parts) {
          if (part.type !== 'text') continue;
          if (!part.synthetic) continue;
          if (isModeSwitchSynthetic(part.text || '')) {
            part.text = '';
            part.synthetic = false;
          }
        }
      }

      // --- Per-turn: Secret redaction on ALL assistant messages ---
      const assistantMessages = output.messages.filter(m => m.info?.role === "assistant");
      for (const msg of assistantMessages) {
        if (!msg.parts?.length) continue;
        for (let i = 0; i < msg.parts.length; i++) {
          const part = msg.parts[i];
          if (part.type === "text" && part.text) {
            const redacted = redactSecrets(part.text);
            if (redacted !== part.text) {
              msg.parts[i] = { ...part, type: "text", text: redacted };
            }
          }
        }
      }

      // --- Per-turn: Git config mutation watchdog ---
      if (gitConfigBaseline) {
        try {
          const currentLocalConfig = execSync("git config --local --list", {
            cwd: projectDir,
            encoding: "utf8",
            input: "",
            timeout: 5000,
            stdio: ["pipe", "pipe", "pipe"],
          }).trim();

          const currentBaseline = captureGitConfigBaseline(projectDir);
          if (currentBaseline) {
            const configChanged = currentBaseline.configHash !== gitConfigBaseline.configHash;
            const localConfigChanged = currentBaseline.localConfigHash !== gitConfigBaseline.localConfigHash;

            if (configChanged || localConfigChanged) {
              const changedKeys = extractChangedSecurityKeys(baselineLocalConfig, currentLocalConfig);
              if (changedKeys.length > 0) {
                const mutationBlock = buildGitConfigMutationBlock(changedKeys);
                const nextUser = userMessages[userMessages.length - 1];
                if (nextUser?.parts?.length) {
                  nextUser.parts.push({ id: crypto.randomUUID(), sessionID: nextUser.info.sessionID, messageID: nextUser.info.id, type: "text", text: mutationBlock });
                }
                gitConfigBaseline = currentBaseline;
                baselineLocalConfig = currentLocalConfig;
              }
            }
          }
        } catch {
          // Git unavailable or config unreadable — skip watchdog
        }
      }

      // --- Per-turn: --no-verify detection REMOVED ---
      // Removed per SPEC-FIX #823: The unconditional --no-verify detection gate
      // contradicts the guidelines (000-critical-rules.md §Hook Output Is Binding
      // and §--no-verify Exception for Local-Only Repos) which state
      // that --no-verify is FORBIDDEN regardless of hook output content.
      // The 010-approval-gate.md Allowlist already governs when --no-verify is
      // permissible. This gate was producing Tier 1 violation warnings for
      // legitimate --no-verify usage (e.g., tag pushes blocked by the pre-push
      // hook false positive, structural branch pushes like issues-data), causing
      // repeated workflow failures.

      



    },
  };
}
