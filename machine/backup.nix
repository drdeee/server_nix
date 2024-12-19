{config, lib, pkgs, ...}:
let
  remoteBase = "ebackup/server";
  generateBackupConfig = backupName: backupLocations: {
    sops.secrets."restic/rclone" = {};
    sops.secrets."restic/passwords/${backupName}" = {};

    services.restic.backups."${backupName}" = {
      initialize = true;
      paths = backupLocations;
      repository = "/var/lib/restic/${backupName}";
      passwordFile = config.sops.secrets."restic/passwords/${backupName}".path;
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 5"
      ];
      timerConfig.OnCalendar = "*-*-* 4:00:00";
    };

    services.restic.backups."${backupName}-remote" = {
      initialize = true;
      paths = backupLocations;
      repository = "rclone:remote:/${remoteBase}/${backupName}";
      rcloneConfigFile = config.sops.secrets."restic/rclone".path;
      passwordFile = config.sops.secrets."restic/passwords/${backupName}".path;
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 5"
      ];
    };

    systemd.services."restic-backups-${backupName}-remote" = {
      wantedBy = [
        config.systemd.services."restic-backups-${backupName}".name
      ];
      after = [
        config.systemd.services."restic-backups-${backupName}".name
      ];
    };
  };

  allBackups = lib.attrsets.mergeAttrsList (lib.attrsets.mapAttrsToList generateBackupConfig config.backups);

in {
  options = {
    backups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      restic
    ];

    sops = allBackups.sops;
    systemd = allBackups.systemd;
    services = allBackups.services;
  };
}
