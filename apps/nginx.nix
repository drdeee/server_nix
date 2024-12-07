let
  ACME_MAIL = "admin@systemlos.org";
in {
  services.nginx = {
    enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@systemlos.org";
  };
}
