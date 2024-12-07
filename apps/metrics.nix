{ config, lib, pkgs, ... }:
let
  grafanaCfg = config.services.grafana.settings;
  prometheusCfg = config.services.prometheus;
  FQDN = "metrics.zentrale-pirna.org";
in
{
  services.prometheus = {
    enable = true;
    port = 9000;
    globalConfig.scrape_interval = "30s";
    exporters.node = {
      enable = true;
      port = 9100;
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = ["localhost:${toString prometheusCfg.exporters.node.port}"];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server.domain = FQDN;
      server.http_addr = "127.0.0.1";
      server.http_port = 9001;
    };
  };

  services.nginx.virtualHosts."${FQDN}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${grafanaCfg.server.http_addr}:${toString grafanaCfg.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
