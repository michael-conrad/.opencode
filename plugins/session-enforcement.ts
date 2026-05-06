/**
 * Session Enforcement Plugin for OpenCode
 *
 * Injects session context into the LLM system prompt and enforces
 * skill invocation rules. Also detects bare issue references (#N)
 * and injects mandatory audit pipelines.
 *
 * Hook: system.transform — pushes English prose context (from session-init
 *   and PluginInput augmentations) into the LLM system prompt.
 * Hook: chat.messages.transform — injects skill enforcement content and
 *   bare issue pipeline directives into user messages.
 *
 * NO shell.env hook — env-loader.ts owns all bash environment injection.
 * NO parsing of session-init output — stdout goes verbatim to system prompt.
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

function buildNoVerifyBlockedBlock(): string {
  return `### No-Verify Commit Blocked

**Warning:** --no-verify is FORBIDDEN in repos with remotes. git commit --no-verify and git push --no-verify bypass git hooks that enforce repository safety. This is a Tier 1 mandate. Only permitted in local-only repos (zero remotes). Check git remote -v first. See 000-critical-rules.md for details on Git Configuration and Destructive Command Authorization.`;
}

function buildInlineWorkDetectedBlock(editToolNames: string[], dispatchFound: boolean): string {
  const editList = editToolNames.map(t => `- \`${t}\``).join("\n");
  const dispatchNote = dispatchFound
    ? "A sub-agent dispatch was found, but file edits occurred BEFORE the dispatch in this turn."
    : "No sub-agent dispatch (task tool) was found in this turn.";
  return `### Inline Work Detected

**Warning:** The orchestrator performed file operations without sub-agent dispatch evidence.

File-editing tool calls detected in this turn:
${editList}

${dispatchNote}

The orchestrator MUST be a pure router — all file modifications MUST be dispatched through divide-and-conquer sub-agents. See 000-critical-rules.md Inline Work. Exemptions: pair- branches, .issues/ file edits, simple-work single-file changes. If this is an exempt case, disregard this warning.`;
}

function buildEvidenceGateBlock(): string {
  return `### Evidence Gate

**Warning:** Issue closure attempted without verification evidence. A github_issue_write call with state=closed was detected, but no per-SC verification evidence table exists in recent assistant messages. Every issue closure requires a verification evidence table confirming each success criterion was met with a tool-call artifact. See 000-critical-rules.md Verification Dishonesty and verification-before-completion skill. If the closure is exempt (not_planned, duplicate, rollback-reopen), disregard this warning.`;
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

let cachedOutput: string | null = null;
let cacheTimestamp = 0;

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

async function runSessionInit(projectDir: string): Promise<string> {
  if (cachedOutput && Date.now() - cacheTimestamp < CACHE_TTL_MS) {
    return cachedOutput;
  }

  try {
    const stdout = execSync("./.opencode/tools/session-init", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    cachedOutput = stdout;
    cacheTimestamp = Date.now();

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

    cachedOutput = stdout;
    cacheTimestamp = Date.now();

    return stdout;
  }
}

let cachedIdentityOutput: string | null = null;
let identityCacheTimestamp = 0;

async function runSessionContextIdentity(projectDir: string): Promise<string> {
  if (cachedIdentityOutput && Date.now() - identityCacheTimestamp < CACHE_TTL_MS) {
    return cachedIdentityOutput;
  }

  try {
    const stdout = execSync("./.opencode/scripts/session_context_identity.py", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    cachedIdentityOutput = stdout;
    identityCacheTimestamp = Date.now();

    return stdout;
  } catch (err: any) {
    const stdout = err?.stdout?.toString().trim() ?? "";
    const stderr = err?.stderr?.toString().trim() ?? "";
    const exitCode = err?.status ?? 1;

    const isTimeout = err?.killed || err?.signal === "SIGTERM";

    if (!stdout || stdout.length === 0) {
      const errorMsg = isTimeout
        ? `session_context_identity.py timed out after 30s`
        : (stderr || "Script returned empty output");
      console.error(`[session-enforcement] session_context_identity.py: ${errorMsg}`);
      writeDiagnostic(projectDir, {
        source: "session_context_identity.py",
        level: "error",
        message: errorMsg,
        exitCode: isTimeout ? undefined : exitCode,
      });
      return "";
    }

    if (stderr) {
      writeDiagnostic(projectDir, {
        source: "session_context_identity.py",
        level: "warning",
        message: stderr,
        exitCode,
      });
    }

    cachedIdentityOutput = stdout;
    identityCacheTimestamp = Date.now();

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

interface ProjectMetadata {
  name: string;
  version: string;
  pythonVersion: string;
}

function readProjectMetadata(projectDir: string): ProjectMetadata | null {
  const pyprojectPath = path.join(projectDir, "pyproject.toml");
  if (!fs.existsSync(pyprojectPath)) {
    return null;
  }

  let name = "";
  let version = "";
  let inProjectSection = false;

  try {
    const content = fs.readFileSync(pyprojectPath, "utf8");
    for (const line of content.split("\n")) {
      const trimmed = line.trim();
      if (trimmed === "[project]") {
        inProjectSection = true;
        continue;
      }
      if (trimmed.startsWith("[") && trimmed.endsWith("]")) {
        inProjectSection = false;
        continue;
      }
      if (inProjectSection) {
        if (trimmed.startsWith("name")) {
          const eqIdx = trimmed.indexOf("=");
          if (eqIdx > 0) {
            name = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, "");
          }
        } else if (trimmed.startsWith("version")) {
          const eqIdx = trimmed.indexOf("=");
          if (eqIdx > 0) {
            version = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, "");
          }
        }
      }
    }
  } catch {
    return null;
  }

  if (!name) {
    return null;
  }

  let pythonVersion = "";
  const pythonVersionPath = path.join(projectDir, ".python-version");
  if (fs.existsSync(pythonVersionPath)) {
    try {
      pythonVersion = fs.readFileSync(pythonVersionPath, "utf8").trim();
    } catch {
      // Ignore read errors
    }
  }

  return { name, version: version || "0.1.0", pythonVersion };
}

function buildMetadataBlock(_projectDir: string): string {
  return "";
}

function buildGuidelineIndexBlock(_projectDir: string): string {
  return "";
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
 * Source attribution: CSO (Content Search Optimization) principles from
 * https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 * Description format: "Use when..." with triggering conditions, NOT workflow summaries.
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
        } else if (frontmatter.description && !frontmatter.description.startsWith("Use when")) {
          validationIssues.push("Description does not start with \"Use when\" — CSO requirement for trigger discovery");
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

**Fix template:** every SKILL.md MUST start with YAML frontmatter with name, description (starting with "Use when"), type, and license fields. See #601 for the original bug that motivated this validation.`;
}

function extractValue(sessionOutput: string | null, key: string): string | null {
  if (!sessionOutput) return null;
  const escapedKey = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const match = sessionOutput.match(new RegExp(`${escapedKey}=\\s*(\\S+)`));
  return match ? match[1] : null;
}

function buildIdentityEchoDirective(platform: string, owner: string, repo: string): string {
  return `Before doing anything else, echo your byline using the standard format:

Platform: ${platform}, Org: ${owner}, Repo: ${repo}
🤖 <AgentName> (<ModelId>) <status-icon> <status>`;
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

/**
 * Build a protected branch edit warning block for when files are edited
 * on dev/main without a worktree or pair- branch prefix.
 * 
 * This is the per-turn runtime guard — it fires AFTER each assistant turn
 * when git diff detects file changes on a protected branch. This is distinct
 * from the session-start trigger in session_context_triggers.py which only
 * checks once at session start.
 */
function buildProtectedBranchEditTrigger(changedFiles: string[], branch: string): string {
  const fileList = changedFiles.slice(0, 10).map(f => `\`${f}\``).join(", ");
  const moreFiles = changedFiles.length > 10 ? `, …and ${changedFiles.length - 10} more` : "";
  
  return `### Session Triggers

protected_branch_with_changes: ${changedFiles.length} file(s) changed on ${branch} branch without worktree or pair-mode prefix.
Changed: ${fileList}${moreFiles}
Process silently. Do NOT echo this trigger in chat output.`;
}

/**
 * Detect uncommitted file changes on the current branch via git diff.
 * Returns empty array if no changes or if git is unavailable.
 */
function detectUncommittedFileChanges(projectDir: string): string[] {
  try {
    const result = execSync("git diff --name-only", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
    if (!result) return [];
    return result.split("\n").filter(line => line.trim().length > 0);
  } catch {
    return [];
  }
}

/**
 * Get the current git branch name.
 * Returns null if git is unavailable.
 */
function getCurrentBranch(projectDir: string): string | null {
  try {
    return execSync("git branch --show-current", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim() || null;
  } catch {
    return null;
  }
}

/**
 * Check if the current branch is a protected branch (main/master/dev)
 * that should not have direct edits.
 */
function isProtectedBranch(branch: string): boolean {
  return branch === "main" || branch === "master" || branch === "dev";
}

/**
 * Check if the current branch is a pair-mode branch (starts with "pair-").
 * Pair-mode branches allow direct edits on the development directory.
 */
function isPairModeBranch(branch: string): boolean {
  return branch.startsWith("pair-");
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

      const scriptOutput = await runSessionInit(projectDir);
      if (scriptOutput) {
        output.system.push(scriptOutput);
      }

      // Inject worktree context when session is operating in a worktree
      const worktreeBlock = buildWorktreeBlock(input);
      if (worktreeBlock) {
        output.system.push(worktreeBlock);
      }

      // Inject frontmatter validation warning if any skills have broken frontmatter
      const warning = buildFrontmatterWarning(frontmatterErrors);
      if (warning) {
        output.system.push(warning);
      }

      // Inject identity section from session_context_identity.py
      const identityOutput = await runSessionContextIdentity(projectDir);
      if (identityOutput) {
        output.system.push(identityOutput);
      }
    },

    // Inject enforcement content into first user message (adapted from obra/superpowers)
      // AND detect bare #N issue references in last user message
      // AND inject identity-echo directive + trigger warnings into first user message
      // AND inject plugin diagnostics block into first user message
      //
      // FIRST-TURN GUARD: IDENTITY_ECHO, SESSION_TRIGGERS, EXTREMELY_IMPORTANT,
      // PLUGIN_DIAGNOSTICS, and IDENTITY_VALIDATION_FAILURE are injected ONLY on
      // the first turn of PRIMARY sessions (isFirstTurn && !isSubAgent). Sub-agent
      // sessions inherit context from their parent, so these blocks are redundant
      // and waste context window space (REQ-1/REQ-2).
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
        const isFirstTurn = userMessages.length === 1;

        // --- Sub-agent detection (REQ-1) ---
        // Determine if this session has a parentID (is a sub-agent session).
        // Extract sessionID from the first user message's info to look up
        // in the subAgentSessions Set populated by system.transform.
        // REQ-5: No disk persistence — subAgentSessions is process-scoped only.
        // REQ-4: Graceful degradation — if sessionID is unavailable, assume
        // primary session (isSubAgent = false) so full injections are applied.
        const sessionID = firstUser?.info?.sessionID;
        const isSubAgent = sessionID ? subAgentSessions.has(sessionID) : false;

        // --- First-turn-only PRIMARY sessions: Skip all first-turn injections
        //     for sub-agent sessions (isFirstTurn && !isSubAgent required) ---
        // REQ-2: Sub-agent sessions inherit parent context, making these blocks
        //         redundant. Gating them saves significant context window space.
        const shouldInjectFirstTurn = isFirstTurn && !isSubAgent;

        if (shouldInjectFirstTurn) {
          // --- First-turn-only: Identity-echo directive + trigger warnings ---
          const triggersOutput = await runSessionContextTriggers(projectDir);
          const knownPlatform = extractValue(cachedIdentityOutput, "github.platform");
          const knownOwner = extractValue(cachedIdentityOutput, "github.owner");
          const knownRepo = extractValue(cachedIdentityOutput, "github.repo");
          const knownIdentitySource = extractValue(cachedIdentityOutput, "github.identity_source");

          // Degraded mode: when identity_source is "none", we have no remote at all.
          // Platform is "local", owner/repo are "(none)". This is a valid operational state,
          // not an error. Skip the FATAL identity validation for local-only mode.
          const isLocalMode = knownPlatform === "local" || knownIdentitySource === "none";

          // Submodule mode: parent repo has zero remotes, owner/repo come from submodule.
          // Agent must NOT add remotes to the parent repo or push from the parent repo.
          const isSubmoduleMode = knownIdentitySource === "submodule";

          const identityBlock = buildIdentityEchoDirective(
            knownPlatform || "<platform>",
            knownOwner || "<owner>",
            knownRepo || "<repo>",
          );
          const triggerBlock = triggersOutput ? `### Session Triggers\n\n${triggersOutput}` : "";

          const echoParts: string[] = [];
          if (identityBlock) {
            echoParts.push(identityBlock);
          }
          if (triggerBlock) {
            echoParts.push(triggerBlock);
          }
          if (echoParts.length > 0 && firstUser.parts?.length) {
            firstUser.parts.unshift({ type: "text", text: echoParts.join("\n\n") });
          }

          // --- First-turn-only: Plugin diagnostics injection ---
          const diagnostics = collectDiagnostics(projectDir);
          const diagnosticBlock = buildDiagnosticBlock(diagnostics);
          if (diagnosticBlock && firstUser.parts?.length) {
            firstUser.parts.push({ type: "text", text: diagnosticBlock });
          }

          // --- First-turn-only: Identity echo validation ---
          if (isLocalMode) {
            // Local mode: identity values are "(none)" by design. Skip FATAL validation.
            // Emit a warning instead so the agent knows it's in local-only mode.
            const lastUser = userMessages[userMessages.length - 1];
            if (lastUser?.parts?.length) {
              lastUser.parts.push({
                type: "text",
                text: `### Local Mode\n\n**Warning:** Operating in local-only mode — no git remote configured.\n\n- github.platform: local\n- github.owner: (none)\n- github.repo: (none)\n- github.identity_source: none\n\nGitHub/GitBucket API calls are unavailable. Local issue tracking (.issues/) is available. Do NOT attempt to use GitHub MCP or GitBucket API tools — all issue operations route to local .issues/.`
              });
            }
          } else if (isSubmoduleMode) {
            const parentRemoteCount = gitConfigBaseline?.remoteCount ?? 0;
            const lastUser = userMessages[userMessages.length - 1];
            if (lastUser?.parts?.length) {
              lastUser.parts.push({
                type: "text",
                text: `### Local Mode\n\n**Warning:** Operating in submodule-local mode — parent repo has ${parentRemoteCount} remote(s).\n\n- github.identity_source: submodule\n- All remote git operations (fetch, pull, push, remote branch management) must run from inside the submodule directory — not the project root.\n- The parent repo has ZERO remotes by design.\n- github.owner and github.repo are from the submodule remote for API routing ONLY\n- GitHub MCP calls route to the submodule's repository\n- Local git operations (branch, commit, stash) on the parent repo are permitted\n- Do NOT push from the parent repo — there is no remote to push to.\n- Do NOT add remotes to the parent repo.`
              });
            }
          } else if (!knownPlatform || !knownOwner || !knownRepo) {
            const missing = [
              !knownPlatform ? "github.platform" : null,
              !knownOwner ? "github.owner" : null,
              !knownRepo ? "github.repo" : null,
            ].filter(Boolean).join(", ");

            const lastUser = userMessages[userMessages.length - 1];
            if (lastUser?.parts?.length) {
              lastUser.parts.push({
                type: "text",
                text: `### Identity Validation Failure\n\nFATAL ERROR: Session identity values are MISSING. HALT all operations immediately.\n\nMissing values: ${missing}\n\nIdentity validation cannot proceed without these values. Do NOT infer identity from repository names, file paths, or environment variables. Resolve the missing identity values before continuing any operations.`
              });
            }
          } else {
            const assistantMessages = output.messages.filter(m => m.info?.role === "assistant");
            if (assistantMessages.length > 0) {
              const firstAssistant = assistantMessages[0];
              const assistantText = firstAssistant.parts
                ?.filter(p => p.type === "text" && p.text)
                .map(p => p.text)
                .join(" ") || "";

              const echoMatch = assistantText.match(/Platform:\s*(\S+),\s*Org:\s*(\S+),\s*Repo:\s*(\S+)/);

              const lastUser = userMessages[userMessages.length - 1];

              if (!echoMatch) {
                if (lastUser?.parts?.length) {
                  lastUser.parts.push({
                    type: "text",
                    text: `### Identity Validation Failure\n\nFATAL ERROR: Your first message did not contain a valid identity echo. You MUST echo your platform identity before proceeding with ANY operations.\n\nExpected: Platform: ${knownPlatform}, Org: ${knownOwner}, Repo: ${knownRepo}\n\nHALT all operations. Echo the correct identity values above before continuing.`
                  });
                }
              } else {
                const [, echoPlatform, echoOwner, echoRepo] = echoMatch;
                if (echoPlatform !== knownPlatform || echoOwner !== knownOwner || echoRepo !== knownRepo) {
                  if (lastUser?.parts?.length) {
                    lastUser.parts.push({
                      type: "text",
                      text: `### Identity Validation Failure\n\nFATAL ERROR: Identity echo mismatch detected!\n\nYour echo: Platform: ${echoPlatform}, Org: ${echoOwner}, Repo: ${echoRepo}\nExpected: Platform: ${knownPlatform}, Org: ${knownOwner}, Repo: ${knownRepo}\n\nHALT all operations. These values do NOT match. Use ONLY the expected values above. Do NOT infer identity from repository names, file paths, or environment variables.`
                    });
                  }
                }
              }
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
                  nextUser.parts.push({ type: "text", text: mutationBlock });
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

      // --- Per-turn: --no-verify detection ---
      let hasRemotes: boolean;
      if (gitConfigBaseline) {
        hasRemotes = gitConfigBaseline.remoteCount > 0;
      } else {
        // Baseline capture failed — check remotes inline
        try {
          const remoteCheck = execSync("git remote -v", {
            cwd: projectDir,
            encoding: "utf8",
            input: "",
            timeout: 5000,
            stdio: ["pipe", "pipe", "pipe"],
          }).trim();
          hasRemotes = remoteCheck.length > 0;
        } catch {
          hasRemotes = false; // No remotes = local-only → permit --no-verify
        }
      }
      for (const msg of assistantMessages) {
        if (!msg.parts?.length) continue;
        for (const part of msg.parts) {
          if (part.type === "text" && part.text) {
            const noVerifyMatch = part.text.match(/(?:git\s+commit|git\s+push)\s+.*--no-verify/);
            if (noVerifyMatch && hasRemotes) {
              const blockedBlock = buildNoVerifyBlockedBlock();
              const nextUser = userMessages[userMessages.length - 1];
              if (nextUser?.parts?.length) {
                nextUser.parts.push({ type: "text", text: blockedBlock });
              }
              break;
            }
          }
        }
      }

      // --- Per-turn: Inline work detector (Gate 3) ---
      // Detect when the orchestrator performed file-editing tool calls without
      // a preceding sub-agent dispatch in the same turn. Exemptions: sub-agent
      // sessions, pair-* branches, .issues/ only changes.
      const currentBranchForInline = getCurrentBranch(projectDir);
      const isPairBranch = currentBranchForInline ? isPairModeBranch(currentBranchForInline) : false;
      if (!isSubAgent && !isPairBranch) {
        for (const msg of assistantMessages) {
          if (!msg.parts?.length) continue;
          const editToolNames: string[] = [];
          let dispatchFound = false;
          let dispatchIndex = -1;
          let issuesOnlyEdits = true;

          for (const part of msg.parts) {
            if (part.type === "text" && part.text) {
              // Detect sub-agent dispatch (task tool)
              if (part.text.includes("subagent_type") || part.text.includes('"task"') && part.text.includes("dispatch")) {
                dispatchFound = true;
                if (dispatchIndex === -1) dispatchIndex = msg.parts.indexOf(part);
              }
              // Detect file-editing tool calls
              const editMatch = part.text.match(/"name"\s*:\s*"(edit|write|create_or_update_file)"/);
              if (editMatch) {
                editToolNames.push(editMatch[1]);
                // Check if the edit targets .issues/ files
                const filePathMatch = part.text.match(/"filePath"\s*:\s*"([^"]+)"/);
                if (filePathMatch && !filePathMatch[1].startsWith(".issues/")) {
                  issuesOnlyEdits = false;
                }
              }
              // Also detect tool call patterns in assistant text (older format)
              const toolCallMatch = part.text.match(/(edit|write)\(filePath/);
              if (toolCallMatch) {
                editToolNames.push(toolCallMatch[1]);
                const filePathMatch = part.text.match(/filePath["']?\s*[:=]\s*["']([^"']+)/);
                if (filePathMatch && !filePathMatch[1].startsWith(".issues/")) {
                  issuesOnlyEdits = false;
                }
              }
            }
          }

          if (editToolNames.length > 0 && !issuesOnlyEdits) {
            // If dispatch was found, check if edits came before the dispatch
            const editsBeforeDispatch = dispatchFound && dispatchIndex > -1
              ? editToolNames.length > 0 // edits exist, check if any were before dispatch
              : true;

            if (!dispatchFound || editsBeforeDispatch) {
              const block = buildInlineWorkDetectedBlock(editToolNames, dispatchFound);
              const nextUser = userMessages[userMessages.length - 1];
              if (nextUser?.parts?.length) {
                nextUser.parts.push({ type: "text", text: block });
              }
            }
          }
        }
      }

      // --- Per-turn: Evidence gate (Gate 4) ---
      // Detect issue closure attempts without verification evidence table.
      // Exemptions: not_planned, duplicate, rollback-reopen state reasons.
      for (const msg of assistantMessages) {
        if (!msg.parts?.length) continue;
        for (const part of msg.parts) {
          if (part.type === "text" && part.text) {
            // Detect github_issue_write with state=closed
            const closureMatch = part.text.match(/state.*closed|state.*:.*"closed"/i);
            if (closureMatch) {
              // Check for exempt state reasons
              const exemptReason = part.text.match(/state_reason.*(?:not_planned|duplicate)/i);
              if (!exemptReason) {
                // Check if a verification evidence table exists in recent messages
                const allAssistantText = assistantMessages
                  .map(m => m.parts?.filter(p => p.type === "text" && p.text).map(p => p.text).join(" ") || "")
                  .join(" ");
                const hasEvidence = allAssistantText.includes("PASS") &&
                  (allAssistantText.includes("Success Criteria") || allAssistantText.includes("verification") || allAssistantText.includes("evidence"));

                if (!hasEvidence) {
                  // Also check for rollback-reopen marker
                  const rollbackReopen = part.text.match(/\[ROLLBACK-REOPEN\]/i);
                  if (!rollbackReopen) {
                    const block = buildEvidenceGateBlock();
                    const nextUser = userMessages[userMessages.length - 1];
                    if (nextUser?.parts?.length) {
                      nextUser.parts.push({ type: "text", text: block });
                    }
                  }
                }
              }
            }
          }
        }
      }

      // --- Per-turn: Protected branch edit guard ---
      // After each assistant turn, check if files were edited on dev/main
      // without a worktree or pair- branch prefix. If so, inject warning.
      const currentBranch = getCurrentBranch(projectDir);
      if (currentBranch && isProtectedBranch(currentBranch)) {
        const worktreeDir = input?.worktree || "";
        const inWorktree = worktreeDir && worktreeDir !== projectDir;
        
        if (!inWorktree && !isPairModeBranch(currentBranch)) {
          const changedFiles = detectUncommittedFileChanges(projectDir);
          if (changedFiles.length > 0) {
            const warning = buildProtectedBranchEditTrigger(changedFiles, currentBranch);
            const lastAssistant = assistantMessages[assistantMessages.length - 1];
            if (lastAssistant?.parts?.length) {
              lastAssistant.parts.push({ type: "text", text: warning });
            }
          }
        }
      }
    },
  };
}
