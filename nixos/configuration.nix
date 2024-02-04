# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # G14
      # taken from https://github.com/NixOS/nixos-hardware
      <nixos-hardware/asus/zephyrus/ga401>

      # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # G14
  networking.hostName = "sullivan"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;

  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # CUSTOM CONFIG ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  # Use compressed RAM for swap
  zramSwap.enable = true;

  # setup NextDNS
  # from https://github.com/NixOS/nixpkgs/issues/225634#issuecomment-1880353935
  services.resolved = {
    enable = true;
    extraConfig = ''
      [Resolve]
      DNS=45.90.28.0#8f2a6d.dns.nextdns.io
      DNS=2a07:a8c0::#8f2a6d.dns.nextdns.io
      DNS=45.90.30.0#8f2a6d.dns.nextdns.io
      DNS=2a07:a8c1::#8f2a6d.dns.nextdns.io
      DNSOverTLS=yes
    '';
  };

  nix.settings.trusted-users = [ "root" "ajit" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  wget

    gnome.gnome-tweaks
    gnome.dconf-editor

    # for https://github.com/AstraExt/astra-monitor
    # look for ^ this comment in configuration.nix if you want to completely remove the extension 
    libgtop
    
    # no extension added for alt+tab as it can be configured natively: https://superuser.com/a/1413350
    gnome-extension-manager
    gnomeExtensions.dash-to-panel
    gnomeExtensions.switcher
    gnomeExtensions.clipboard-history
    # enable this once it starts supporting fuzzy on everything, not just files:
    # gnomeExtensions.fuzzy-app-search
  ];

  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ajit = {
    isNormalUser = true;
    description = "Ajit";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; []; # I should rather opt for home-manager. More below:
    # Anything that's distro dependent (eg. Gnome extensions) and 
    # OS level config (DNS, starts-up on boot/login like Tailscale) should go into `environment.systemPackages`.
    # Core OS items that you expect to be present for all users like wget, curl, 
    # shell like fish, a basic editor should also go into `environment.systemPackages`. 
    # Dev tooling like Git, ripgrep, browser, editor like VS Code or neovim are user-dependent (one user may use it, somebody else may not).
    # So dev tooling (and rest of the things really) will go into home-manager.
  };

  # not needed by me yet
  # services.flatpak.enable = true;

  # ROG Control Centre app doesn' open, but you can still use the command `asusctl -c 80` to limit battery.

  # If the key import fails and you don't see a UI to enter password, run `gpgconf --reload gpg-agent` and retry.
  # Otherwise log out and log back in.
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
    enableSSHSupport = true;
  };

  # for https://github.com/AstraExt/astra-monitor
  # ref. https://github.com/fflewddur/tophat/issues/106#issuecomment-1888146418
  environment.variables = {
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
  };

  # Enable the 1Password CLI, this also enables a SGUID wrapper so the CLI can authorize against the GUI app
  programs._1password = {
    enable = true;
  };
  # Enable the 1Passsword GUI with myself as an authorized user for polkit
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["ajit"];
  };
}

