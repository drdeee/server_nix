{config, lib, ...}:
let
  cfg = config.services.lldap.settings;
  fqdn = "users.systemlos.org";
  rootDomain = "systemlos";
  topDomain = "org";
in {

  services.lldap = {
    enable = true;
    environment = {
      LLDAP_LDAP_USER_PASS_FILE = config.sops.secrets."services/lldap/adminPassword".path;
    };
    settings = {
      http_host = "127.0.0.1";
      http_port = 8001;
      http_url = "https://${fqdn}";
      ldap_host = "127.0.0.1";
      ldap_port = 3890;
      ldap_base_dn = "dc=${rootDomain},dc=${topDomain}";
      database_url = "postgresql:///lldap";
      ldap_user_dn = "system";
      ldap_user_email = "system@${rootDomain}.${topDomain}";
    };
  };

  sops.secrets."services/lldap/adminPassword" = {
    owner = config.systemd.services.lldap.serviceConfig.User;
  };

  users.users.lldap = {
    isSystemUser = true;
    linger = true;
    group = "lldap";
  };

  users.groups.lldap = {};

  systemd.services.lldap = {
    serviceConfig.User = "lldap";
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
