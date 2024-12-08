{config, lib, ...}:
let
  cfg = config.services.kanidm.serverSettings;
  fqdn = "auth.systemlos.org";
in {
  services.kanidm = {
    enableServer = true;
    serverSettings = {
      domain = "${fqdn}";
      origin = "https://${fqdn}";
      bindaddress = "127.0.0.1:8001";
      ldapbindaddress = "127.0.0.1:636";
      tls_chain = "/var/lib/kanidm/chain.pem";
      tls_key = "/var/lib/kanidm/key.pem";
      online_backup = {
        versions = 3;
        path = "/var/lib/kanidm/backups";
        schedule = "0 2 * * *";
      };
    };
  };

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${cfg.bindaddress}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  security.acme.certs."${fqdn}".postRun = ''
    cp key.pem /var/lib/kanidm && cp chain.pem /var/lib/kanidm
    chown kanidm:kanidm /var/lib/kanidm/key.pem && chown kanidm:kanidm /var/lib/kanidm/chain.pem
    chmod 400 /var/lib/kanidm/key.pem && chmod 400 /var/lib/kanidm/chain.pem
  '';
}
