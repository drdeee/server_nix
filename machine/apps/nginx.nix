let
  ACME_MAIL = "admin@systemlos.org";
in {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@systemlos.org";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
