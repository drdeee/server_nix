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
    config = lib.readFile ../config/maddy.conf;
  };

  # TODO mail client
  services.nginx.virtualHosts."${hostname}" = {
    globalRedirect = "https://aktivistisch.de";
    enableACME = true;
    forceSSL = true;
  };

  security.acme.certs."${hostname}".group = config.services.maddy.group;
  users.users.nginx.extraGroups = ["${config.services.maddy.group}"];


  services.postgresql.ensureDatabases = ["maddy"];
  services.postgresql.ensureUsers = lib.singleton {
    name = "maddy";
    ensureDBOwnership = true;
  };
}
