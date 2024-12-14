{ pkgs, ...}:
{

  environment.systemPackages =with pkgs; [
    htop
    sops
  ];

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  virtualisation.docker.enable = true;
}
