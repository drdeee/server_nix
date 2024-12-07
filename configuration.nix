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
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  system.stateVersion = "23.11";
}
