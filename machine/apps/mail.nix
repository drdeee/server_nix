{
  config, lib, ...
}:
let
  lldap = config.services.lldap.settings;
  primaryDomain = "systemlos.org";
  baseDN = "dc=systemlos,dc=org";
in {
  services.maddy = {
    enable = true;
    user = "maddy";
    group = "maddy";
    primaryDomain = "${primaryDomain}";
    # dn_template "cn={username},ou=people,dc=${rootDomain},dc=${topDomain}"
    config = ''
      auth.ldap ldap {
        urls ldap://${lldap.ldap_host}:${toString lldap.ldap_port}

        bind plain "cn=system,ou=people,${baseDN}" "{env:MADDY_LDAP_PASSWORD}"
        base_dn "${baseDN}"

        starttls off
        debug off
        connect_timeout 1m
      }
    '';
  };

  services.postgresql.ensureDatabases = ["maddy"];
  services.postgresql.ensureUsers = lib.singleton {
    name = "maddy";
    ensureDBOwnership = true;
  };
}
