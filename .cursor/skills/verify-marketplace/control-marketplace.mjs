#!/usr/bin/env node
/**
 * Drive the duyet/codex-claude-plugins marketplace pack.
 * There is no hosted web UI; the user-facing product is plugin catalogs,
 * manifests, and documented install paths for Claude Code, Codex,
 * Grok Build, and Grok Bot.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const SCRIPT_PATH = fileURLToPath(import.meta.url);
const SKILL_DIR = path.dirname(SCRIPT_PATH);
const USAGE_EXIT = 2;
const FAIL_EXIT = 1;
const OK_EXIT = 0;

const MARKETPLACE_FILES = {
  root: "marketplace.json",
  claude: path.join(".claude-plugin", "marketplace.json"),
  codex: path.join(".agents", "plugins", "marketplace.json"),
  grok: path.join(".grok-plugin", "marketplace.json"),
};

const CLAUDE_INSTALL_NEEDLES = [
  {
    id: "readme-marketplace-add",
    file: "README.md",
    needle: "/plugin marketplace add duyet/codex-claude-plugins",
  },
  {
    id: "readme-plugin-install",
    file: "README.md",
    needle: "/plugin install ",
  },
  {
    id: "readme-skills-cli",
    file: "README.md",
    needle: "npx skills add duyet/codex-claude-plugins",
  },
  {
    id: "readme-settings-json",
    file: "README.md",
    needle: "extraKnownMarketplaces",
  },
];

const CODEX_INSTALL_NEEDLES = [
  {
    id: "readme-codex-marketplace",
    file: "README.md",
    needle: ".agents/plugins/marketplace.json",
  },
  {
    id: "contributing-codex-marketplace",
    file: "CONTRIBUTING.md",
    needle: ".agents/plugins/marketplace.json",
  },
];

const GROK_INSTALL_NEEDLES = [
  {
    id: "readme-grok-marketplace-add",
    file: "README.md",
    needle: "grok plugin marketplace add duyet/codex-claude-plugins",
  },
  {
    id: "readme-grok-plugin-install",
    file: "README.md",
    needle: "grok plugin install ",
  },
  {
    id: "readme-grok-marketplace-file",
    file: "README.md",
    needle: ".grok-plugin/marketplace.json",
  },
  {
    id: "readme-grok-logo",
    file: "README.md",
    needle: "assets/logo.svg",
  },
  {
    id: "contributing-grok-marketplace",
    file: "CONTRIBUTING.md",
    needle: ".grok-plugin/marketplace.json",
  },
];

const DOCS_NEEDLES = [
  {
    id: "contributing-validate",
    file: "CONTRIBUTING.md",
    needle: "scripts/validate-plugins.sh",
  },
  {
    id: "claude-md-validate",
    file: "CLAUDE.md",
    needle: "scripts/validate-plugins.sh",
  },
  {
    id: "claude-md-claude-manifest",
    file: "CLAUDE.md",
    needle: ".claude-plugin/plugin.json",
  },
  {
    id: "claude-md-codex-manifest",
    file: "CLAUDE.md",
    needle: ".codex-plugin/plugin.json",
  },
  {
    id: "claude-md-grok-manifest",
    file: "CLAUDE.md",
    needle: ".grok-plugin/plugin.json",
  },
  {
    id: "claude-md-grok-build-manifest",
    file: "CLAUDE.md",
    needle: ".grok-build-plugin/plugin.json",
  },
  {
    id: "claude-md-grok-marketplace",
    file: "CLAUDE.md",
    needle: ".grok-plugin/marketplace.json",
  },
];

const COMMANDS = [
  "doctor",
  "info",
  "list",
  "inspect",
  "validate",
  "check-docs",
  "check-install",
  "install-antigravity",
  "prove",
  "cleanup",
  "map",
  "help",
];

function main(argv) {
  const parsed = parseArgs(argv);
  if (parsed.flags.version) {
    writeOutput(parsed, {
      ok: true,
      command: "version",
      version: "1.1.0",
      skill: "verify-marketplace",
    });
    return OK_EXIT;
  }

  const command = parsed.command ?? "help";
  if (parsed.flags.help || command === "help" || command === "") {
    return runHelp(parsed);
  }
  if (!COMMANDS.includes(command)) {
    writeError(`Unknown command: ${command}`);
    writeError(`Known commands: ${COMMANDS.join(", ")}`);
    writeError("Run with --help for usage.");
    return USAGE_EXIT;
  }

  try {
    switch (command) {
      case "doctor":
        return runDoctor(parsed);
      case "info":
        return runInfo(parsed);
      case "list":
        return runList(parsed);
      case "inspect":
        return runInspect(parsed);
      case "validate":
        return runValidate(parsed);
      case "check-docs":
        return runCheckDocs(parsed);
      case "check-install":
        return runCheckInstall(parsed);
      case "install-antigravity":
        return runInstallAntigravity(parsed);
      case "prove":
        return runProve(parsed);
      case "cleanup":
        return runCleanup(parsed);
      case "map":
        return runMap(parsed);
      case "help":
        return runHelp(parsed);
      default: {
        const _exhaustive = command;
        writeError(`Unhandled command: ${_exhaustive}`);
        return USAGE_EXIT;
      }
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    writeOutput(parsed, {
      ok: false,
      command,
      error: message,
    });
    return FAIL_EXIT;
  }
}

function parseArgs(argv) {
  const flags = {};
  const positionals = [];
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--") {
      positionals.push(...argv.slice(i + 1));
      break;
    }
    if (arg === "-h") {
      flags.help = true;
      continue;
    }
    if (!arg.startsWith("--")) {
      positionals.push(arg);
      continue;
    }
    const stripped = arg.slice(2);
    const eq = stripped.indexOf("=");
    const key = camelFlag(eq === -1 ? stripped : stripped.slice(0, eq));
    if (eq !== -1) {
      flags[key] = stripped.slice(eq + 1);
      continue;
    }
    const booleanFlags = new Set([
      "json",
      "help",
      "dryRun",
      "apply",
      "strict",
      "version",
      "force",
      "missingReadme",
      "missingCodex",
      "missingGrok",
      "hasAntigravity",
      "hasGrok",
      "hasGrokBuild",
    ]);
    if (booleanFlags.has(key)) {
      flags[key] = true;
      continue;
    }
    const next = argv[i + 1];
    if (next && !next.startsWith("-")) {
      flags[key] = next;
      i += 1;
    } else {
      flags[key] = true;
    }
  }
  if (flags.format === "json") {
    flags.json = true;
  }
  return {
    command: positionals[0],
    args: positionals.slice(1),
    flags,
  };
}

function camelFlag(name) {
  return name.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
}

function resolveRepoRoot(parsed) {
  if (parsed.flags.repo) {
    const resolved = path.resolve(parsed.flags.repo);
    assertRepoRoot(resolved);
    return resolved;
  }
  const fromScript = path.resolve(SKILL_DIR, "..", "..", "..");
  if (isRepoRoot(fromScript)) {
    return fromScript;
  }
  let dir = process.cwd();
  while (true) {
    if (isRepoRoot(dir)) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) {
      break;
    }
    dir = parent;
  }
  throw new Error(
    "Could not find marketplace repo root (need marketplace.json and .claude-plugin/marketplace.json). Pass --repo <path>.",
  );
}

function isRepoRoot(dir) {
  return (
    fs.existsSync(path.join(dir, MARKETPLACE_FILES.root)) &&
    fs.existsSync(path.join(dir, MARKETPLACE_FILES.claude))
  );
}

function assertRepoRoot(dir) {
  if (!isRepoRoot(dir)) {
    throw new Error(`Not a marketplace repo root: ${dir}`);
  }
}

function loadJson(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");
  try {
    return JSON.parse(raw);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Invalid JSON: ${filePath}: ${message}`);
  }
}

function tryLoadJson(filePath) {
  if (!fs.existsSync(filePath)) {
    return { ok: false, error: `missing: ${filePath}` };
  }
  try {
    return { ok: true, value: loadJson(filePath), path: filePath };
  } catch (error) {
    return {
      ok: false,
      error: error instanceof Error ? error.message : String(error),
      path: filePath,
    };
  }
}

function pluginDirectories(repoRoot) {
  return fs
    .readdirSync(repoRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .filter((name) => {
      const claude = path.join(repoRoot, name, ".claude-plugin", "plugin.json");
      const codex = path.join(repoRoot, name, ".codex-plugin", "plugin.json");
      const grok = path.join(repoRoot, name, ".grok-plugin", "plugin.json");
      const grokBuild = path.join(
        repoRoot,
        name,
        ".grok-build-plugin",
        "plugin.json",
      );
      return (
        fs.existsSync(claude) ||
        fs.existsSync(codex) ||
        fs.existsSync(grok) ||
        fs.existsSync(grokBuild)
      );
    })
    .sort();
}

function pluginRecord(repoRoot, name) {
  const dir = path.join(repoRoot, name);
  const claudePath = path.join(dir, ".claude-plugin", "plugin.json");
  const codexPath = path.join(dir, ".codex-plugin", "plugin.json");
  const antigravityPath = path.join(dir, ".antigravity-plugin", "plugin.json");
  const grokPath = path.join(dir, ".grok-plugin", "plugin.json");
  const grokBuildPath = path.join(dir, ".grok-build-plugin", "plugin.json");
  const claude = fs.existsSync(claudePath) ? loadJson(claudePath) : null;
  const codex = fs.existsSync(codexPath) ? loadJson(codexPath) : null;
  const antigravity = fs.existsSync(antigravityPath)
    ? loadJson(antigravityPath)
    : null;
  const grok = fs.existsSync(grokPath) ? loadJson(grokPath) : null;
  const grokBuild = fs.existsSync(grokBuildPath)
    ? loadJson(grokBuildPath)
    : null;
  const readme = fs.existsSync(path.join(dir, "README.md"));
  const claudeMd = fs.existsSync(path.join(dir, "CLAUDE.md"));
  return {
    name,
    dir,
    version:
      claude?.version ??
      codex?.version ??
      grok?.version ??
      grokBuild?.version ??
      null,
    description:
      claude?.description ??
      codex?.description ??
      grok?.description ??
      grokBuild?.description ??
      null,
    claude: Boolean(claude),
    codex: Boolean(codex),
    antigravity: Boolean(antigravity),
    grok: Boolean(grok),
    grokBuild: Boolean(grokBuild),
    readme,
    claudeMd,
    manifests: {
      claude: claude ? rel(repoRoot, claudePath) : null,
      codex: codex ? rel(repoRoot, codexPath) : null,
      antigravity: antigravity ? rel(repoRoot, antigravityPath) : null,
      grok: grok ? rel(repoRoot, grokPath) : null,
      grokBuild: grokBuild ? rel(repoRoot, grokBuildPath) : null,
    },
  };
}

function marketplaceNames(data) {
  const plugins = Array.isArray(data?.plugins) ? data.plugins : [];
  return plugins.map((plugin) => plugin?.name).filter(Boolean);
}

function grokSource(plugin) {
  const source = plugin?.source;
  if (typeof source === "string" && source.startsWith("./")) {
    return { ok: true, path: source };
  }
  if (source && typeof source === "object") {
    const pathValue = source.path;
    const local = source.type === "local" || source.source === "local";
    return {
      ok:
        local &&
        typeof pathValue === "string" &&
        pathValue.startsWith("./"),
      path: typeof pathValue === "string" ? pathValue : null,
    };
  }
  return { ok: false, path: null };
}

function grokLogoCheck(repoRoot, plugin) {
  const name = plugin?.name ?? "unknown";
  const logo = plugin?.logo;
  const source = grokSource(plugin);
  if (typeof logo !== "string" || !logo.trim()) {
    return {
      ok: false,
      detail: `${name}: Grok marketplace logo missing`,
    };
  }
  if (logo.startsWith("http://") || logo.startsWith("https://")) {
    return { ok: true, detail: `${name} remote logo ${logo}` };
  }
  if (!source.path) {
    return {
      ok: false,
      detail: `${name}: Grok logo ${JSON.stringify(logo)} has no source path`,
    };
  }
  const filePath = path.normalize(path.join(repoRoot, source.path, logo));
  const exists = fs.existsSync(filePath) && fs.statSync(filePath).isFile();
  return {
    ok: exists,
    detail: exists
      ? `${name} logo ${rel(repoRoot, filePath)}`
      : `${name}: Grok logo missing: ${JSON.stringify(logo)}`,
  };
}

function rel(repoRoot, filePath) {
  return path.relative(repoRoot, filePath) || ".";
}

function fileContains(repoRoot, relativePath, needle) {
  const filePath = path.join(repoRoot, relativePath);
  if (!fs.existsSync(filePath)) {
    return { ok: false, detail: `missing file ${relativePath}` };
  }
  const text = fs.readFileSync(filePath, "utf8");
  if (text.includes(needle)) {
    return { ok: true, detail: `${relativePath} contains ${JSON.stringify(needle)}` };
  }
  return {
    ok: false,
    detail: `${relativePath} is missing ${JSON.stringify(needle)}`,
  };
}

function collectMarketplaces(repoRoot) {
  const result = {};
  for (const [key, relative] of Object.entries(MARKETPLACE_FILES)) {
    result[key] = tryLoadJson(path.join(repoRoot, relative));
    if (result[key].ok) {
      result[key].relative = relative;
      result[key].names = marketplaceNames(result[key].value);
    } else {
      result[key].relative = relative;
      result[key].names = [];
    }
  }
  return result;
}

function runDoctor(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const checks = [];
  const python = spawnSync("python3", ["--version"], { encoding: "utf8" });
  checks.push({
    id: "python3",
    ok: python.status === 0,
    detail:
      python.status === 0
        ? python.stdout.trim() || python.stderr.trim()
        : "python3 is required to run scripts/validate-plugins.sh",
  });
  checks.push({
    id: "node",
    ok: true,
    detail: process.version,
  });
  const validateScript = path.join(repoRoot, "scripts", "validate-plugins.sh");
  checks.push({
    id: "validate-script",
    ok: fs.existsSync(validateScript),
    detail: fs.existsSync(validateScript)
      ? rel(repoRoot, validateScript)
      : "scripts/validate-plugins.sh is missing",
  });
  for (const [key, relative] of Object.entries(MARKETPLACE_FILES)) {
    const loaded = tryLoadJson(path.join(repoRoot, relative));
    checks.push({
      id: `marketplace-${key}`,
      ok: loaded.ok,
      detail: loaded.ok
        ? `${relative} parses (${marketplaceNames(loaded.value).length} plugins)`
        : loaded.error,
    });
  }
  const plugins = pluginDirectories(repoRoot);
  checks.push({
    id: "plugin-dirs",
    ok: plugins.length > 0,
    detail: `${plugins.length} plugin directories with Claude, Codex, or Grok manifests`,
  });
  const skillCli = path.join(SKILL_DIR, "control-marketplace.mjs");
  checks.push({
    id: "lever",
    ok: fs.existsSync(skillCli),
    detail: rel(repoRoot, skillCli),
  });
  const featureMap = path.join(SKILL_DIR, "references", "features", "README.md");
  checks.push({
    id: "feature-map",
    ok: fs.existsSync(featureMap),
    detail: fs.existsSync(featureMap)
      ? rel(repoRoot, featureMap)
      : "references/features/README.md is missing",
  });
  return finishChecks(parsed, "doctor", checks, {
    repoRoot,
    plugins: plugins.length,
  });
}

function runInfo(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const marketplaces = collectMarketplaces(repoRoot);
  const plugins = pluginDirectories(repoRoot).map((name) =>
    pluginRecord(repoRoot, name),
  );
  const payload = {
    ok:
      marketplaces.root.ok &&
      marketplaces.claude.ok &&
      marketplaces.codex.ok &&
      marketplaces.grok.ok,
    command: "info",
    repoRoot,
    marketplaceName: marketplaces.root.value?.name ?? null,
    counts: {
      pluginDirs: plugins.length,
      rootMarketplace: marketplaces.root.names.length,
      claudeMarketplace: marketplaces.claude.names.length,
      codexMarketplace: marketplaces.codex.names.length,
      grokMarketplace: marketplaces.grok.names.length,
      grok: plugins.filter((plugin) => plugin.grok).length,
      grokBuild: plugins.filter((plugin) => plugin.grokBuild).length,
      antigravity: plugins.filter((plugin) => plugin.antigravity).length,
      missingReadme: plugins.filter((plugin) => !plugin.readme).length,
    },
    surfaces: {
      claudeCode: true,
      codex: true,
      antigravity: plugins.some((plugin) => plugin.antigravity),
      grokBuild:
        marketplaces.grok.ok && plugins.some((plugin) => plugin.grokBuild),
      grokBot: marketplaces.grok.ok && plugins.some((plugin) => plugin.grok),
    },
    gaps: {
      missingFromCodex: sortedDiff(
        plugins.map((plugin) => plugin.name),
        marketplaces.codex.names,
      ),
      extraInCodex: sortedDiff(
        marketplaces.codex.names,
        plugins.map((plugin) => plugin.name),
      ),
      missingFromGrok: sortedDiff(
        plugins.map((plugin) => plugin.name),
        marketplaces.grok.names,
      ),
      extraInGrok: sortedDiff(
        marketplaces.grok.names,
        plugins.map((plugin) => plugin.name),
      ),
    },
    hostedUi: false,
  };
  writeOutput(parsed, payload);
  return payload.ok ? OK_EXIT : FAIL_EXIT;
}

function runList(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  let plugins = pluginDirectories(repoRoot).map((name) =>
    pluginRecord(repoRoot, name),
  );
  if (parsed.flags.missingReadme) {
    plugins = plugins.filter((plugin) => !plugin.readme);
  }
  if (parsed.flags.missingCodex) {
    plugins = plugins.filter((plugin) => !plugin.codex);
  }
  if (parsed.flags.missingGrok) {
    plugins = plugins.filter((plugin) => !plugin.grok || !plugin.grokBuild);
  }
  if (parsed.flags.hasAntigravity) {
    plugins = plugins.filter((plugin) => plugin.antigravity);
  }
  if (parsed.flags.hasGrok) {
    plugins = plugins.filter((plugin) => plugin.grok);
  }
  if (parsed.flags.hasGrokBuild) {
    plugins = plugins.filter((plugin) => plugin.grokBuild);
  }
  const payload = {
    ok: true,
    command: "list",
    repoRoot,
    count: plugins.length,
    plugins,
  };
  writeOutput(parsed, payload);
  return OK_EXIT;
}

function runInspect(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const names = parsed.args;
  if (names.length === 0) {
    writeError("inspect requires at least one plugin name.");
    return USAGE_EXIT;
  }
  const marketplaces = collectMarketplaces(repoRoot);
  const plugins = names.map((name) => {
    const dir = path.join(repoRoot, name);
    if (!fs.existsSync(dir)) {
      return { name, ok: false, error: `directory missing: ${name}` };
    }
    const record = pluginRecord(repoRoot, name);
    const marketplaceRows = {};
    for (const [key, loaded] of Object.entries(marketplaces)) {
      const row = (loaded.value?.plugins ?? []).find(
        (plugin) => plugin?.name === name,
      );
      marketplaceRows[key] = row ?? null;
    }
    return {
      ok: true,
      ...record,
      marketplaceRows,
    };
  });
  const payload = {
    ok: plugins.every((plugin) => plugin.ok),
    command: "inspect",
    repoRoot,
    plugins,
  };
  writeOutput(parsed, payload);
  return payload.ok ? OK_EXIT : FAIL_EXIT;
}

function runValidate(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const script = path.join(repoRoot, "scripts", "validate-plugins.sh");
  if (!fs.existsSync(script)) {
    throw new Error("scripts/validate-plugins.sh is missing");
  }
  const result = spawnSync("bash", [script], {
    cwd: repoRoot,
    encoding: "utf8",
  });
  const output = `${result.stdout ?? ""}${result.stderr ?? ""}`;
  const failedLabels = [
    ...output.matchAll(/^❌ (.+)$/gm),
  ].map((match) => match[1]);
  const passedLabels = [
    ...output.matchAll(/^✅ (.+)$/gm),
  ].map((match) => match[1]);
  const payload = {
    ok: result.status === 0,
    command: "validate",
    repoRoot,
    exitCode: result.status,
    passed: passedLabels,
    failed: failedLabels,
    output,
  };
  writeOutput(parsed, payload);
  return payload.ok ? OK_EXIT : FAIL_EXIT;
}

function runCheckDocs(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const checks = [];
  for (const spec of [
    ...CLAUDE_INSTALL_NEEDLES,
    ...CODEX_INSTALL_NEEDLES,
    ...GROK_INSTALL_NEEDLES,
    ...DOCS_NEEDLES,
  ]) {
    const found = fileContains(repoRoot, spec.file, spec.needle);
    checks.push({
      id: spec.id,
      ok: found.ok,
      detail: found.detail,
    });
  }
  const plugins = pluginDirectories(repoRoot).map((name) =>
    pluginRecord(repoRoot, name),
  );
  const missingReadme = plugins.filter((plugin) => !plugin.readme);
  checks.push({
    id: "plugin-readmes",
    ok: parsed.flags.strict ? missingReadme.length === 0 : true,
    severity: missingReadme.length ? "warn" : "info",
    detail:
      missingReadme.length === 0
        ? "every plugin directory has README.md"
        : `missing README.md: ${missingReadme.map((plugin) => plugin.name).join(", ")}`,
    plugins: missingReadme.map((plugin) => plugin.name),
  });
  return finishChecks(parsed, "check-docs", checks, { repoRoot });
}

function runCheckInstall(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const surface = parsed.flags.surface ?? "all";
  const allowed = new Set(["all", "claude", "codex", "antigravity", "grok"]);
  if (!allowed.has(surface)) {
    writeError(`Unknown --surface ${surface}. Use claude|codex|antigravity|grok|all.`);
    return USAGE_EXIT;
  }
  const want = (name) => surface === "all" || surface === name;
  const marketplaces = collectMarketplaces(repoRoot);
  const plugins = pluginDirectories(repoRoot);
  const checks = [];

  if (want("claude")) {
    checks.push({
      id: "claude-marketplace-parses",
      ok: marketplaces.claude.ok,
      detail: marketplaces.claude.ok
        ? MARKETPLACE_FILES.claude
        : marketplaces.claude.error,
    });
    const claudePlugins = marketplaces.claude.value?.plugins ?? [];
    for (const plugin of claudePlugins) {
      const source = plugin?.source;
      const sourceOk =
        typeof source === "string" &&
        source.startsWith("./") &&
        fs.existsSync(path.join(repoRoot, source));
      checks.push({
        id: `claude-source-${plugin?.name ?? "unknown"}`,
        ok: sourceOk,
        detail: sourceOk
          ? `${plugin.name} source ${source}`
          : `${plugin?.name}: Claude source missing or invalid: ${JSON.stringify(source)}`,
      });
    }
    const rootPlugins = marketplaces.root.value?.plugins ?? [];
    const marketplaceName = marketplaces.root.value?.name;
    for (const plugin of rootPlugins) {
      const expected = `${plugin?.name}@${marketplaceName}`;
      checks.push({
        id: `root-id-${plugin?.name ?? "unknown"}`,
        ok: plugin?.id === expected,
        detail:
          plugin?.id === expected
            ? plugin.id
            : `${plugin?.name}: expected id ${expected}, got ${JSON.stringify(plugin?.id)}`,
      });
    }
    for (const spec of CLAUDE_INSTALL_NEEDLES) {
      const found = fileContains(repoRoot, spec.file, spec.needle);
      checks.push({ id: spec.id, ok: found.ok, detail: found.detail });
    }
  }

  if (want("codex")) {
    checks.push({
      id: "codex-marketplace-parses",
      ok: marketplaces.codex.ok,
      detail: marketplaces.codex.ok
        ? MARKETPLACE_FILES.codex
        : marketplaces.codex.error,
    });
    const missingFromCodex = sortedDiff(plugins, marketplaces.codex.names);
    const extraInCodex = sortedDiff(marketplaces.codex.names, plugins);
    checks.push({
      id: "codex-marketplace-names",
      ok: missingFromCodex.length === 0 && extraInCodex.length === 0,
      detail:
        missingFromCodex.length === 0 && extraInCodex.length === 0
          ? "Codex marketplace names match plugin directories"
          : `missingFromCodex=${JSON.stringify(missingFromCodex)} extraInCodex=${JSON.stringify(extraInCodex)}`,
      missingFromCodex,
      extraInCodex,
    });
    const codexPlugins = marketplaces.codex.value?.plugins ?? [];
    for (const plugin of codexPlugins) {
      const sourcePath = plugin?.source?.path;
      const sourceOk =
        plugin?.source?.source === "local" &&
        typeof sourcePath === "string" &&
        sourcePath.startsWith("./") &&
        fs.existsSync(path.join(repoRoot, sourcePath));
      checks.push({
        id: `codex-source-${plugin?.name ?? "unknown"}`,
        ok: sourceOk,
        detail: sourceOk
          ? `${plugin.name} source ${sourcePath}`
          : `${plugin?.name}: Codex source missing or invalid: ${JSON.stringify(plugin?.source)}`,
      });
    }
    for (const spec of CODEX_INSTALL_NEEDLES) {
      const found = fileContains(repoRoot, spec.file, spec.needle);
      checks.push({ id: spec.id, ok: found.ok, detail: found.detail });
    }
  }

  if (want("antigravity")) {
    const antigravity = plugins
      .map((name) => pluginRecord(repoRoot, name))
      .filter((plugin) => plugin.antigravity);
    checks.push({
      id: "antigravity-plugins",
      ok: true,
      detail:
        antigravity.length === 0
          ? "no .antigravity-plugin manifests"
          : antigravity.map((plugin) => plugin.name).join(", "),
      plugins: antigravity.map((plugin) => plugin.name),
    });
    const installScript = path.join(repoRoot, "scripts", "install-antigravity.sh");
    checks.push({
      id: "antigravity-install-script",
      ok: fs.existsSync(installScript),
      detail: fs.existsSync(installScript)
        ? rel(repoRoot, installScript)
        : "scripts/install-antigravity.sh is missing",
    });
  }

  if (want("grok")) {
    checks.push({
      id: "grok-marketplace-parses",
      ok: marketplaces.grok.ok,
      detail: marketplaces.grok.ok
        ? MARKETPLACE_FILES.grok
        : marketplaces.grok.error,
    });
    const records = plugins.map((name) => pluginRecord(repoRoot, name));
    const missingGrokBot = records
      .filter((plugin) => !plugin.grok)
      .map((plugin) => plugin.name);
    const missingGrokBuild = records
      .filter((plugin) => !plugin.grokBuild)
      .map((plugin) => plugin.name);
    checks.push({
      id: "grok-bot",
      ok: marketplaces.grok.ok && missingGrokBot.length === 0,
      available: marketplaces.grok.ok,
      detail:
        marketplaces.grok.ok && missingGrokBot.length === 0
          ? `${MARKETPLACE_FILES.grok} and .grok-plugin/plugin.json on every plugin`
          : `Grok Bot missing: marketplaceOk=${marketplaces.grok.ok} missingManifests=${JSON.stringify(missingGrokBot)}`,
    });
    checks.push({
      id: "grok-build",
      ok: missingGrokBuild.length === 0,
      available: missingGrokBuild.length === 0,
      detail:
        missingGrokBuild.length === 0
          ? ".grok-build-plugin/plugin.json on every plugin"
          : `missing Grok Build manifests: ${JSON.stringify(missingGrokBuild)}`,
    });
    const missingFromGrok = sortedDiff(plugins, marketplaces.grok.names);
    const extraInGrok = sortedDiff(marketplaces.grok.names, plugins);
    checks.push({
      id: "grok-marketplace-names",
      ok: missingFromGrok.length === 0 && extraInGrok.length === 0,
      detail:
        missingFromGrok.length === 0 && extraInGrok.length === 0
          ? "Grok marketplace names match plugin directories"
          : `missingFromGrok=${JSON.stringify(missingFromGrok)} extraInGrok=${JSON.stringify(extraInGrok)}`,
      missingFromGrok,
      extraInGrok,
    });
    const grokPlugins = marketplaces.grok.value?.plugins ?? [];
    for (const plugin of grokPlugins) {
      const source = grokSource(plugin);
      const absSource =
        source.path && source.path.startsWith("./")
          ? path.join(repoRoot, source.path)
          : null;
      const sourceOk = source.ok && Boolean(absSource) && fs.existsSync(absSource);
      checks.push({
        id: `grok-source-${plugin?.name ?? "unknown"}`,
        ok: sourceOk,
        detail: sourceOk
          ? `${plugin.name} source ${source.path}`
          : `${plugin?.name}: Grok source missing or invalid: ${JSON.stringify(plugin?.source)}`,
      });
      const logo = grokLogoCheck(repoRoot, plugin);
      checks.push({
        id: `grok-logo-${plugin?.name ?? "unknown"}`,
        ok: logo.ok,
        detail: logo.detail,
      });
    }
    for (const spec of GROK_INSTALL_NEEDLES) {
      const found = fileContains(repoRoot, spec.file, spec.needle);
      checks.push({ id: spec.id, ok: found.ok, detail: found.detail });
    }
  }

  return finishChecks(parsed, "check-install", checks, {
    repoRoot,
    surface,
  });
}

function runInstallAntigravity(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const dryRun = !parsed.flags.apply || Boolean(parsed.flags.dryRun);
  const pluginFilter = parsed.flags.plugin ?? parsed.args[0] ?? "all";
  const defaultTarget = path.join(os.homedir(), ".gemini", "config", "plugins");
  const target = parsed.flags.target
    ? path.resolve(parsed.flags.target)
    : defaultTarget;
  const plugins = pluginDirectories(repoRoot)
    .map((name) => pluginRecord(repoRoot, name))
    .filter((plugin) => plugin.antigravity)
    .filter((plugin) => pluginFilter === "all" || plugin.name === pluginFilter);

  if (pluginFilter !== "all" && plugins.length === 0) {
    throw new Error(`No Antigravity plugin named ${pluginFilter}`);
  }

  const plan = plugins.map((plugin) => {
    const manifest = path.join(
      plugin.dir,
      ".antigravity-plugin",
      "plugin.json",
    );
    const data = loadJson(manifest);
    const links = [{ from: manifest, to: path.join(target, plugin.name, "plugin.json") }];
    for (const key of ["skills", "commands", "hooks", "mcpServers", "apps", "agents"]) {
      const value = data[key];
      if (typeof value === "string" && value.startsWith("./")) {
        links.push({
          from: path.resolve(plugin.dir, value),
          to: path.join(target, plugin.name, key),
        });
      }
    }
    return { plugin: plugin.name, links };
  });

  if (!dryRun && target === defaultTarget && !parsed.flags.force) {
    throw new Error(
      "Refusing to write $HOME/.gemini/config/plugins. Pass --target <dir> for a disposable install, or --force with --apply.",
    );
  }

  const written = [];
  if (!dryRun) {
    for (const item of plan) {
      fs.mkdirSync(path.join(target, item.plugin), { recursive: true });
      for (const link of item.links) {
        fs.mkdirSync(path.dirname(link.to), { recursive: true });
        fs.symlinkSync(link.from, link.to);
        written.push(link.to);
      }
    }
  }

  const payload = {
    ok: true,
    command: "install-antigravity",
    dryRun,
    repoRoot,
    target,
    skippedWrite: dryRun,
    plugins: plan.map((item) => item.plugin),
    plan,
    written,
  };
  writeOutput(parsed, payload);
  return OK_EXIT;
}

function runProve(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const feature = parsed.flags.feature ?? "marketplace-catalog";
  const outDir = path.resolve(
    parsed.flags.out ?? path.join(SKILL_DIR, "proof"),
  );
  fs.mkdirSync(outDir, { recursive: true });
  const startedAt = new Date().toISOString();
  const steps = proveSteps(feature);
  const results = [];
  let ok = true;
  for (const step of steps) {
    const childArgs = [...step.args];
    if (parsed.flags.json && !childArgs.includes("--json")) {
      childArgs.push("--json");
    }
    childArgs.push("--repo", repoRoot);
    const result = spawnSync(process.execPath, [SCRIPT_PATH, ...childArgs], {
      encoding: "utf8",
    });
    const stepOk = result.status === 0;
    ok = ok && stepOk;
    results.push({
      id: step.id,
      args: childArgs,
      invocation: portableInvocation(childArgs, repoRoot),
      ok: stepOk,
      exitCode: result.status,
      stdout: result.stdout,
      stderr: result.stderr,
    });
  }
  let skipFailure = null;
  if (feature === "grok-build-and-bot") {
    const grokStep = results.find((step) => step.id === "check-install-grok");
    const skipIds = grokSkipCheckIds(grokStep, repoRoot);
    if (skipIds === null || skipIds.length > 0) {
      ok = false;
      skipFailure = skipIds ?? ["unparseable-check-install-grok"];
      if (grokStep) {
        grokStep.ok = false;
      }
    }
  }
  const proof = {
    ok,
    command: "prove",
    feature,
    startedAt,
    finishedAt: new Date().toISOString(),
    repoRoot: ".",
    outDir: path.relative(repoRoot, outDir) || ".",
    steps: results.map((step) => ({
      id: step.id,
      ok: step.ok,
      exitCode: step.exitCode,
      invocation: portableInvocation(step.args, repoRoot),
    })),
    hostedUi: false,
    note: proofNote(feature),
    ...(skipFailure ? { skipFailure } : {}),
  };
  const jsonPath = path.join(outDir, "drive.json");
  const mdPath = path.join(outDir, "drive.md");
  fs.writeFileSync(`${jsonPath}.tmp`, `${JSON.stringify(proof, null, 2)}\n`);
  fs.renameSync(`${jsonPath}.tmp`, jsonPath);
  fs.writeFileSync(mdPath, renderProofMarkdown(proof, results, repoRoot));
  const transcriptPath = path.join(outDir, "drive.transcript.txt");
  fs.writeFileSync(
    transcriptPath,
    portableText(renderProofTranscript(results, repoRoot), repoRoot),
  );
  const payload = {
    ...proof,
    artifacts: {
      json: rel(repoRoot, jsonPath),
      markdown: rel(repoRoot, mdPath),
      transcript: rel(repoRoot, transcriptPath),
    },
  };
  writeOutput(parsed, payload);
  return ok ? OK_EXIT : FAIL_EXIT;
}

function proveSteps(feature) {
  switch (feature) {
    case "marketplace-catalog":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        { id: "info", args: ["info", "--json"] },
        { id: "list", args: ["list", "--json"] },
        {
          id: "check-install-claude",
          args: ["check-install", "--surface", "claude", "--json"],
        },
      ];
    case "plugin-manifests":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        { id: "list", args: ["list", "--json"] },
      ];
    case "claude-code-install":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        {
          id: "check-install-claude",
          args: ["check-install", "--surface", "claude", "--json"],
        },
      ];
    case "codex-install":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        {
          id: "check-install-codex",
          args: ["check-install", "--surface", "codex", "--json"],
        },
      ];
    case "docs-and-readme":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        { id: "check-docs", args: ["check-docs", "--json"] },
      ];
    case "validation-harness":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        { id: "validate", args: ["validate", "--json"] },
      ];
    case "grok-build-and-bot":
      return [
        { id: "doctor", args: ["doctor", "--json"] },
        { id: "info", args: ["info", "--json"] },
        { id: "list", args: ["list", "--json"] },
        {
          id: "check-install-grok",
          args: ["check-install", "--surface", "grok", "--json"],
        },
      ];
    default:
      throw new Error(
        `Unknown feature ${feature}. See references/features/README.md.`,
      );
  }
}

function proofNote(feature) {
  if (feature === "grok-build-and-bot") {
    return "This pack has no hosted web UI. Proof is Grok marketplace parse, per-plugin Grok Bot and Grok Build manifests, local source paths, and marketplace logo files.";
  }
  return "This pack has no hosted web UI. Proof is catalog parse, plugin inventory, and Claude marketplace source resolution.";
}

function proofWhatProved(proof, catalogSummary) {
  if (proof.feature === "marketplace-catalog") {
    return `The checkout is a marketplace plugin pack. Marketplace JSON parses, plugin directories are listable, and every Claude marketplace \`source\` resolves to a real folder. There is no web app to click; Claude Code install needles in README match files that exist on disk.${catalogSummary}`;
  }
  if (proof.feature === "grok-build-and-bot") {
    return `The checkout ships Grok Bot and Grok Build. \`.grok-plugin/marketplace.json\` parses, every plugin directory has \`.grok-plugin/plugin.json\` and \`.grok-build-plugin/plugin.json\`, marketplace sources resolve, and each marketplace logo path exists on disk. \`check-install --surface grok\` does not report skip.${catalogSummary}`;
  }
  return `Drove feature \`${proof.feature}\` through control-marketplace.${catalogSummary}`;
}

function grokSkipCheckIds(step, repoRoot) {
  if (!step?.stdout) {
    return null;
  }
  try {
    const payload = JSON.parse(portableText(step.stdout, repoRoot));
    if (!Array.isArray(payload.checks)) {
      return null;
    }
    return payload.checks
      .filter((check) => check.severity === "skip")
      .map((check) => check.id);
  } catch {
    return null;
  }
}

function portableInvocation(childArgs, repoRoot) {
  const args = [];
  for (let i = 0; i < childArgs.length; i += 1) {
    if (childArgs[i] === "--repo") {
      i += 1;
      continue;
    }
    args.push(childArgs[i]);
  }
  return [
    "node",
    ".cursor/skills/verify-marketplace/control-marketplace.mjs",
    ...args,
  ].join(" ");
}

function portableText(text, repoRoot) {
  return text.split(repoRoot).join(".").split(process.execPath).join("node");
}

function renderProofMarkdown(proof, results, repoRoot) {
  const infoStep = results.find((step) => step.id === "info");
  let catalogSummary = "";
  if (infoStep?.stdout) {
    try {
      const info = JSON.parse(portableText(infoStep.stdout, repoRoot));
      const missing = info.gaps?.missingFromCodex ?? [];
      catalogSummary = ` Inventory from \`info\`: ${info.counts?.pluginDirs} plugin directories, root/Claude catalogs ${info.counts?.rootMarketplace}/${info.counts?.claudeMarketplace}, Codex ${info.counts?.codexMarketplace}, Grok ${info.counts?.grokMarketplace}${missing.length ? ` (missing ${missing.join(", ")}; not a Claude-catalog failure)` : ""}.`;
    } catch {
      catalogSummary = "";
    }
  }
  const lines = [
    `# Proven drive: ${proof.feature}`,
    "",
    proof.ok ? "Result: **pass**" : "Result: **fail**",
    "",
    `- Started: ${proof.startedAt}`,
    `- Finished: ${proof.finishedAt}`,
    `- Repo: checkout root (paths in this file are repo-relative)`,
    `- Hosted UI: no`,
    "",
    "## What this proved",
    "",
    proofWhatProved(proof, catalogSummary),
    "",
    "## Steps",
    "",
  ];
  for (const step of results) {
    lines.push(
      `- \`${step.id}\`: ${step.ok ? "pass" : "fail"} (exit ${step.exitCode}) — \`${step.invocation}\``,
    );
  }
  lines.push("", "## Artifacts", "");
  lines.push("- `drive.json` — machine-readable summary");
  lines.push(
    "- `drive.md` — what the drive proved (committed). `drive.transcript.txt` is local-only.",
  );
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function renderProofTranscript(results, repoRoot) {
  return results
    .map((step) => {
      return [
        `## ${step.id} (exit ${step.exitCode})`,
        `$ ${step.invocation}`,
        "--- stdout ---",
        portableText(step.stdout ?? "", repoRoot),
        "--- stderr ---",
        portableText(step.stderr ?? "", repoRoot),
        "",
      ].join("\n");
    })
    .join("\n");
}

function runCleanup(parsed) {
  const dryRun = Boolean(parsed.flags.dryRun);
  const tmp = os.tmpdir();
  const entries = fs
    .readdirSync(tmp)
    .filter((name) => name.startsWith("verify-marketplace-"))
    .map((name) => path.join(tmp, name));
  const proofDir = path.join(SKILL_DIR, "proof");
  const removed = [];
  if (!dryRun) {
    for (const entry of entries) {
      fs.rmSync(entry, { recursive: true, force: true });
      removed.push(entry);
    }
  }
  const payload = {
    ok: true,
    command: "cleanup",
    dryRun,
    wouldRemove: entries,
    removed,
    retained: [proofDir],
    note: "Proof artifacts under .cursor/skills/verify-marketplace/proof/ are never deleted.",
  };
  writeOutput(parsed, payload);
  return OK_EXIT;
}

function runMap(parsed) {
  const repoRoot = resolveRepoRoot(parsed);
  const dir = path.join(SKILL_DIR, "references", "features");
  const files = fs.existsSync(dir)
    ? fs
        .readdirSync(dir)
        .filter((name) => name.endsWith(".md"))
        .sort()
    : [];
  const payload = {
    ok: files.includes("README.md"),
    command: "map",
    repoRoot,
    dir: rel(repoRoot, dir),
    files,
  };
  writeOutput(parsed, payload);
  return payload.ok ? OK_EXIT : FAIL_EXIT;
}

function runHelp(parsed) {
  const topic = parsed.command === "help" ? parsed.args[0] : parsed.command;
  const text = helpText(topic);
  if (parsed.flags.json) {
    writeOutput(parsed, {
      ok: true,
      command: "help",
      topic: topic ?? "global",
      commands: COMMANDS,
      text,
    });
  } else {
    process.stdout.write(`${text}\n`);
  }
  return OK_EXIT;
}

function helpText(topic) {
  const global = `control-marketplace — drive the duyet/codex-claude-plugins marketplace pack

USAGE
  node .cursor/skills/verify-marketplace/control-marketplace.mjs <command> [flags]

This repo is a plugin marketplace, not a hosted web app. The lever validates
marketplace JSON, plugin manifests, and documented Claude Code, Codex, Grok
Build, and Grok Bot install paths.

GLOBAL FLAGS
  --json              Machine-readable stdout (also --format json)
  --repo <path>       Marketplace repo root (default: walk from cwd / this skill)
  --help, -h          Show this help or command help
  --dry-run           On destructive commands, print the plan and skip writes
  --strict            Promote docs warnings (missing plugin README) to failures
  --version           Print lever version

COMMANDS
  doctor                 Is this checkout worth driving?
  info                   Pack identity, catalog counts, surface flags
  list                   Plugins on disk and which manifests they ship
  inspect <name...>      One plugin's manifests, docs, and marketplace rows
  validate               Production harness: bash scripts/validate-plugins.sh
  check-docs             README / CLAUDE.md / CONTRIBUTING install and docs paths
  check-install          Claude, Codex, Antigravity, Grok install resolvability
  install-antigravity    Symlink Antigravity plugins (destructive; default dry-run)
  prove                  Record one mapped-feature drive as proof
  cleanup                Remove /tmp/verify-marketplace-* scratch; keeps proof/
  map                    Feature map files under references/features/

EXAMPLES
  node .cursor/skills/verify-marketplace/control-marketplace.mjs --help
  node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs inspect commit --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs validate --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface claude --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs install-antigravity --dry-run --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature marketplace-catalog --json
  node .cursor/skills/verify-marketplace/control-marketplace.mjs cleanup --dry-run --json

EXIT CODES
  0  ok
  1  a check failed
  2  usage error

JSON SHAPE
  Every command prints { ok, command, ... }. Failed checks use ok: false and
  non-zero exit. Compose with jq, for example:
    node ... list --json | jq -r '.plugins[].name'`;

  const details = {
    doctor: `doctor — read-only health check

USAGE
  control-marketplace.mjs doctor [--json] [--repo <path>]

Reports python3, node, validate-plugins.sh, marketplace JSON parse, plugin
directory count, and that this lever plus the feature map are present.

Does not fail on Codex or Grok catalog name drift; that is validate /
check-install --surface codex|grok.`,
    info: `info — pack identity

USAGE
  control-marketplace.mjs info [--json] [--repo <path>]

Prints marketplace name, plugin counts per catalog, Antigravity count,
Grok Bot / Grok Build surface flags, and Codex or Grok name gaps.`,
    list: `list — plugin inventory

USAGE
  control-marketplace.mjs list [--json] [--missing-readme] [--missing-codex] [--missing-grok] [--has-antigravity] [--has-grok] [--has-grok-build]

Each row includes claude/codex/antigravity/grok/grokBuild booleans, README/CLAUDE.md, and version.`,
    inspect: `inspect — one plugin

USAGE
  control-marketplace.mjs inspect <name...> [--json]

Shows manifests, docs flags, and the matching row from each marketplace file.`,
    validate: `validate — production harness

USAGE
  control-marketplace.mjs validate [--json]

Runs bash scripts/validate-plugins.sh in the repo root. This is the same check
CI uses. JSON includes passed/failed labels and the raw script output.`,
    "check-docs": `check-docs — documented install and docs paths

USAGE
  control-marketplace.mjs check-docs [--json] [--strict]

Needles in README.md, CLAUDE.md, and CONTRIBUTING.md. Missing plugin README.md
is a warning unless --strict.`,
    "check-install": `check-install — can a user actually install from this checkout?

USAGE
  control-marketplace.mjs check-install [--surface claude|codex|antigravity|grok|all] [--json]

claude   Claude marketplace sources exist; root ids are name@marketplace
codex    Codex marketplace names match plugin dirs; local sources exist
antigravity  Lists .antigravity-plugin packs and the install script
grok     Grok marketplace names, local sources, per-plugin logos, and Grok Bot / Grok Build manifests. Skip is a failure.`,
    "install-antigravity": `install-antigravity — symlink Antigravity plugins

USAGE
  control-marketplace.mjs install-antigravity [--plugin <name>|all] [--dry-run|--apply] [--target <dir>] [--force] [--json]

Destructive: writes symlinks. Default is dry-run (no writes). --apply without
--target refuses $HOME/.gemini/config/plugins unless --force.

Verify a dry-run by checking that --target (or the default home path) is unchanged.`,
    prove: `prove — record one mapped feature drive

USAGE
  control-marketplace.mjs prove [--feature <id>] [--out <dir>] [--json]

Default feature is marketplace-catalog. Writes drive.json, drive.md, and
drive.transcript.txt. Cleanup must not delete this directory.`,
    cleanup: `cleanup — remove scratch only

USAGE
  control-marketplace.mjs cleanup [--dry-run] [--json]

Deletes /tmp/verify-marketplace-* only. Never deletes proof artifacts.`,
    map: `map — feature map index

USAGE
  control-marketplace.mjs map [--json]

Lists references/features/*.md. Read README.md there before driving.`,
  };

  if (topic && topic !== "help" && details[topic]) {
    return `${details[topic]}\n\nUse --help with no command for the full command surface.`;
  }
  return global;
}

function finishChecks(parsed, command, checks, extra = {}) {
  const errors = checks.filter(
    (check) => check.ok === false && check.severity !== "skip",
  );
  const payload = {
    ok: errors.length === 0,
    command,
    ...extra,
    checks,
    failed: errors.map((check) => check.id),
  };
  writeOutput(parsed, payload);
  return payload.ok ? OK_EXIT : FAIL_EXIT;
}

function sortedDiff(left, right) {
  const rightSet = new Set(right);
  return [...new Set(left)].filter((item) => !rightSet.has(item)).sort();
}

function writeError(message) {
  process.stderr.write(`${message}\n`);
}

function writeOutput(parsed, payload) {
  if (parsed.flags.json) {
    process.stdout.write(`${JSON.stringify(payload, null, 2)}\n`);
    return;
  }
  process.stdout.write(`${renderText(payload)}\n`);
}

function renderText(payload) {
  const lines = [];
  lines.push(`${payload.command}: ${payload.ok ? "ok" : "FAIL"}`);
  if (payload.error) {
    lines.push(payload.error);
  }
  if (payload.repoRoot) {
    lines.push(`repo: ${payload.repoRoot}`);
  }
  if (Array.isArray(payload.checks)) {
    for (const check of payload.checks) {
      const mark = check.ok ? "PASS" : "FAIL";
      const severity = check.severity ? ` [${check.severity}]` : "";
      lines.push(`  ${mark}${severity} ${check.id}: ${check.detail}`);
    }
  }
  if (Array.isArray(payload.plugins) && payload.command === "list") {
    for (const plugin of payload.plugins) {
      const flags = [
        plugin.claude ? "claude" : null,
        plugin.codex ? "codex" : null,
        plugin.antigravity ? "antigravity" : null,
        plugin.grok ? "grok" : null,
        plugin.grokBuild ? "grok-build" : null,
        plugin.readme ? "readme" : "NO-README",
      ]
        .filter(Boolean)
        .join(",");
      lines.push(`  ${plugin.name} ${plugin.version ?? "?"} [${flags}]`);
    }
  }
  if (payload.command === "validate") {
    lines.push(`exit: ${payload.exitCode}`);
    if (payload.output) {
      lines.push(payload.output.trimEnd());
    }
  }
  if (payload.command === "info" && payload.counts) {
    lines.push(`marketplace: ${payload.marketplaceName}`);
    lines.push(`pluginDirs: ${payload.counts.pluginDirs}`);
    lines.push(
      `catalogs: root=${payload.counts.rootMarketplace} claude=${payload.counts.claudeMarketplace} codex=${payload.counts.codexMarketplace} grok=${payload.counts.grokMarketplace}`,
    );
    lines.push(
      `surfaces: claudeCode=${payload.surfaces.claudeCode} codex=${payload.surfaces.codex} antigravity=${payload.surfaces.antigravity} grokBuild=${payload.surfaces.grokBuild} grokBot=${payload.surfaces.grokBot}`,
    );
    if (payload.gaps?.missingFromCodex?.length) {
      lines.push(
        `codex gap: missing ${payload.gaps.missingFromCodex.join(", ")}`,
      );
    }
    if (payload.gaps?.missingFromGrok?.length) {
      lines.push(
        `grok gap: missing ${payload.gaps.missingFromGrok.join(", ")}`,
      );
    }
  }
  if (payload.command === "prove" && payload.steps) {
    for (const step of payload.steps) {
      lines.push(`  ${step.ok ? "PASS" : "FAIL"} ${step.id}`);
    }
    if (payload.artifacts) {
      lines.push(`artifacts: ${Object.values(payload.artifacts).join(", ")}`);
    }
  }
  if (payload.command === "install-antigravity") {
    lines.push(`dryRun: ${payload.dryRun}`);
    lines.push(`target: ${payload.target}`);
    lines.push(`plugins: ${(payload.plugins ?? []).join(", ") || "(none)"}`);
  }
  if (payload.command === "cleanup") {
    lines.push(`dryRun: ${payload.dryRun}`);
    lines.push(
      `scratch: ${(payload.wouldRemove ?? []).join(", ") || "(none)"}`,
    );
    lines.push(`retained: ${(payload.retained ?? []).join(", ")}`);
  }
  if (payload.command === "map") {
    for (const file of payload.files ?? []) {
      lines.push(`  ${file}`);
    }
  }
  if (payload.command === "help" && payload.text) {
    return payload.text;
  }
  return lines.join("\n");
}

const exitCode = main(process.argv.slice(2));
process.exit(exitCode);
