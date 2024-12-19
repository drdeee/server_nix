{ config, lib, pkgs, ... }:
let
  remoteBase = "ebackup/server";
  mirrorBase = "SanDisk-Extreme55AE-01/systemlos";
  pruneOpts = [
    "--keep-daily 3"
    "--keep-weekly 5"
  ];

  serviceName = config.systemd.services."restic-backups-local".name;
  defaultResticConf = {
    initialize = true;
    paths = config.backupPaths;
    rcloneConfigFile = config.sops.secrets."restic/rclone".path;
    pruneOpts = pruneOpts;
    timerConfig = null;
  };

  runAfterLocal = {
    wantedBy = [ serviceName ];
    after = [ serviceName ];
  };
in
{
  options = {
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    sops.secrets."restic/rclone" = { };
    sops.secrets."restic/passwords/local" = { };
    sops.secrets."restic/passwords/remote" = { };
    sops.secrets."restic/passwords/mirror" = { };

    services.restic.backups.local = defaultResticConf // {
      repository = "/var/lib/resticRepo";
      passwordFile = config.sops.secrets."restic/passwords/local".path;
      timerConfig.OnCalendar = "*-*-* 4:00:00";
    };

    services.restic.backups.remote = defaultResticConf // {
      repository = "rclone:remote:/${remoteBase}";
      passwordFile = config.sops.secrets."restic/passwords/remote".path;
    };

    services.restic.backups.mirror = defaultResticConf // {
      repository = "rclone:mirror:/${mirrorBase}";
      passwordFile = config.sops.secrets."restic/passwords/mirror".path;
    };

    systemd.services."restic-backups-remote" = runAfterLocal;

    systemd.services."restic-backups-mirror" = {
      wantedBy = runAfterLocal.wantedBy;
      after = runAfterLocal.after;
      serviceConfig.ExecStart = lib.mkForce [
        "${pkgs.restic}/bin/restic copy --from-repo /var/lib/resticRepo --from-password-file ${config.sops.secrets."restic/passwords/local".path}"
        "${pkgs.restic}/bin/restic forget --prune ${lib.concatStringsSep " " pruneOpts}"
      ];
    };
  };
}
