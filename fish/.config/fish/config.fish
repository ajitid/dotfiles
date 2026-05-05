source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

mise activate fish | source

fish_add_path -g "$HOME/.bun/bin"

export EDITOR="zeditor --wait"
export LINKUP_API_KEY=(passage show linkup/api-key)
export ZAI_API_KEY=(passage show zai/api-key)
