function sesh
    # Validate dependencies
    for dep in zellij lazygit yazi
        if not command -q $dep
            echo "sesh: '$dep' is not installed. See https://github.com/almonk/sesh#dependencies"
            return 1
        end
    end

    set -l tool (string lower -- $argv[1])

    if test "$tool" = list
        zellij list-sessions
        return
    end

    if test "$tool" = pickup
        set -l session (zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | head -1 | awk '{print $1}')
        if test -z "$session"
            echo "sesh: no sessions found"
            return 1
        end
        echo "sesh: attaching to $session"
        zellij attach "$session"
        return
    end

    set -l dir $argv[2]

    if test -z "$tool"
        set tool claude
    end

    if test -z "$dir"
        set dir (pwd)
    end

    set dir (realpath "$dir" 2>/dev/null)
    or begin
        echo "sesh: invalid directory: $argv[2]"
        return 1
    end

    switch $tool
        case claude
            if not command -q claude
                echo "sesh: 'claude' is not installed. Install with: npm install -g @anthropic-ai/claude-code"
                return 1
            end
            set cmd_block "pane size=\"65%\" command=\"claude\" {
            args \"--dangerously-skip-permissions\"
            cwd \"$dir\"
        }"
        case codex
            if not command -q codex
                echo "sesh: 'codex' is not installed. Install with: npm install -g @openai/codex"
                return 1
            end
            set cmd_block "pane size=\"65%\" command=\"codex\" {
            cwd \"$dir\"
        }"
        case amp
            if not command -q amp
                echo "sesh: 'amp' is not installed. Install with: npm install -g @sourcegraph/amp"
                return 1
            end
            set cmd_block "pane size=\"65%\" command=\"amp\" {
            cwd \"$dir\"
        }"
        case pi
            if not command -q pi
                echo "sesh: 'pi' is not installed."
                return 1
            end
            set cmd_block "pane size=\"65%\" command=\"pi\" {
            cwd \"$dir\"
        }"
        case '*'
            echo "Usage: sesh [claude|codex|amp|pi] [directory]"
            echo ""
            echo "Tools:"
            echo "  claude  Claude Code CLI (default)"
            echo "  codex   OpenAI Codex CLI"
            echo "  amp     Amp CLI (Sourcegraph)"
            echo "  pi      Pi CLI"
            echo ""
            echo "Examples:"
            echo "  sesh                  # Claude + lazygit in current dir"
            echo "  sesh pi               # Pi + lazygit in current dir"
            echo "  sesh claude ~/project # Claude + lazygit in ~/project"
            return 1
    end

    set -l layout_dir (mktemp -d /tmp/sesh-XXXXXX)
    set -l layout_file "$layout_dir/layout.kdl"
    echo "
keybinds {
    shared {
        bind \"Alt 1\" { MoveFocus \"left\"; }
        bind \"Alt 2\" { MoveFocus \"right\"; }
        bind \"Alt 3\" { ToggleFloatingPanes; }
        bind \"Ctrl q\" { Detach; }
    }
}
layout {
    pane split_direction=\"vertical\" {
        $cmd_block
        pane size=\"35%\" command=\"lazygit\" {
            cwd \"$dir\"
        }
    }
    floating_panes {
        pane command=\"yazi\" {
            cwd \"$dir\"
            width \"100%\"
            height \"50%\"
            x \"0%\"
            y \"51%\"
        }
        pane command=\"bash\" {
            args \"-c\" \"sleep 0.001 && zellij action toggle-floating-panes\"
            close_on_exit true
            width 1
            height 1
            x \"0%\"
            y \"0%\"
        }
    }
}
" > $layout_file

    zellij --layout "$layout_file"
    rm -rf "$layout_dir"
end
