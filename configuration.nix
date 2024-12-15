{
  imports = let
    # replace this with an actual commit id or tag
    commit = "c6134b6fff6bda95a1ac872a2a9d5f32e3c37856";
  in [
    "${builtins.fetchTarball {
      url = "https://github.com/Mic92/sops-nix/archive/${commit}.tar.gz";
      sha256 = "0dvak4whkhxsmg64g7dqj9m264ndral2w7f132fwhq89j30fmbwv";
    }}/modules/sops"
    ./machine
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "systemlos";
  networking.domain = "systemlos.org";

  system.stateVersion = "24.11";

  # locales
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  # nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
