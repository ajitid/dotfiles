# Setup instructions for CachyOS

## Install packages

- Install zed, ghostty, mise, extension-manager, stow, watchexec and foliate from CachyOS package installer
- Paru
  - Install Chrome using `paru -S google-chrome`
  - Install [Vicinae](https://github.com/vicinaehq/vicinae) using `paru -S vicinae-bin` and then use Extension Manager to install [Vicinae](https://github.com/dagimg-dot/vicinae-gnome-extension) the extension to get Gnome support
  - Install [xidel](https://github.com/benibela/xidel) using `paru -S xidel-bin`
  - Install Sublime merge using `paru -S sublime-merge`
  - Install [passage](https://github.com/FiloSottile/passage) using `paru -S passage-git`
  - Install GitHub CLI using `paru -S github-cli`
- Run `mise use -g usage node go rust ghq bun`
- Setup GitHub SSH key access and GPG signing key
- Install [Tophat](https://github.com/fflewddur/tophat) from Extension Manager

## Set up Pi 

- Install Pi using `bun add -g @mariozechner/pi-coding-agent`
- `cd ~ && git clone git@github.com:ajitid/pi-config.git .pi`
- Follow setup instructions in `~/.pi/setup.md`
