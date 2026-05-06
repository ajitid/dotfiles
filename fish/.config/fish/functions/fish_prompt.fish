function precmd --on-event fish_prompt
  # because `exit_status` is defined as global using `-g` once in config.fish
  # we don't need to use `-g` again to set it
  set exit_status $status

  set -l normal (set_color normal)
  set -l italics (set_color -i)

  if test $exit_status != 0
    echo "$italics<exited with" $exit_status "status>$normal"
  end
end

# Defined interactively
function fish_prompt
  set -l cyan (set_color -o cyan)
  set -l red (set_color -o red)
  set -l green (set_color -o green)
  set -l normal (set_color normal)

  set -l cwd $cyan(basename (prompt_pwd))

  set -l arrow_color "$green"
  if test $exit_status != 0
    set arrow_color "$red"
  end

  set -l arrow "$arrow_color➜ "
  if test "$USER" = root
    set arrow "$arrow_color# "
  end

  echo -s $cwd
  echo -s $arrow $normal
end
