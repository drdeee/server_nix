# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."mailu-admin" = {
    image = "ghcr.io/mailu/admin:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/data:/data:rw"
      "/var/lib/mailu/dkim:/dkim:rw"
    ];
    dependsOn = [
      "mailu-redis"
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--log-opt=tag=mailu-admin"
      "--network-alias=admin"
      "--network=mailu_default"
    ];
  };
  systemd.services."podman-mailu-admin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-antispam" = {
    image = "ghcr.io/mailu/rspamd:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/filter:/var/lib/rspamd:rw"
      "/var/lib/mailu/overrides/rspamd:/overrides:ro"
    ];
    dependsOn = [
      "mailu-antivirus"
      "mailu-front"
      "mailu-oletools"
      "mailu-redis"
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--hostname=antispam"
      "--log-opt=tag=mailu-antispam"
      "--network-alias=antispam"
      "--network=mailu_clamav"
      "--network=mailu_default"
      "--network=mailu_oletools"
    ];
  };
  systemd.services."podman-mailu-antispam" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_clamav.service"
      "podman-network-mailu_default.service"
      "podman-network-mailu_oletools.service"
    ];
    requires = [
      "podman-network-mailu_clamav.service"
      "podman-network-mailu_default.service"
      "podman-network-mailu_oletools.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-antivirus" = {
    image = "clamav/clamav-debian:1.2.3-45";
    volumes = [
      "/var/lib/mailu/filter/clamav:/var/lib/clamav:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=kill -0 `cat /tmp/clamd.pid` && kill -0 `cat /tmp/freshclam.pid`"
      "--health-interval=10s"
      "--health-retries=3"
      "--health-start-period=10s"
      "--health-timeout=5s"
      "--log-opt=tag=mailu-antivirus"
      "--network-alias=antivirus"
      "--network=mailu_clamav"
    ];
  };
  systemd.services."podman-mailu-antivirus" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_clamav.service"
    ];
    requires = [
      "podman-network-mailu_clamav.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-fetchmail" = {
    image = "ghcr.io/mailu/fetchmail:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/data/fetchmail:/data:rw"
    ];
    dependsOn = [
      "mailu-admin"
      "mailu-imap"
      "mailu-resolver"
      "mailu-smtp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--log-opt=tag=mailu-fetchmail"
      "--network-alias=fetchmail"
      "--network=mailu_default"
    ];
  };
  systemd.services."podman-mailu-fetchmail" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-front" = {
    image = "ghcr.io/mailu/nginx:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/certs:/certs:rw"
      "/var/lib/mailu/overrides/nginx:/overrides:ro"
    ];
    ports = [
      "127.0.0.1:80:80/tcp"
      "127.0.0.1:443:443/tcp"
      "127.0.0.1:25:25/tcp"
      "127.0.0.1:465:465/tcp"
      "127.0.0.1:587:587/tcp"
      "127.0.0.1:110:110/tcp"
      "127.0.0.1:995:995/tcp"
      "127.0.0.1:143:143/tcp"
      "127.0.0.1:993:993/tcp"
      "127.0.0.1:4190:4190/tcp"
    ];
    dependsOn = [
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--log-opt=tag=mailu-front"
      "--network-alias=front"
      "--network=mailu_default"
      "--network=mailu_radicale"
      "--network=mailu_webmail"
    ];
  };
  systemd.services."podman-mailu-front" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
      "podman-network-mailu_radicale.service"
      "podman-network-mailu_webmail.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
      "podman-network-mailu_radicale.service"
      "podman-network-mailu_webmail.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-fts_attachments" = {
    image = "apache/tika:2.9.2.1-full";
    dependsOn = [
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--health-cmd=wget -nv -t1 -O /dev/null http://127.0.0.1:9998/tika || exit 1"
      "--health-interval=10s"
      "--health-retries=3"
      "--health-start-period=10s"
      "--health-timeout=5s"
      "--hostname=tika"
      "--log-opt=tag=mailu-tika"
      "--network-alias=fts_attachments"
      "--network=mailu_fts_attachments"
    ];
  };
  systemd.services."podman-mailu-fts_attachments" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_fts_attachments.service"
    ];
    requires = [
      "podman-network-mailu_fts_attachments.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-imap" = {
    image = "ghcr.io/mailu/dovecot:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/mail:/mail:rw"
      "/var/lib/mailu/overrides/dovecot:/overrides:ro"
    ];
    dependsOn = [
      "mailu-front"
      "mailu-fts_attachments"
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--log-opt=tag=mailu-imap"
      "--network-alias=imap"
      "--network=mailu_default"
      "--network=mailu_fts_attachments"
    ];
  };
  systemd.services."podman-mailu-imap" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
      "podman-network-mailu_fts_attachments.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
      "podman-network-mailu_fts_attachments.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-oletools" = {
    image = "ghcr.io/mailu/oletools:2024.06";
    dependsOn = [
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--hostname=oletools"
      "--log-opt=tag=mailu-oletools"
      "--network-alias=oletools"
      "--network=mailu_oletools"
    ];
  };
  systemd.services."podman-mailu-oletools" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_oletools.service"
    ];
    requires = [
      "podman-network-mailu_oletools.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-redis" = {
    image = "redis:alpine";
    volumes = [
      "/var/lib/mailu/redis:/data:rw"
    ];
    dependsOn = [
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--network-alias=redis"
      "--network=mailu_default"
    ];
  };
  systemd.services."podman-mailu-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-resolver" = {
    image = "ghcr.io/mailu/unbound:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    log-driver = "journald";
    extraOptions = [
      "--ip=192.168.203.254"
      "--log-opt=tag=mailu-resolver"
      "--network-alias=resolver"
      "--network=mailu_default"
    ];
  };
  systemd.services."podman-mailu-resolver" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-smtp" = {
    image = "ghcr.io/mailu/postfix:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/mailqueue:/queue:rw"
      "/var/lib/mailu/overrides/postfix:/overrides:ro"
    ];
    dependsOn = [
      "mailu-front"
      "mailu-resolver"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=192.168.203.254"
      "--log-opt=tag=mailu-smtp"
      "--network-alias=smtp"
      "--network=mailu_default"
    ];
  };
  systemd.services."podman-mailu-smtp" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_default.service"
    ];
    requires = [
      "podman-network-mailu_default.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-webdav" = {
    image = "ghcr.io/mailu/radicale:2024.06";
    volumes = [
      "/var/lib/mailu/dav:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--log-opt=tag=mailu-webdav"
      "--network-alias=webdav"
      "--network=mailu_radicale"
    ];
  };
  systemd.services."podman-mailu-webdav" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_radicale.service"
    ];
    requires = [
      "podman-network-mailu_radicale.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mailu-webmail" = {
    image = "ghcr.io/mailu/webmail:2024.06";
    environment = {
      "ADMIN" = "true";
      "ANTIVIRUS" = "clamav";
      "API" = "false";
      "API_TOKEN" = "";
      "AUTH_RATELIMIT_IP" = "5/hour";
      "AUTH_RATELIMIT_USER" = "50/day";
      "COMPOSE_PROJECT_NAME" = "mailu";
      "COMPRESSION" = "";
      "COMPRESSION_LEVEL" = "";
      "CREDENTIAL_ROUNDS" = "12";
      "DEFAULT_SPAM_THRESHOLD" = "80";
      "DISABLE_STATISTICS" = "True";
      "DMARC_RUA" = "admin";
      "DMARC_RUF" = "admin";
      "DOMAIN" = "mail.systemlos.org";
      "FETCHMAIL_DELAY" = "600";
      "FETCHMAIL_ENABLED" = "true";
      "FULL_TEXT_SEARCH" = "en";
      "FULL_TEXT_SEARCH_ATTACHMENTS" = "true";
      "HOSTNAMES" = "mail.systemlos.org";
      "LOG_LEVEL" = "INFO";
      "MESSAGE_RATELIMIT" = "200/day";
      "MESSAGE_SIZE_LIMIT" = "50000000";
      "POSTMASTER" = "admin";
      "REAL_IP_FROM" = "";
      "REAL_IP_HEADER" = "";
      "RECIPIENT_DELIMITER" = "+";
      "REJECT_UNLISTED_RECIPIENT" = "";
      "RELAYHOST" = "";
      "RELAYNETS" = "";
      "SCAN_MACROS" = "true";
      "SECRET_KEY" = "XA1RBOV9FDLHP45E";
      "SITENAME" = "Mailu";
      "SUBNET" = "192.168.203.0/24";
      "TLS_FLAVOR" = "cert";
      "TZ" = "Etc/UTC";
      "WEBDAV" = "radicale";
      "WEBMAIL" = "roundcube";
      "WEBROOT_REDIRECT" = "/webmail";
      "WEBSITE" = "https://mail.systemlos.org";
      "WEB_ADMIN" = "/admin";
      "WEB_API" = "/api";
      "WEB_WEBMAIL" = "/webmail";
      "WELCOME" = "false";
      "WELCOME_BODY" = "Welcome to your new email account, if you can read this, then it is configured properly!";
      "WELCOME_SUBJECT" = "Welcome to your new email account";
    };
    environmentFiles = [
      "/etc/nixos/machine/apps/mailu/mailu.env"
    ];
    volumes = [
      "/var/lib/mailu/overrides/roundcube:/overrides:ro"
      "/var/lib/mailu/webmail:/data:rw"
    ];
    dependsOn = [
      "mailu-front"
    ];
    log-driver = "journald";
    extraOptions = [
      "--log-opt=tag=mailu-webmail"
      "--network-alias=webmail"
      "--network=mailu_webmail"
    ];
  };
  systemd.services."podman-mailu-webmail" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mailu_webmail.service"
    ];
    requires = [
      "podman-network-mailu_webmail.service"
    ];
    partOf = [
      "podman-compose-mailu-root.target"
    ];
    wantedBy = [
      "podman-compose-mailu-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-mailu_clamav" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mailu_clamav";
    };
    script = ''
      podman network inspect mailu_clamav || podman network create mailu_clamav --driver=bridge
    '';
    partOf = [ "podman-compose-mailu-root.target" ];
    wantedBy = [ "podman-compose-mailu-root.target" ];
  };
  systemd.services."podman-network-mailu_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mailu_default";
    };
    script = ''
      podman network inspect mailu_default || podman network create mailu_default --driver=bridge --subnet=192.168.203.0/24
    '';
    partOf = [ "podman-compose-mailu-root.target" ];
    wantedBy = [ "podman-compose-mailu-root.target" ];
  };
  systemd.services."podman-network-mailu_fts_attachments" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mailu_fts_attachments";
    };
    script = ''
      podman network inspect mailu_fts_attachments || podman network create mailu_fts_attachments --driver=bridge --internal
    '';
    partOf = [ "podman-compose-mailu-root.target" ];
    wantedBy = [ "podman-compose-mailu-root.target" ];
  };
  systemd.services."podman-network-mailu_oletools" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mailu_oletools";
    };
    script = ''
      podman network inspect mailu_oletools || podman network create mailu_oletools --driver=bridge --internal
    '';
    partOf = [ "podman-compose-mailu-root.target" ];
    wantedBy = [ "podman-compose-mailu-root.target" ];
  };
  systemd.services."podman-network-mailu_radicale" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mailu_radicale";
    };
    script = ''
      podman network inspect mailu_radicale || podman network create mailu_radicale --driver=bridge
    '';
    partOf = [ "podman-compose-mailu-root.target" ];
    wantedBy = [ "podman-compose-mailu-root.target" ];
  };
  systemd.services."podman-network-mailu_webmail" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mailu_webmail";
    };
    script = ''
      podman network inspect mailu_webmail || podman network create mailu_webmail --driver=bridge
    '';
    partOf = [ "podman-compose-mailu-root.target" ];
    wantedBy = [ "podman-compose-mailu-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-mailu-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
