{config, pkgs, ...}: let
  fqdn = "auth0.systemlos.org";
in {
  sops.secrets."services/keycloak/databasePassword" = {};

  services.keycloak = {
    enable = true;

    package = pkgs.keycloak;

    database = {
      type = "postgresql";
      createLocally = true;
      passwordFile = config.sops.secrets."services/keycloak/databasePassword".path;
    };

    initialAdminPassword = "changeNow!!!11!";

    settings = {
      hostname = fqdn;
      http-relative-path = "/";
      http-port = 38080;
      http-host = "127.0.0.1";
      http-enabled = true;
    };
  };
  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.keycloak.settings.http-port}/";
  };
}
