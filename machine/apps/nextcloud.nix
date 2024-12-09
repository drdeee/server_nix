{pkgs, config, ...}:
{
  sops.secrets."services/nextcloud/adminPassword" = {};
  services.nextcloud = {
    enable = true;
    hostName = "cloud.systemlos.org";
    package = pkgs.nextcloud30;

    config.adminpassFile = config.sops.secrets."services/nextcloud/adminPassword".path;

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
    };
  };
}
