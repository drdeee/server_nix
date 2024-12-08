{ config, lib, pkgs, ... }:
let
  grafanaCfg = config.services.grafana.settings;
  prometheusCfg = config.services.prometheus;
  fqdn = "metrics.systemlos.org";
in
{
  services.prometheus = {
    enable = true;
    port = 9000;
    globalConfig.scrape_interval = "30s";
    exporters = {
      node = {
        enable = true;
        port = 9100;
      };
      nginx = {
        enable = true;
        port = 9101;
      };
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
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = ["localhost:${toString prometheusCfg.exporters.nginx.port}"];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server.domain = fqdn;
      server.http_addr = "127.0.0.1";
      server.http_port = 9001;
      database = {
        type = "postgres";
	user = "grafana";
        host = "/run/postgresql/";
      };
    };
  };

  services.postgresql.ensureUsers = lib.singleton {
    name = "grafana";
    ensureDBOwnership = true;
  };
  services.postgresql.ensureDatabases = ["grafana"];

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${grafanaCfg.server.http_addr}:${toString grafanaCfg.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
