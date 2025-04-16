#!/usr/bin/fish

# paru flags:
# -S install something
# -y udpate package cache list
# -u upgrade system

paru -Syu
# omitting -y flag here as we ran with -y just above
paru -S firefox-developer-edition ghostty visual-studio-code-bin
paru -S quickemu
paru -S upnote-appimage go partitionmanager ntfs-3g ghq moreutils zoxide caffeine-ng
paru -S sublime-merge
paru -S stow

# cachyos replaces ls with exa so I need to specify full path for ls here
/usr/bin/ls -d */ | xargs -I {} stow {} -t ~

# VS Code will automatically install `golangci-lint` binary to `~/go/bin` but you'd need to install the rest:
parallel-moreutils -i sh -c "go install {}@latest" -- \
github.com/kisielk/errcheck \
github.com/nishanths/exhaustive/cmd/exhaustive \
honnef.co/go/tools/cmd/staticcheck
# I'm using `parallel` from `moreutils` package here. In Arch it is available as `parallel-moreutils` whereas in Nix it is available as `parallel`.
# Reason for using `parallel`: using parallel as Go may acquire a lock when installing packages, but I want the successive runs which only verify that the pkgs are installed to run quickly.

# keeping fisher completely local, even though it is available through paru
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install danhper/fish-ssh-agent