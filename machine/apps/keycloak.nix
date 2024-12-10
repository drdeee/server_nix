{config, ...}: let
  fqdn = "auth.systemlos.org";
in {
  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      createLocally = true;
      host = "/run/postgresql";
    };

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
