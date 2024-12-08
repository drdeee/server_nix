{ pkgs, ...}:
{

  environment.systemPackages =with pkgs; [
    htop
  ];

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}
