{config, lib, pkgs, ...}:
let
  cfg = config.services.lldap.settings;
  fqdn = "users.systemlos.org";
  rootDomain = "systemlos";
  topDomain = "org";

  bootstrapScript = pkgs.writeScriptBin "bootstrap.sh" ''
    ${builtins.readFile "/etc/nixos/machine/apps/lldap/bootstrap.sh"}
  '';
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

  environment.systemPackages = with pkgs; [
    jq
    jo
    lldap
  ];

  users.users.lldap = {
    isSystemUser = true;
    linger = true;
    group = "lldap";
  };

  users.groups.lldap = {};

  systemd.services.lldap = {
    serviceConfig.User = "lldap";
  };

  systemd.services.lldap-bootstrap = {
    script = ''
      LLDAP_URL="http://${cfg.http_host}:${toString cfg.http_port}"
      LLDAP_ADMIN_USERNAME="${cfg.ldap_user_dn}"
      LLDAP_ADMIN_PASSWORD=$(<${config.sops.secrets."services/lldap/adminPassword".path})
      PATH=$PATH:${pkgs.curl}/bin:${pkgs.jq}/bin:${pkgs.jo}/bin:${pkgs.lldap}/bin
      ${bootstrapScript}/bin/bootstrap.sh

      lldap_set_password -b $LLDAP_URL --admin-username LLDAP_ADMIN_USERNAME \
        --admin-password $LLDAP_ADMIN_PASSWORD
        -u vaultwarden
        -p $(<${config.sops.secrets."services/lldap/adminPassword".path})
    '';
    after = [ "lldap.service" ];
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
