{ config, pkgs, ... }: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
    })
  ];

  sops.secrets."services/mail/adminPassword" = {
    owner = config.systemd.services.lldap.serviceConfig.User;
    key = "services/ldap/adminPassword";
  };

  mailserver = {
    enable = true;
    fqdn = "mail.systemlos.org";
    domains = [ "systemlos.org" ];

    ldap = {
      enable = true;
      uris = ["ldap://127.0.0.1:3890"];
      searchBase = "ou=people,dc=systemlos,dc=org";
      bind.dn = "uid=system,ou=people,dc=systemlos,dc=org";
      bind.passwordFile = config.sops.secrets."services/mail/adminPassword".path;
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };

}
