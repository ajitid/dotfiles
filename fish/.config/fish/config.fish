function fish_greeting
end

if status is-interactive
    set -U fish_greeting
    set -g exit_status 0
end

if status is-interactive; and set -q SSH_CONNECTION
    security unlock-keychain ~/Library/Keychains/login.keychain-db
end

fzf --fish | source

fish_add_path -g "$HOME/.local/bin"

set -gx EDITOR "zed --wait"
set -gx LINKUP_API_KEY (security find-generic-password -a "$USER" -s "linkup/api-key" -w)
set -gx REDDIT_CLIENT_ID (security find-generic-password -a "$USER" -s "reddit/client-id" -w)
set -gx REDDIT_CLIENT_SECRET (security find-generic-password -a "$USER" -s "reddit/client-secret" -w)
set -gx REDDIT_USER_AGENT 'linux:pi-reddit-skill:v0.1 by u_ajitid'

abbr -a -- - 'cd -'
abbr gg 'ghq get -p'
alias g. 'smerge .'

function gi
  set -l repo (ghq list | fzf)
  or return
  cd "$HOME/ghq/$repo"
end

function caffe_wake_up_sunshine
    # you have 120 sec = 2 min to login using moonlight
    caffeinate -d -u -t 120 &
    sleep 1
    # brew services restart sunshine # optional, run it in sunshine failed loading itself
end
