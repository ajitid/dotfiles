{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ajit";
  home.homeDirectory = "/home/ajit";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # if vivaldi doesn't work, replace it with the following:
    # ```
    # (vivaldi.override {
    #   proprietaryCodecs = true;
    #   enableWidevine = false;
    # })
    # vivaldi-ffmpeg-codecs
    # widevine-cdm
    # ```
    # This for sure works
    # Read more at
    # https://help.vivaldi.com/desktop/media/html5-proprietary-media-on-linux/
    # https://www.reddit.com/r/Fedora/comments/xrtd99/the_exclusion_of_vpapi_is_a_huge_issue_but_what/
    # https://www.reddit.com/r/NixOS/comments/xiqg13/anyone_managed_to_set_up_vivaldi_lately/

    # TOOLS
    ghq
    ripgrep
    moreutils

    # LANGS & TOOLCHAIN
    go
    nodejs_20
    nodePackages.pnpm

    # GUIs
    vscode-fhs
    sublime-merge
    stremio
    google-chrome
    vlc
  ];

  # using parallel as Go may acquire a lock when installing packages, but I want the successive runs which only verify
  # that the pkgs are installed to run quickly
  home.activation.installGolangciLintPackages = lib.hm.dag.entryAfter [ "installPackages" ] ''
  PATH="${config.home.path}/bin:$PATH"

  $DRY_RUN_CMD parallel -i sh -c "go install {}@latest" -- \
  github.com/kisielk/errcheck \
  github.com/nishanths/exhaustive/cmd/exhaustive \
  honnef.co/go/tools/cmd/staticcheck
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/git/gitignoreglobal".source = src/gitignoreglobal; # prefixing RHS path with `./` works too
    ".golangci.yml".source = src/.golangci.yml;
    ".ssh/allowed_signers".source = src/ssh/allowed_signers;
    ".ssh/config".source = src/ssh/config;
    ".npmrc".text = "prefix=~/.local"; # adds binaries to ~/.local/bin and node modules to ~/.local/lib/node_modules

    # For copying/symlinking whole dir instead (I don't know if it symlinks the dir, by seeing recursive flag it probabaly doesn't):
    # ".local/bin" = {
    #   source = ./src/scripts;
    #   recursive = true;
    # };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ajit/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    VISUAL = "code --wait";
    SUDO_EDITOR = "code --wait";
    # https://github.com/signalapp/Signal-Desktop/issues/5869#issuecomment-1734194851
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Taken from https://github.com/Misterio77/nix-starter-configs/blob/main/minimal/home-manager/home.nix
  # Reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    # this looks helpful, but may not be needed:
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    extraConfig = {
      user = {
        name = "Ajit";
        email = "zlksnkwork@gmail.com";
	      signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKY13SJKReiR0UnTBI01Q6PqlV04vnxbjKRxqDlnZtsp";
      };
      core = {
        autocrlf = false;
        excludesfile = "~/.config/git/gitignoreglobal";
      };
      init = {
        defaultBranch = "main";
      };
      commit.gpgSign = true;
      gpg.format = "ssh";
      # from https://discourse.nixos.org/t/cant-commit-with-git-after-installing-1password/34021/2
      # and https://developer.1password.com/docs/ssh/git-commit-signing/
      # On non-NixOS linux systems this program path is `/opt/1Password/op-ssh-sign`
      gpg."ssh".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      # In "Step 2: Register your public key" of https://developer.1password.com/docs/ssh/git-commit-signing/ there's a section for adding to local machine. 
      # If not done GitHub will say signature is valid but `git log -1 --show-signature` or Sublime Merge won't.
      # You shouldn't be adding public key from 1pass as is into allowed_signers btw, as Sublime Merge would report the key is valid but `git log -1 --show-signature` still won't.
      # The reason is it needs to be prefixed with email(s) or wildcard to be a valid line. 
      # Open https://calebhearth.com/sign-git-with-ssh and https://blog.jakubholy.net/2022/git-commit-signature-with-1password/ and search for "No principal matched" in them.
      gpg."ssh".allowedSignersFile = "~/.ssh/allowed_signers";
      gc = {
        reflogexpireunreachable = 90;
        reflogexpire = 90;
      };
      push.default = "current";
      diff.algorithm = "histogram";
    };
  };

  # in the absence of home-manager, you may need danhper/fish-ssh-agent
  programs.fish = {
    enable = true;
    shellInit = ''
fish_add_path -Pa $HOME/.local/bin $HOME/go/bin $HOME/Documents/the-zig $HOME/ghq/github.com/ajitid/dotfiles/scripts

abbr -a -- - 'cd -'
alias gi "cd ~/ghq/(ghq list | fzf)"

# https://askubuntu.com/questions/499807/how-to-unzip-tgz-file-using-the-terminal
abbr tarunzip 'tar --extract --one-top-level --file'

alias l 'ls -aAlhp --group-directories-first'

# folder/file size
abbr huge 'du -h --max-depth=1 | sort -hr'
# alternative https://github.com/bootandy/dust

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
    '';
    interactiveShellInit = ''
set fish_greeting    
set _ZO_ECHO 1
    '';
  };
}
