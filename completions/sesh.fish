complete -c sesh -f
complete -c sesh -n "test (count (commandline -opc)) -eq 1" -a "claude codex amp pi pickup list" -d "AI tool"
complete -c sesh -n "test (count (commandline -opc)) -eq 2" -a "(__fish_complete_directories)" -d "Directory"
