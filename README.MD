# Dotfiles

Harcoded to Zephyrus G14 hardware. `configuration.nix` mentions `# G14` wherever that hardcoding has been made.

## High Level Commands

- hey-init-nixos.sh
- hey-sync-nix.sh
- hey-save-space.sh

## Setup Your Computer

Install NixOS. I used:
- 23.05 version as I couldn't make 23.11 and 24.04 to install on my G14
- ajit as the username

Then run these:

```
mkdir -p ~/ghq/github.com/ajitid && cd $_
nix-shell -p git
git clone https://github.com/ajitid/dotfiles.git
exit

sudoedit /etc/nixos/configuration.nix
# Add `cachix` into `environment.systemPackages` then save
sudo nixos-rebuild switch

# Upgrade nixos to latest. See https://nixos.org/manual/nixos/stable/#sec-upgrading
# use latest stable channel rather than the mentioned 24.05 here:
sudo nix-channel --add https://channels.nixos.org/nixos-24.05 nixos
sudo nixos-rebuild switch --upgrade
reboot

### nixos stops working upon reboot (stucks at reboot) so the steps below are not what I'd run. nixos-hardware needs latest nixos that's why I had to update it above.

sudoedit /etc/nixos/configuration.nix
# Change `system.stateVersion` to the the lastest version then save
sudo nixos-rebuild switch
reboot

cd dotfiles/scripts
./hey-init-nixos.sh
./pvt/hey-update-nix.sh
./pvt/hey-apply-nixos.sh
reboot
asusctl -c 80 # limit battery to 80%, doesn't need reboot to apply itself
./pvt/hey-apply-home-manager.sh
# logout and log back in
# change ~/ghq/github.com/ajitid/dotfiles Git origin from HTTPS to SSH
# enable gnome extensions and manually install astra-monitor
# configure keyboard shortcuts and extensions config
# Open chrome://flags/ → Preferred Ozone platform, choose Wayland
#
# You may need to increase watchers: https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
# ^ modify this https://github.com/euank/nixpkgs/commit/835749939f86f623bbc7d16b27c144e4b42789b8
    to use 'max_user_watches' instead of 'max_user_instances' or just follow VS Code instructions direclty
#   Again, you may actually not need to do this because of https://github.com/NixOS/nixpkgs/issues/36214#issuecomment-860249879
#   ^ If this is actually the case then remove the comment
```

## Additional Notes

Rest of the low-level commands can be executed by cd-ing into `<dotfiles-path>/scripts/pvt` and then running `./<script-name>.sh`.

> [!NOTE]
>
> Trim generations script ([wiki](https://nixos.wiki/wiki/NixOS_Generations_Trimmer), [gist](https://gist.github.com/MaxwellDupre/3077cd229490cf93ecab08ef2a79c852)) is not supposed to be run directly, rather use hey-save-space.sh

If you add new scripts, do `chmod u+x scripts/*.sh`.

## To Do

**Look into**:

- https://github.com/mercurytechnologies/nix-your-shell (useful for `nix-shell -p <pkgname>` and keeping fish as the shell, not bash)
- https://github.com/zzhaolei/transient.fish (this explains better: https://github.com/romkatv/powerlevel10k#transient-prompt)
- Removing harcoding to G14, see how https://github.com/hlissner/dotfiles does it
- Seems like people tend to disable smooth scrolling a lot https://www.reddit.com/r/NixOS/comments/scf0ui/how_would_i_update_desktop_file/

**Other stuff to automate**:

- Running `asusctl -c 80`
- enabling extensions and manually installing that astra-monitor
- configuring keyboard shortcuts and extensions config via dconf cli
- Prefer ozone platform to wayland by placing a config file for chrome somewhere  
  Can be manually set by chrome://flags/ -> Preferred Ozone platform and choosing Wayland  
  Also see for "placing a file method" https://www.reddit.com/r/archlinux/comments/13gtogn/chrome_browser_blurry_text_after_gnome_441_update/

**Hibernation stuff**:

https://discourse.nixos.org/t/hybrid-sleep-not-working-suspend-hibernation-works/17492  
^ I see the same thing. And because I'm using zram, `systemctl hibernate` won't work.  
The instructions to properly set-up hibernate is here: https://www.worldofbs.com/nixos-framework/#setting-up-hibernate
