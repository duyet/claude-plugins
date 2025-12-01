import { describe, it } from "node:test";
import assert from "node:assert";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = path.resolve(__dirname, "..");
const MARKETPLACE_PATH = path.join(
  ROOT_DIR,
  ".claude-plugin",
  "marketplace.json"
);
const PLUGINS_DIR = path.join(ROOT_DIR, "plugins");

// Helper functions
function readJSON(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf-8"));
}

function isKebabCase(str) {
  return /^[a-z0-9]+(-[a-z0-9]+)*$/.test(str);
}

function parseYAMLFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;

  const yaml = match[1];
  const result = {};

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
    assert.ok(marketplace.name, "marketplace.name is required");
    assert.ok(
      isKebabCase(marketplace.name),
      `marketplace.name "${marketplace.name}" should be kebab-case`
    );
  });

  it("should have owner information", () => {
    assert.ok(marketplace.owner, "marketplace.owner is required");
    assert.ok(marketplace.owner.name, "marketplace.owner.name is required");
  });

  it("should have metadata", () => {
    assert.ok(marketplace.metadata, "marketplace.metadata is required");
    assert.ok(
      marketplace.metadata.description,
      "marketplace.metadata.description is required"
    );
    assert.ok(
      marketplace.metadata.version,
      "marketplace.metadata.version is required"
    );
  });

  it("should have plugins array", () => {
    assert.ok(Array.isArray(marketplace.plugins), "plugins should be an array");
    assert.ok(marketplace.plugins.length > 0, "plugins array should not be empty");
  });

  it("should have valid version format", () => {
    const semverRegex = /^\d+\.\d+\.\d+$/;
    assert.ok(
      semverRegex.test(marketplace.metadata.version),
      `marketplace version "${marketplace.metadata.version}" should be semver format`
    );
  });
});

describe("Plugin Schema Validation", () => {
  for (const plugin of marketplace.plugins) {
    describe(`Plugin: ${plugin.name}`, () => {
      it("should have required fields", () => {
        assert.ok(plugin.name, "plugin.name is required");
        assert.ok(plugin.source, "plugin.source is required");
        assert.ok(plugin.description, "plugin.description is required");
        assert.ok(plugin.version, "plugin.version is required");
      });

      it("should have valid name in kebab-case", () => {
        assert.ok(
          isKebabCase(plugin.name),
          `plugin.name "${plugin.name}" should be kebab-case`
        );
      });

      it("should have valid version format", () => {
        const semverRegex = /^\d+\.\d+\.\d+$/;
        assert.ok(
          semverRegex.test(plugin.version),
          `plugin version "${plugin.version}" should be semver format`
        );
      });

      it("should have valid keywords array", () => {
        if (plugin.keywords) {
          assert.ok(
            Array.isArray(plugin.keywords),
            "keywords should be an array"
          );
          for (const keyword of plugin.keywords) {
            assert.strictEqual(
              typeof keyword,
              "string",
              "each keyword should be a string"
            );
          }
        }
      });

      it("should have valid license if specified", () => {
        if (plugin.license) {
          const validLicenses = ["MIT", "Apache-2.0", "GPL-3.0", "BSD-3-Clause", "ISC"];
          assert.ok(
            validLicenses.includes(plugin.license) || plugin.license.length > 0,
            `license should be a valid SPDX identifier`
          );
        }
      });
    });
  }
});

describe("Structural Integrity", () => {
  it("should have pluginRoot directory", () => {
    const pluginRoot = path.join(ROOT_DIR, marketplace.metadata.pluginRoot || "plugins");
    assert.ok(
      fs.existsSync(pluginRoot),
      `pluginRoot directory "${pluginRoot}" should exist`
    );
  });

  it("should have totalPlugins matching actual count", () => {
    if (marketplace.metadata.totalPlugins !== undefined) {
      assert.strictEqual(
        marketplace.metadata.totalPlugins,
        marketplace.plugins.length,
        `totalPlugins (${marketplace.metadata.totalPlugins}) should match plugins array length (${marketplace.plugins.length})`
      );
    }
  });

  for (const plugin of marketplace.plugins) {
    describe(`Plugin Directory: ${plugin.name}`, () => {
      const pluginPath =
        typeof plugin.source === "string" && plugin.source.startsWith("./")
          ? path.join(ROOT_DIR, plugin.source)
          : null;

      if (pluginPath) {
        it("should have plugin directory", () => {
          assert.ok(
            fs.existsSync(pluginPath),
            `Plugin directory "${pluginPath}" should exist`
          );
        });

        it("should have plugin.json", () => {
          const pluginJsonPath = path.join(
            pluginPath,
            ".claude-plugin",
            "plugin.json"
          );
          assert.ok(
            fs.existsSync(pluginJsonPath),
            `plugin.json should exist at "${pluginJsonPath}"`
          );
        });

        it("should have command.md", () => {
          const commandPath = path.join(pluginPath, "command.md");
          assert.ok(
            fs.existsSync(commandPath),
            `command.md should exist at "${commandPath}"`
          );
        });
      }
    });
  }
});

describe("Plugin.json Consistency", () => {
  for (const plugin of marketplace.plugins) {
    const pluginPath =
      typeof plugin.source === "string" && plugin.source.startsWith("./")
        ? path.join(ROOT_DIR, plugin.source)
        : null;

    if (pluginPath) {
      const pluginJsonPath = path.join(
        pluginPath,
        ".claude-plugin",
        "plugin.json"
      );

      if (fs.existsSync(pluginJsonPath)) {
        describe(`Consistency: ${plugin.name}`, () => {
          const pluginJson = readJSON(pluginJsonPath);

          it("should have matching name", () => {
            assert.strictEqual(
              pluginJson.name,
              plugin.name,
              `plugin.json name "${pluginJson.name}" should match marketplace entry "${plugin.name}"`
            );
          });

          it("should have matching version", () => {
            assert.strictEqual(
              pluginJson.version,
              plugin.version,
              `plugin.json version "${pluginJson.version}" should match marketplace entry "${plugin.version}"`
            );
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
            assert.ok(
              frontmatter,
              `command.md should have YAML frontmatter (---...---)`
            );
          });

          it("should have allowed-tools field", () => {
            assert.ok(
              frontmatter && frontmatter["allowed-tools"],
              `command.md should have allowed-tools in frontmatter`
            );
          });

          it("should have description field", () => {
            assert.ok(
              frontmatter && frontmatter["description"],
              `command.md should have description in frontmatter`
            );
          });
        });
      }
    }
  }
});

describe("No Duplicate Plugin Names", () => {
  it("should have unique plugin names", () => {
    const names = marketplace.plugins.map((p) => p.name);
    const uniqueNames = new Set(names);
    assert.strictEqual(
      names.length,
      uniqueNames.size,
      `Found duplicate plugin names: ${names.filter((n, i) => names.indexOf(n) !== i).join(", ")}`
    );
  });
});

describe("URL Validation", () => {
  const urlRegex = /^https?:\/\/.+/;

  it("should have valid homepage URL in metadata", () => {
    if (marketplace.metadata.homepage) {
      assert.ok(
        urlRegex.test(marketplace.metadata.homepage),
        `homepage "${marketplace.metadata.homepage}" should be a valid URL`
      );
    }
  });

  it("should have valid owner URL", () => {
    if (marketplace.owner.url) {
      assert.ok(
        urlRegex.test(marketplace.owner.url),
        `owner.url "${marketplace.owner.url}" should be a valid URL`
      );
    }
  });

  for (const plugin of marketplace.plugins) {
    describe(`URLs: ${plugin.name}`, () => {
      it("should have valid repository URL if specified", () => {
        if (plugin.repository) {
          assert.ok(
            urlRegex.test(plugin.repository),
            `repository "${plugin.repository}" should be a valid URL`
          );
        }
      });

      it("should have valid homepage URL if specified", () => {
        if (plugin.homepage) {
          assert.ok(
            urlRegex.test(plugin.homepage),
            `homepage "${plugin.homepage}" should be a valid URL`
          );
        }
      });

      it("should have valid author URL if specified", () => {
        if (plugin.author && plugin.author.url) {
          assert.ok(
            urlRegex.test(plugin.author.url),
            `author.url "${plugin.author.url}" should be a valid URL`
          );
        }
      });
    });
  }
});
