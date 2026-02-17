# sesh

A split terminal session for AI-assisted coding. Runs an AI tool alongside lazygit in a single Zellij layout.

```
┌─────────────────────────────┬───────────────────┐
│                             │                   │
│         Claude Code         │     lazygit       │
│           (65%)             │      (35%)        │
│                             │                   │
└─────────────────────────────┴───────────────────┘
```

## Install

### Fish (with Fisher)

```fish
fisher install almonk/sesh
```

### Fish (manual)

```fish
cp functions/sesh.fish ~/.config/fish/functions/
cp completions/sesh.fish ~/.config/fish/completions/
```

### Zsh

Add this to your `~/.zshrc`:

```zsh
source /path/to/sesh/sesh.sh
```

### Bash

Add this to your `~/.bashrc`:

```bash
source /path/to/sesh/sesh.sh
```

## Dependencies

Install with Homebrew:

```
brew install zellij lazygit
```

You'll also need at least one AI tool:

| Tool | Install |
|------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` |
| [Codex](https://github.com/openai/codex) | `npm install -g @openai/codex` |
| [Pi](https://pi.ai) | See pi.ai for installation |

## Usage

```
sesh                      # Claude + lazygit in current directory
sesh codex                # Codex + lazygit in current directory
sesh pi                   # Pi + lazygit in current directory
sesh claude ~/my-project  # Claude + lazygit in a specific directory
```

## How it works

sesh generates a temporary Zellij layout file and launches a session with two vertical panes:

- **Left (65%)** — your chosen AI tool (Claude Code by default)
- **Right (35%)** — lazygit for staging, committing, and managing git

The layout file is cleaned up automatically when the session ends.
