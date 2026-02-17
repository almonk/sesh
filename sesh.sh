#!/usr/bin/env bash

sesh() {
    # Validate dependencies
    for dep in zellij lazygit; do
        if ! command -v "$dep" &>/dev/null; then
            echo "sesh: '$dep' is not installed. See https://github.com/almonk/sesh#dependencies"
            return 1
        fi
    done

    local tool="${1:-claude}"
    tool="$(echo "$tool" | tr '[:upper:]' '[:lower:]')"
    local dir="${2:-$(pwd)}"

    dir="$(realpath "$dir" 2>/dev/null)" || {
        echo "sesh: invalid directory: $2"
        return 1
    }

    local cmd_block

    case "$tool" in
        claude)
            if ! command -v claude &>/dev/null; then
                echo "sesh: 'claude' is not installed. Install with: npm install -g @anthropic-ai/claude-code"
                return 1
            fi
            cmd_block="pane size=\"65%\" command=\"claude\" {
            args \"--dangerously-skip-permissions\"
            cwd \"$dir\"
        }"
            ;;
        codex)
            if ! command -v codex &>/dev/null; then
                echo "sesh: 'codex' is not installed. Install with: npm install -g @openai/codex"
                return 1
            fi
            cmd_block="pane size=\"65%\" command=\"codex\" {
            cwd \"$dir\"
        }"
            ;;
        pi)
            if ! command -v pi &>/dev/null; then
                echo "sesh: 'pi' is not installed."
                return 1
            fi
            cmd_block="pane size=\"65%\" command=\"pi\" {
            cwd \"$dir\"
        }"
            ;;
        *)
            echo "Usage: sesh [claude|codex|pi] [directory]"
            echo ""
            echo "Tools:"
            echo "  claude  Claude Code CLI (default)"
            echo "  codex   OpenAI Codex CLI"
            echo "  pi      Pi CLI"
            echo ""
            echo "Examples:"
            echo "  sesh                  # Claude + lazygit in current dir"
            echo "  sesh pi               # Pi + lazygit in current dir"
            echo "  sesh claude ~/project # Claude + lazygit in ~/project"
            return 1
            ;;
    esac

    local layout_file
    layout_file="$(mktemp /tmp/sesh-layout.XXXXXX.kdl)"
    cat > "$layout_file" <<EOF
keybinds {
    shared {
        bind "Alt 1" { MoveFocus "left"; }
        bind "Alt 2" { MoveFocus "right"; }
    }
}
layout {
    pane split_direction="vertical" {
        $cmd_block
        pane size="35%" command="lazygit" {
            cwd "$dir"
        }
    }
}
EOF

    zellij --layout "$layout_file"
    rm -f "$layout_file"
}
