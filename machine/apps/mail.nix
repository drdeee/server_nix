{
  config, lib, ...
}:
let
  lldap = config.services.lldap.settings;
  primaryDomain = "systemlos.org";
  rootDomain = "systemlos";
  topDomain = "org";

in {
  services.maddy = {
    enable = true;
    user = "maddy";
    group = "maddy";
    primaryDomain = "${primaryDomain}";
    config = ''
      auth.ldap {
        urls ldap://${lldap.ldap_host}:${toString lldap.ldap_port}
        bind off
        dn_template "cn={username},ou=people,dc=${rootDomain},dc=${topDomain}"
        base_dn "ou=people,dc=${rootDomain},dc=${topDomain}"
      }
    '';
  };

  services.postgresql.ensureDatabases = ["maddy"];
  services.psotgresql.ensureUsers = lib.singleton {
    name = "maddy";
    ensureDBOwnership = true;
  };
}
