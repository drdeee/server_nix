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
}
