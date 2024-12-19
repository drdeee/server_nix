{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix

    ./system
    ./apps

    ./backup.nix
  ];
}
