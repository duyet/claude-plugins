import { describe, it, expect } from "bun:test";
import fs from "node:fs";
import path from "node:path";

const ROOT_DIR = path.resolve(import.meta.dir, "..");
const MARKETPLACE_PATH = path.join(ROOT_DIR, ".claude-plugin", "marketplace.json");
const PLUGINS_DIR = path.join(ROOT_DIR, "plugins");

// Helper functions
function readJSON(filePath: string) {
  return JSON.parse(fs.readFileSync(filePath, "utf-8"));
}

function isKebabCase(str: string): boolean {
  return /^[a-z0-9]+(-[a-z0-9]+)*$/.test(str);
}

function parseYAMLFrontmatter(content: string): Record<string, string> | null {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;

  const yaml = match[1];
  const result: Record<string, string> = {};

  for (const line of yaml.split("\n")) {
    const colonIndex = line.indexOf(":");
    if (colonIndex > 0) {
      const key = line.substring(0, colonIndex).trim();
      const value = line.substring(colonIndex + 1).trim();
      result[key] = value;
    }
  }

  return result;
}

// Load marketplace data
const marketplace = readJSON(MARKETPLACE_PATH);

describe("Marketplace JSON Schema", () => {
  it("should have a valid name in kebab-case", () => {
    expect(marketplace.name).toBeDefined();
    expect(isKebabCase(marketplace.name)).toBe(true);
  });

  it("should have owner information", () => {
    expect(marketplace.owner).toBeDefined();
    expect(marketplace.owner.name).toBeDefined();
  });

  it("should have metadata", () => {
    expect(marketplace.metadata).toBeDefined();
    expect(marketplace.metadata.description).toBeDefined();
    expect(marketplace.metadata.version).toBeDefined();
  });

  it("should have plugins array", () => {
    expect(Array.isArray(marketplace.plugins)).toBe(true);
    expect(marketplace.plugins.length).toBeGreaterThan(0);
  });

  it("should have valid semver version format", () => {
    const semverRegex = /^\d+\.\d+\.\d+$/;
    expect(marketplace.metadata.version).toMatch(semverRegex);
  });
});

describe("Plugin Schema Validation", () => {
  for (const plugin of marketplace.plugins) {
    describe(`Plugin: ${plugin.name}`, () => {
      it("should have required fields", () => {
        expect(plugin.name).toBeDefined();
        expect(plugin.source).toBeDefined();
        expect(plugin.description).toBeDefined();
        expect(plugin.version).toBeDefined();
      });

      it("should have valid name in kebab-case", () => {
        expect(isKebabCase(plugin.name)).toBe(true);
      });

      it("should have valid semver version format", () => {
        const semverRegex = /^\d+\.\d+\.\d+$/;
        expect(plugin.version).toMatch(semverRegex);
      });

      it("should have valid keywords array if specified", () => {
        if (plugin.keywords) {
          expect(Array.isArray(plugin.keywords)).toBe(true);
          for (const keyword of plugin.keywords) {
            expect(typeof keyword).toBe("string");
          }
        }
      });

      it("should have valid license if specified", () => {
        if (plugin.license) {
          expect(typeof plugin.license).toBe("string");
          expect(plugin.license.length).toBeGreaterThan(0);
        }
      });
    });
  }
});

describe("Structural Integrity", () => {
  it("should have pluginRoot directory", () => {
    const pluginRoot = path.join(ROOT_DIR, marketplace.metadata.pluginRoot || "plugins");
    expect(fs.existsSync(pluginRoot)).toBe(true);
  });

  it("should have totalPlugins matching actual count", () => {
    if (marketplace.metadata.totalPlugins !== undefined) {
      expect(marketplace.metadata.totalPlugins).toBe(marketplace.plugins.length);
    }
  });

  for (const plugin of marketplace.plugins) {
    const pluginPath =
      typeof plugin.source === "string" && plugin.source.startsWith("./")
        ? path.join(ROOT_DIR, plugin.source)
        : null;

    if (pluginPath) {
      describe(`Plugin Directory: ${plugin.name}`, () => {
        it("should have plugin directory", () => {
          expect(fs.existsSync(pluginPath)).toBe(true);
        });

        it("should have plugin.json", () => {
          const pluginJsonPath = path.join(pluginPath, ".claude-plugin", "plugin.json");
          expect(fs.existsSync(pluginJsonPath)).toBe(true);
        });

        it("should have command.md", () => {
          const commandPath = path.join(pluginPath, "command.md");
          expect(fs.existsSync(commandPath)).toBe(true);
        });
      });
    }
  }
});

describe("Plugin.json Consistency", () => {
  for (const plugin of marketplace.plugins) {
    const pluginPath =
      typeof plugin.source === "string" && plugin.source.startsWith("./")
        ? path.join(ROOT_DIR, plugin.source)
        : null;

    if (pluginPath) {
      const pluginJsonPath = path.join(pluginPath, ".claude-plugin", "plugin.json");

      if (fs.existsSync(pluginJsonPath)) {
        describe(`Consistency: ${plugin.name}`, () => {
          const pluginJson = readJSON(pluginJsonPath);

          it("should have matching name", () => {
            expect(pluginJson.name).toBe(plugin.name);
          });

          it("should have matching version", () => {
            expect(pluginJson.version).toBe(plugin.version);
          });
        });
      }
    }
  }
});

describe("Command.md Frontmatter Validation", () => {
  for (const plugin of marketplace.plugins) {
    const pluginPath =
      typeof plugin.source === "string" && plugin.source.startsWith("./")
        ? path.join(ROOT_DIR, plugin.source)
        : null;

    if (pluginPath) {
      const commandPath = path.join(pluginPath, "command.md");

      if (fs.existsSync(commandPath)) {
        describe(`Frontmatter: ${plugin.name}`, () => {
          const content = fs.readFileSync(commandPath, "utf-8");
          const frontmatter = parseYAMLFrontmatter(content);

          it("should have valid YAML frontmatter", () => {
            expect(frontmatter).not.toBeNull();
          });

          it("should have allowed-tools field", () => {
            expect(frontmatter?.["allowed-tools"]).toBeDefined();
          });

          it("should have description field", () => {
            expect(frontmatter?.["description"]).toBeDefined();
          });
        });
      }
    }
  }
});

describe("No Duplicate Plugin Names", () => {
  it("should have unique plugin names", () => {
    const names = marketplace.plugins.map((p: any) => p.name);
    const uniqueNames = new Set(names);
    expect(names.length).toBe(uniqueNames.size);
  });
});

describe("URL Validation", () => {
  const urlRegex = /^https?:\/\/.+/;

  it("should have valid homepage URL in metadata", () => {
    if (marketplace.metadata.homepage) {
      expect(marketplace.metadata.homepage).toMatch(urlRegex);
    }
  });

  it("should have valid owner URL", () => {
    if (marketplace.owner.url) {
      expect(marketplace.owner.url).toMatch(urlRegex);
    }
  });

  for (const plugin of marketplace.plugins) {
    describe(`URLs: ${plugin.name}`, () => {
      it("should have valid repository URL if specified", () => {
        if (plugin.repository) {
          expect(plugin.repository).toMatch(urlRegex);
        }
      });

      it("should have valid homepage URL if specified", () => {
        if (plugin.homepage) {
          expect(plugin.homepage).toMatch(urlRegex);
        }
      });

      it("should have valid author URL if specified", () => {
        if (plugin.author?.url) {
          expect(plugin.author.url).toMatch(urlRegex);
        }
      });
    });
  }
});
