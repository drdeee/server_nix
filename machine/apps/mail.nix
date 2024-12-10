{ config, pkgs, ... }: let
  fqdn = "mail.systemlos.org";
  domainList = [ "systemlos.org" ];
in {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
    })
  ];

  sops.secrets."services/mail/ldapPassword" = {};

  mailserver = {
    enable = true;
    fqdn = "${fqdn}";
    domains = domainList;

    ldap = {
      enable = true;
      uris = ["ldap://127.0.0.1:3890"];
      searchBase = "ou=people,dc=systemlos,dc=org";
      bind.dn = "uid=system,ou=people,dc=systemlos,dc=org";
      bind.passwordFile = config.sops.secrets."services/mail/ldapPassword".path;
    };
    certificateScheme = "acme";
  };

  # roundcube
  services.roundcube = {
    enable = true;
    hostName = fqdn;
    dicts = with pkgs.aspellDicts; [ en de ];
    configureNginx = true;
  };

  services.postgresql.ensureDatabases = ["roundcube"];
  services.postgresql.ensureUsers = [
    {
      name = "roundcube";
      ensureDBOwnership = true;
    }
  ];
}
