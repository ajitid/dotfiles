# Dotfiles

Harcoded to Zephyrus G14 hardware. `configuration.nix` mentions `# G14` wherever that hardcoding has been made.

## High Level Commands

- hey-init-nixos.sh
- hey-sync-nix.sh
- hey-save-space.sh

## Setup Your Computer

Install NixOS, and run these:

```
mkdir -p ~/ghq/github.com/ajitid && cd $_
nix-shell -p git
git clone https://github.com/ajitid/dotfiles.git
exit
cd scripts
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
```

## Additional Notes

Rest of the low-level commands can be executed by cd-ing into `<dotfiles-path>/scripts/pvt` and then running `./<script-name>.sh`.

> [!NOTE]
>
> Trim generations script ([wiki](https://nixos.wiki/wiki/NixOS_Generations_Trimmer), [gist](https://gist.github.com/MaxwellDupre/3077cd229490cf93ecab08ef2a79c852)) is not supposed to be run directly, rather use hey-trim-gens.sh

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
