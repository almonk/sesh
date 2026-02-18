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

    if [[ "$tool" == "list" ]]; then
        zellij list-sessions
        return
    fi

    if [[ "$tool" == "pickup" ]]; then
        local session
        session="$(zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | head -1 | awk '{print $1}')"
        if [[ -z "$session" ]]; then
            echo "sesh: no sessions found"
            return 1
        fi
        echo "sesh: attaching to $session"
        zellij attach "$session"
        return
    fi

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
        amp)
            if ! command -v amp &>/dev/null; then
                echo "sesh: 'amp' is not installed. Install with: npm install -g @sourcegraph/amp"
                return 1
            fi
            cmd_block="pane size=\"65%\" command=\"amp\" {
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
        help|--help|-h)
            echo "Usage: sesh [command] [directory]"
            echo ""
            echo "Built-in tools:"
            echo "  claude  Claude Code CLI (default)"
            echo "  codex   OpenAI Codex CLI"
            echo "  amp     Amp CLI (Sourcegraph)"
            echo "  pi      Pi CLI"
            echo ""
            echo "Any other command will be run in the main pane:"
            echo "  sesh vim ~/project    # vim + lazygit in ~/project"
            echo ""
            echo "Examples:"
            echo "  sesh                  # Claude + lazygit in current dir"
            echo "  sesh pi               # Pi + lazygit in current dir"
            echo "  sesh claude ~/project # Claude + lazygit in ~/project"
            return 0
            ;;
        *)
            if ! command -v "$tool" &>/dev/null; then
                echo "sesh: '$tool' is not installed or not in PATH"
                return 1
            fi
            cmd_block="pane size=\"65%\" command=\"$tool\" {
            cwd \"$dir\"
        }"
            ;;
    esac

    local layout_file
    local layout_dir
    layout_dir="$(mktemp -d /tmp/sesh-XXXXXX)"
    local layout_file="$layout_dir/layout.kdl"
    cat > "$layout_file" <<EOF
keybinds {
    shared {
        bind "Alt 1" { MoveFocus "left"; }
        bind "Alt 2" { MoveFocus "right"; }
        bind "Ctrl q" { Detach; }
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
    rm -rf "$layout_dir"
}
