{ config, lib, pkgs, ... }:
let
  fqdn = "vault.systemlos.org";
  port = 11001;
in
{

  sops.secrets."noreplyPassword/vaultwarden" = {
    key = "noreplyPassword";
    owner = "vaultwarden";
  };

  sops.secrets."services/vaultwarden" = {
    owner = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;

    package = pkgs.vaultwarden-postgresql;
    dbBackend = "postgresql";

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;

      DOMAIN = "https://${fqdn}";
      SIGNUPS_ALLOWED = "false";
      SMTP_FROM = "noreply@systemlos.org";
      SMTP_HOST = "mail.systemlos.org";
      SMTP_USERNAME = "noreply@systemlos.org";
      SMTP_PASSWORD_FILE = config.sops.secrets."noreplyPassword/vaultwarden".path;

      PUSH_ENABLED = "true";
      PUSH_RELAY_URI = "https://api.bitwarden.eu";
      PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";

      DATABASE_URL = "postgresql:///vaultwarden";

      SHOW_PASSWORD_HINT = "false";
    };
    environmentFile = config.sops.secrets."services/vaultwarden".path;
  };

  services.postgresql.ensureDatabases = [ "vaultwarden" ];
  services.postgresql.ensureUsers = [
    {
      name = "vaultwarden";
      ensureDBOwnership = true;
    }
  ];

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  backupPaths = [
    "/var/lib/vaultwarden"
  ];
}
