{ ... }: {
  imports = [
    ./hardware-configuration.nix    
    ./packages.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "systemlos";
  networking.domain = "systemlos.org";
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6EaHDSRD0uSuNDMb5fvy9jL7Cc7o03QU8khhLBWYe7 admin@systemlos.org''];
    };
    elias = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6EaHDSRD0uSuNDMb5fvy9jL7Cc7o03QU8khhLBWYe7 admin@systemlos.org''];
      extraGroups = ["wheel"];
    };
  };
  system.stateVersion = "23.11";
}
