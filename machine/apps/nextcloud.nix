{ pkgs, config, ... }:
let
  backupPath = "/var/lib/nextcloud";
  fqdn = "cloud.systemlos.org";
  redirectToNew = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = fqdn;
  };
in
{

  sops.secrets."services/nextcloud/adminPassword" = {
    owner = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    hostName = fqdn;

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

  backups.paths = [
    backupPath
  ];

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
  };

  services.nginx.virtualHosts."cloud.aktivistisch.de" = redirectToNew;
}
