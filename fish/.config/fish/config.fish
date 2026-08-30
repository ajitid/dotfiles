function fish_greeting
end

if status is-interactive
    set -U fish_greeting
    set -g exit_status 0
end

fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin "$HOME/.local/bin"

if type -q fzf
    fzf --fish | source
end

set -gx EDITOR "zed --wait"

# When using terminal via ssh (or via ssh+tmux), `security` stuff doesn't get unlocked automatically.
# We need to manually authorize.
function marinate
    if status is-interactive
        security unlock-keychain ~/Library/Keychains/login.keychain-db
        _fish_set_keys
    end
end

function _fish_set_keys
    set -gx LINKUP_API_KEY (security find-generic-password -a "$USER" -s "linkup/api-key" -w)
    set -gx REDDIT_CLIENT_ID (security find-generic-password -a "$USER" -s "reddit/client-id" -w)
    set -gx REDDIT_CLIENT_SECRET (security find-generic-password -a "$USER" -s "reddit/client-secret" -w)
    set -gx REDDIT_USER_AGENT 'linux:pi-reddit-skill:v0.1 by u_ajitid'
end

_fish_set_keys

abbr -a -- - 'cd -'
abbr gg 'ghq get -p'
alias g. 'smerge .'

function gi
  set -l repo (ghq list | fzf)
  or return
  cd "$HOME/ghq/$repo"
end

# ncdu for folder sizes

function caffe_wake_up
    # awake the display
    # you have 120 sec = 2 min to login using Parsec
    caffeinate -d -u -t 120 &
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# needed for Mosh at the client side to connect to this machine
# set -gx LANG en_IN.UTF-8
