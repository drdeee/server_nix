{ pkgs, ...}:
{

  environment.systemPackages =with pkgs; [
    htop
    sops
    jq
    jo
  ];

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
}
