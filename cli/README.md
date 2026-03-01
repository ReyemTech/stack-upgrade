# @reyemtech/stack-upgrade

[![npm](https://img.shields.io/npm/v/@reyemtech/stack-upgrade)](https://www.npmjs.com/package/@reyemtech/stack-upgrade)
[![npm downloads](https://img.shields.io/npm/dm/@reyemtech/stack-upgrade)](https://www.npmjs.com/package/@reyemtech/stack-upgrade)
[![License: BSL 1.1](https://img.shields.io/badge/License-BSL_1.1-yellow.svg)](https://github.com/ReyemTech/stack-upgrade/blob/main/LICENSE)
[![Node](https://img.shields.io/node/v/@reyemtech/stack-upgrade)](https://nodejs.org)

CLI to launch Stack Upgrade Agents via Docker or Kubernetes. Auto-detects repos, Claude credentials, and runtime — then launches disposable containers that upgrade your stack autonomously using [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

**Currently supports:** Laravel. **Coming soon:** React, Rails, Django.

## Quick Start

```bash
npx @reyemtech/stack-upgrade
```

Or install globally:

```bash
npm i -g @reyemtech/stack-upgrade
stack-upgrade
```

## Prerequisites

- **Docker** or **kubectl** in PATH
- **GitHub CLI** (`gh`) authenticated — for repo discovery and PR creation
- **Claude credentials** — Claude Max token or Anthropic API key

## What It Does

1. Scans your GitHub repos for supported stacks (Laravel via `composer.json`)
2. Prompts for target version, push/PR preference, and branch suffix
3. Supports queuing multiple upgrades to run in parallel
4. Launches a disposable Docker container (or K8s pod) per upgrade
5. Each container runs Claude Code autonomously through upgrade phases
6. Pushes an upgrade branch and optionally opens a PR with a generated changelog

## Supported Stacks

| Stack | Image | Status |
|-------|-------|--------|
| Laravel | `ghcr.io/reyemtech/laravel-upgrade-agent` | Available |
| React | — | Planned |
| Rails | — | Planned |
| Django | — | Planned |

## Configuration

Config is persisted to `~/.stack-upgrade/config.json`:

- Claude credentials (auto-detected from `~/.claude/.credentials.json`, env vars, or manual input)
- GitHub token
- Preferred run target (Docker or Kubernetes)

## License

[BSL 1.1](https://github.com/ReyemTech/stack-upgrade/blob/main/LICENSE)

---

<p align="center">
  <a href="https://www.reyem.tech">
    <img src="https://www.reyem.tech/images/logo-light-tagline.webp" alt="ReyemTech" width="200">
  </a>
</p>
