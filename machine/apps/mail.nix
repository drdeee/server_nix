{
  config, lib, ...
}:
let
  lldap = config.services.lldap.settings;
  hostname = "mail.systemlos.org";
  primaryDomain = "systemlos.org";
  baseDN = "dc=systemlos,dc=org";
in {
  sops.secrets."services/maddy/ldapPassword" = {
    owner = "maddy";
  };

  services.maddy = {
    enable = true;
    user = "maddy";
    group = "maddy";

    hostname = "${hostname}";
    primaryDomain = "${primaryDomain}";
    localDomains = ["${primaryDomain}"];

    openFirewall = true;

    tls.certificates = [
      {
        keyPath = "/var/lib/acme/${hostname}/key.pem";
        certPath = "/var/lib/acme/${hostname}/cert.pem";
      }
    ];

    secrets = [
      config.sops.secrets."services/maddy/ldapPassword".path
    ];
    # dn_template "cn={username},ou=people,dc=${rootDomain},dc=${topDomain}"
    config = ''
      # Authentication
      auth.ldap local_ldap {
        urls ldap://${lldap.ldap_host}:${toString lldap.ldap_port}

        bind plain "cn=system,ou=people,${baseDN}" "{env:LDAP_PASSWORD}"
        base_dn "${baseDN}"

        starttls off
        debug off
        connect_timeout 1m
      }
      ${lib.readFile ../config/maddy.conf}
    '';
  };

  systemd.services.maddy.preStart = ''
    touch /var/lib/maddy/aliases
    mkdir -p /var/lib/maddy/storage
  '';

  security.acme.certs."${hostname}".group = config.services.maddy.group;
  users.users.nginx.extraGroups = ["${config.services.maddy.group}"];


  services.postgresql.ensureDatabases = ["maddy"];
  services.postgresql.ensureUsers = lib.singleton {
    name = "maddy";
    ensureDBOwnership = true;
  };

  # roundcube
  services.roundcube = {
    enable = true;
    hostName = "${hostname}";
    dicts = [ en de ];
    database = {
      host = "/run/postgresql";
    };
    configureNginx = true;
  };

  services.nginx.virtualHosts."${hostname}" = {
    enableACME = true;
    forceSSL = true;
  };

  services.postgresql.ensureDatabases = ["roundcube"];
  services.postgresql.ensureUsers = lib.singleton {
    name = "roundcube";
    ensureDBOwnership = true;
  }

}
