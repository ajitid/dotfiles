function fish_greeting
end

if status is-interactive
    set -U fish_greeting
    set -g exit_status 0
end

fish_add_path -g "$HOME/.bun/bin"
fish_add_path -g "$HOME/.local/bin"

set -gx EDITOR "zed --wait"
set -gx LINKUP_API_KEY (secret-tool lookup linkup api-key)

set -gx VOXTER_API_KEY (secret-tool lookup voxter api-key)
set -gx VOXTER_CONTEXT_BIAS 'Claude Code,Skia,skia-safe,Bevy,OPENRNDR,Mistral'

set -gx REDDIT_CLIENT_ID (secret-tool lookup reddit client-id)
set -gx REDDIT_CLIENT_SECRET (secret-tool lookup reddit client-secret)
set -gx REDDIT_USER_AGENT 'linux:pi-reddit-skill:v0.1 by u_ajitid'

abbr -a -- - 'cd -'
abbr gg 'ghq get -p'
alias g. 'smerge .'
function gcd
  set -l repo (ghq list | fzf)
  or return
  cd "$HOME/ghq/$repo"
end

# folder/file size
# du -h --max-depth=1 | sort -hr
# in above, `r` in `sort -hr` stands to show high to low in folder size
# abbr huge 'du -h --max-depth=1 | sort -h'
# alternative https://github.com/bootandy/dust

# remove duplicate lines (except the blank ones) from welp and put the result into file welp2
# awk 'length == 0 ? 1 : !a[$0]++' welp > welp2
