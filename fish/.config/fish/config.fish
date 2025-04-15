source /usr/share/cachyos-fish-config/cachyos-config.fish

fish_add_path -Pa $HOME/.local/bin $HOME/go/bin $HOME/scripts/git

# if this doesn't work, provide the fuill path of vscode here
set -x VISUAL 'code --wait'
set -x SUDO_EDITOR 'code --wait'

# overwrite greeting
# potentially disabling fastfetch
if status is-interactive
  function fish_greeting
  end
  
  set -x _ZO_ECHO 1
end

zoxide init --cmd j fish | source

abbr -a -- - 'cd -'
alias gi "cd ~/ghq/(ghq list | fzf)"
abbr gg 'ghq get -p'
alias g. 'smerge .'

# folder/file size
# du -h --max-depth=1 | sort -hr
# in above, `r` in `sort -hr` stands to show high to low in folder size
abbr huge 'du -h --max-depth=1 | sort -h'
# alternative https://github.com/bootandy/dust

# remove duplicate lines (except the blank ones) from welp and put the result into file welp2
# awk 'length == 0 ? 1 : !a[$0]++' welp > welp2

function mkcd --description 'Create and enter directory'
  if mkdir $argv
    if string match -qv -- '-*' $argv[-1]
      cd $argv[-1]
    end
  end
end

# TODO add completion
function up
  # set args (getopt -s sh abc: $argv); or help_exit
  # echo $argv[1]
  set -l dir_to_be_child $argv[1]
  # intentionally written this way because I'm learning syntax
  # https://stackoverflow.com/a/29177261/7683365
  if [ "$dir_to_be_child" = "" ]
    cd .. # in fish you can do `..` directly, and for cd-ing into a child dir we can use `src/` or `./src/`
  else
    cd -
    set -l alt_dir $PWD
    cd -
    set -l curr_dir $PWD

    set -l is_found 0
    while [ "$PWD" != "/" ]; and test $is_found -eq 0
      cd ..
      # https://www.unix.com/shell-programming-and-scripting/46716-execute-command-silently-quietly-within-shell.html
      set -l res (find $dir_to_be_child -maxdepth 0 -type d 2>/dev/null | wc -l)
      if test $res -eq 1
        set is_found 1
      end
    end

    if [ "$PWD" = "/" ]
      cd $alt_dir
      cd $curr_dir
      echo "Couldn't find $dir_to_be_child"
      return 1
    end

    set -l found_dir $PWD
    cd $curr_dir
    cd $found_dir
  end
end