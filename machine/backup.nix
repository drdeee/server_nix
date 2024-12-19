{config, lib, pkgs, ...}:
let
  remoteBase = "ebackup/server";
  mirrorBase = "SanDisk-Extreme55AE-01/systemlos";
  pruneOpts = [
    "--keep-daily 3"
    "--keep-weekly 5"
  ];

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
      pruneOpts = pruneOpts;
      timerConfig = null;
    };

    services.restic.backups."${backupName}-mirror" = {
      initialize = true;
      paths = backupLocations;
      repository = "rclone:mirror:/${mirrorBase}/${backupName}";
      rcloneConfigFile = config.sops.secrets."restic/rclone".path;
      passwordFile = config.sops.secrets."restic/passwords/${backupName}".path;
      pruneOpts = pruneOpts;
      timerConfig = null;
    };

    systemd.services."restic-backups-${backupName}-remote" = {
      wantedBy = [
        config.systemd.services."restic-backups-${backupName}".name
      ];
      after = [
        config.systemd.services."restic-backups-${backupName}".name
      ];
    };

    systemd.services."restic-backups-${backupName}-mirror" = {
      wantedBy = [
        config.systemd.services."restic-backups-${backupName}".name
      ];
      after = [
        config.systemd.services."restic-backups-${backupName}".name
      ];
      serviceConfig.ExecStart = [
        "${pkgs.restic}/bin/restic copy --from-repo /var/lib/restic/${backupName} --from-password-file ${config.sops.secrets."restic/passwords/${backupName}".path}"
        "${pkgs.restic}/bin/restic forget --prune ${lib.concatStringsSep " " pruneOpts}"
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
    sops = allBackups.sops;
    systemd = allBackups.systemd;
    services = allBackups.services;
  };
}
