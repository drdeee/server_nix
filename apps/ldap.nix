{config, lib, ...}:
let
  cfg = config.services.lldap.settings;
  fqdn = "users.systemlos.org";
in {
  services.lldap = {
    enable = true;
    settings = {
      http_host = "127.0.0.1";
      http_port = 8001;
      http_url = "https://${fqdn}";
      ldap_host = "127.0.0.1";
      ldap_base_dn = "dc=systemlos,dc=org";
      database_url = "postgresql://lldap@/run/postgresql/lldap";
    };
  };

  services.postgresql.ensureUsers = lib.singleton {
    name = "lldap";
    ensureDBOwnership = true;
  };
  services.postgresql.ensureDatabases = ["lldap"];

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${cfg.http_host}:${toString cfg.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
