{pkgs,...}:
{
  services.nextcloud = {
    enable = true;
    hostName = "cloud.systemlos.org";
    package = pkgs.nextcloud30;
    extraApps = {
    inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
  };
  };
}
