{
  imports = [
    ./nginx.nix
    ./metrics.nix
    ./ldap.nix
    ./postgresql.nix
    # ./mail.nix
    ./nextcloud.nix
    ./keycloak.nix
  ];
}
