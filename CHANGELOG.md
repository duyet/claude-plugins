# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- First-class Grok Build and Grok Bot support: `.grok-plugin/plugin.json` and `.grok-build-plugin/plugin.json` on every plugin, plus `.grok-plugin/marketplace.json`
- Plugin logos for Claude Code, Codex, Grok Build, Grok Bot, and Antigravity (`assets/logo.svg` per plugin, wired in manifests and marketplaces)
- Marketplace.json for centralized plugin registry
- GitHub issue templates (bug report, feature request)
- GitHub batch commands: bulk-close-issues, bulk-merge-prs, bulk-label
- PR templates for commit plugin (default, bugfix, feature)
- PR automation GitHub Action for auto-labeling and reviewer assignment
- Enhanced GitHub documentation with examples and troubleshooting

### Changed

- Improved documentation consistency across plugins
- Better version tracking in plugin manifests
- GitHub plugin: Enhanced batch operations and PR workflow
- Commit plugin: Added PR template support and draft PR option

### Removed

- terminal-ui-design plugin (consolidated with frontend-design)

### Fixed

## [1.0.0] - 2026-01-28

### Added

- team-agents: Leader, Senior Engineer, Junior Engineer for parallel execution
- commit: Semantic commit message format with PR workflows
- frontend-design: Anti-slop frontend design patterns
- interview: Socratic requirements gathering
- statusline: Configurable status bar with API tracking
- orchestration: Multi-agent workstream coordination
- duyetbot: Pragmatic development companion
- docs-generator: Automatic documentation maintenance
- github: Smart GitHub operations with gh CLI
- fix: Intelligent issue and CI failure resolution
- clickhouse: Comprehensive ClickHouse knowledge base

### Changed

- Initial release with production-quality plugin ecosystem

## Version History

For detailed history of individual plugins, see each plugin's README.md and CLAUDE.md files.
