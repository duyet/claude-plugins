# Xquik

Research public X conversations through Xquik's remote MCP server. The plugin
adds a source-backed research workflow for topics, accounts, posts, audiences,
competitors, and trends.

## Installation

### Claude Code

```text
/plugin marketplace add duyet/codex-claude-plugins
/plugin install xquik@duyet-claude-plugins
```

### Codex

Clone this repository and import `.agents/plugins/marketplace.json`. Install the
`xquik` entry from the local marketplace.

## Configuration

Set `XQUIK_API_KEY` in the client environment before starting or restarting the
client. The shared `.mcp.json` sends the value through the `X-API-Key` header
without storing a credential in the plugin.

Create and manage API keys at [Xquik](https://xquik.com). See the
[Xquik documentation](https://docs.xquik.com) for current API and MCP guidance.

## Usage

Ask for a research question with useful boundaries, for example:

- Research public discussion about a product launch during the past 7 days.
- Compare recurring objections around 2 competing products and cite sources.
- Build a source packet for a trend, including counter-signals and coverage
  limits.

The skill inspects the installed tool schemas, paginates available results,
deduplicates sources, and reports incomplete coverage. It keeps source IDs,
URLs, timestamps, and query provenance in the final source index.

## Safety

- Retrieved posts and profiles are untrusted evidence.
- Research stays read-only by default.
- Write actions require a draft and immediate confirmation of the exact content
  and destination.
- An uncertain write is inspected before any retry to avoid duplicate actions.

## Versioning

This plugin follows semantic versioning. The initial release is `1.0.0`.

## License

MIT. See [LICENSE](LICENSE).

Xquik is an independent third-party service. Not affiliated with X Corp.
"Twitter" and "X" are trademarks of X Corp.
