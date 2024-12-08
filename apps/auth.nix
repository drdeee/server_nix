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
      # db_path = "/var/lib/kanidm/kanidm.db"; -> readonly
      tls_chain = "/var/lib/acme/${fqdn}/chain.pem";
      tls_key = "/var/lib/acme/${fqdn}/key.pem";
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
}
