function mkcd --description 'Create and enter directory'
  if mkdir $argv
    if string match -qv -- '-*' $argv[-1]
      cd $argv[-1]
    end
  end
end
