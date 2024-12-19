{config, lib, pkgs, ...}:
let
  remoteBase = "ebackup/server";
  mirrorBase = "SanDisk-Extreme55AE-01/systemlos";
  pruneOpts = [
    "--keep-daily 3"
    "--keep-weekly 5"
  ];

  generateBackupConfig = backupName: backupLocations: let
    serviceName = config.systemd.services."restic-backups-${backupName}".name;
    defaultResticConf = {
      initialize = true;
      paths = backupLocations;
      passwordFile = config.sops.secrets."restic/passwords/${backupName}".path;
      rcloneConfigFile = config.sops.secrets."restic/rclone".path;
      pruneOpts = pruneOpts;
      timerConfig = null;
    };
    runAfterLocal = {
      wantedBy = [ serviceName ];
      after = [ serviceName ];
    };
  in {
    sops.secrets."restic/rclone" = {};
    sops.secrets."restic/passwords/${backupName}" = {};

    services.restic.backups."${backupName}" = defaultResticConf // {
      repository = "/var/lib/restic/${backupName}";
      timerConfig.OnCalendar = "*-*-* 4:00:00";
    };

    services.restic.backups."${backupName}-remote" = defaultResticConf // {
      repository = "rclone:remote:/${remoteBase}/${backupName}";
    };

    services.restic.backups."${backupName}-mirror" = defaultResticConf // {
      repository = "rclone:mirror:/${mirrorBase}/${backupName}";
    };

    systemd.services."restic-backups-${backupName}-remote" = runAfterLocal;

    systemd.services."restic-backups-${backupName}-mirror" = {
      wantedBy = runAfterLocal.wantedBy;
      after = runAfterLocal.after;
      serviceConfig.ExecStart = lib.mkForce [
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
