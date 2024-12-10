{pkgs, config, ...}:
{

  sops.secrets."services/nextcloud/adminPassword" = {
    owner = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    hostName = "cloud.systemlos.org";

    package = pkgs.nextcloud30;

    database.createLocally = true;
    configureRedis = true;

    maxUploadSize = "16G";
    https = true;

    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets."services/nextcloud/adminPassword".path;
    };

    # extraApps = {
    #   inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
    # };
  };

  services.nginx.virtualHosts."cloud.systemlos.org" = {
    forceSSL = true;
    enableACME = true;
  };
}
