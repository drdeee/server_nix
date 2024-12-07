{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./system
    ./apps
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "systemlos";
  networking.domain = "systemlos.org";

  system.stateVersion = "23.11";

  # locales
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
}
