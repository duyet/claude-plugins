# AnyRouter Plugin

Wire [AnyRouter](https://anyrouter.dev) — a universal, OpenAI-compatible LLM gateway for 150+ models across 28+ providers — into Claude Code, Codex, Cursor, and any other coding agent that accepts a custom base URL.

This plugin ships as a **Claude Code plugin** (`.claude-plugin/`), a **Codex plugin** (`.codex-plugin/`), and **Grok Build / Grok Bot** manifests (`.grok-plugin/` + `.grok-build-plugin/`), and bundles a remote **MCP server** for key and credit management.

## What you get

- **`anyrouter` skill** — discoverable knowledge for the agent: the contract (base URL / key env / model id format), integration patterns, migration recipes (from OpenAI / Anthropic / OpenRouter), routing, streaming, app attribution, MCP overview. Tells the agent to **fetch live `.md` docs** instead of trusting any frozen snapshot.
- **`/anyrouter:migrate` command** — interactive migration of an existing LLM integration to AnyRouter.
- **`anyrouter-integrator` agent** — sub-agent that performs surgical migrations on demand.
- **MCP server** — remote MCP at `https://anyrouter.dev/api/v1/mcp` for `list_models`, `get_credits`, `list_keys`, `create_key`, `revoke_key`, `list_presets`, `list_conversations`.

There is **no `references/` snapshot** — the skill links to live `.md` URLs (`https://anyrouter.dev/docs/<path>.md`) so the agent always works with current content. The auto-generated index is at https://anyrouter.dev/docs.md.

## Install

### Claude Code

```bash
/plugin marketplace add duyet/codex-claude-plugins
/plugin install anyrouter@duyet-claude-plugins
```

Then set your key:

```bash
export ANYROUTER_API_KEY="sk-ar-..."
```

(Get one at https://anyrouter.dev/dashboard/keys.)

### Codex

The plugin's `.codex-plugin/plugin.json` declares Skill, Command, Agent, and MCP capabilities. Install via your Codex plugin loader the same way you install other plugins from `duyet/codex-claude-plugins`.

### Grok Build / Grok Bot

```bash
grok plugin marketplace add duyet/codex-claude-plugins
grok plugin install anyrouter --trust
```

### MCP only

If you only want the AnyRouter MCP server in another client (Claude Desktop, Cursor, Claude Code CLI, OpenCode), point it at `https://anyrouter.dev/api/v1/mcp`. Full per-client setup: https://anyrouter.dev/docs/mcp.md.

## Quick usage

After installing, the agent will load the `anyrouter` skill on its own when you say things like:

- "Add AnyRouter to this project."
- "Migrate this from OpenAI to AnyRouter."
- "Move my OpenRouter calls to AnyRouter."
- "Point Claude Code at AnyRouter."
- "List my AnyRouter API keys." (uses MCP)
- "How much credit do I have left?" (uses MCP)

You can also invoke the slash command directly:

```
/anyrouter:migrate
```

## The contract

| Setting | Value |
| --- | --- |
| Base URL | `https://anyrouter.dev/api/v1` |
| API key env | `ANYROUTER_API_KEY` (prefix `sk-ar-`) |
| Model id format | `provider/model` |
| Default model | `openai/gpt-5.4-mini` |
| Anthropic-native base | `https://anyrouter.dev/api` (for `/messages`) |
| MCP endpoint | `https://anyrouter.dev/api/v1/mcp` |

## Live docs

The skill links to live raw-markdown pages. Start with the index — it lists every section and every page:

- https://anyrouter.dev/docs.md — auto-generated index
- https://anyrouter.dev/llms-full.txt — every doc concatenated
- https://anyrouter.dev/llms.txt — short LLM index per `llmstxt.org`
- https://anyrouter.dev/docs/index.json — machine-readable manifest

## License

MIT. See [LICENSE](LICENSE).
