# Setup instructions for CachyOS

## Install packages

- Install zed, ghostty, mise, extension-manager, stow, watchexec, obsidian and foliate from CachyOS package installer
- Paru
  - Install Chrome using `paru -S google-chrome`
  - Install [Vicinae](https://github.com/vicinaehq/vicinae) using `paru -S vicinae-bin`
    - Use Extension Manager to install [Vicinae](https://github.com/dagimg-dot/vicinae-gnome-extension) the extension to get Gnome support
    - Install [Soulver CPP](https://github.com/vicinaehq/soulver-cpp) and use this as calculator backend. (Note that Swift should be installed before Soulver CPP)
    - Optionally disable and remove System Files search cache in Vicinae, and clean up Paru's cache using `paru -Sc`
    - To run Vicinae you must have `vicinae server` running on a shell or somewhere
  - Install [xidel](https://github.com/benibela/xidel) using `paru -S xidel-bin`
  - Install Sublime merge using `paru -S sublime-merge`
  - Install [passage](https://github.com/FiloSottile/passage) using `paru -S passage-git`
  - Install GitHub CLI using `paru -S github-cli`
  - Install appimagelauncher using `paru -S appimagelauncher`
- Run `mise use -g usage node go rust ghq bun`
- Setup GitHub SSH key access and GPG signing key
- Install [Tophat](https://github.com/fflewddur/tophat) from Extension Manager

## Set up Pi 

- Install Pi using `bun add -g @earendil-works/pi-coding-agent`
- Check if any post install is blocked using `bun pm -g untrusted`. Review and if all ok, then install them all using `bun pm trust -g --all`.
- `cd ~ && git clone git@github.com:ajitid/pi-config.git .pi`
- Follow setup instructions in `~/.pi/setup.md`
