let
  ACME_MAIL = "admin@systemlos.org";
in {
  services.nginx = {
    enable = true;
  };

  security.acme.certs = {
    defaults.email = "admin@systemlos.org"
  };
}
