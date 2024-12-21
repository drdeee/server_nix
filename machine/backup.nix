{ config, lib, pkgs, ... }:
let
  remoteBase = "ebackup/server";
  mirrorBase = "SanDisk-Extreme55AE-01/systemlosBackup";
  pruneOpts = [
    "--keep-daily 3"
    "--keep-weekly 5"
  ];

  remoteName = config.systemd.services."restic-backups-remote".name;
  defaultResticConf = {
    initialize = true;
    paths = config.backups.paths;
    rcloneConfigFile = config.sops.secrets."restic/rclone".path;
    pruneOpts = pruneOpts;
    timerConfig = null;
  };
in
{
  options = {
    backups.paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    backups.preScripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "echo pre-script" ];
    };
    backups.postScripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "echo post-script" ];
    };
  };

  config = {
    sops.secrets."restic/rclone" = { };
    sops.secrets."restic/passwords/remote" = { };
    sops.secrets."restic/passwords/mirror" = { };

    services.restic.backups.remote = defaultResticConf // {
      repository = "rclone:remote:/${remoteBase}";
      passwordFile = config.sops.secrets."restic/passwords/remote".path;
      timerConfig.OnCalendar = "*-*-* 4:00:00";
      backupPrepareCommand = lib.strings.concatStringsSep " && " config.backups.preScripts;
      backupCleanupCommand = lib.strings.concatStringsSep " && " config.backups.postScripts;
    };

    services.restic.backups.mirror = defaultResticConf // {
      repository = "rclone:mirror:/${mirrorBase}";
      passwordFile = config.sops.secrets."restic/passwords/mirror".path;
    };

    systemd.services."restic-backups-mirror" = {
      wantedBy = [ remoteName ];
      after = [ remoteName ];
      serviceConfig.ExecStart = lib.mkForce [
        "${pkgs.restic}/bin/restic copy --from-repo rclone:remote:/${remoteBase} --from-password-file ${config.sops.secrets."restic/passwords/remote".path}"
        "${pkgs.restic}/bin/restic forget --prune ${lib.concatStringsSep " " pruneOpts}"
      ];
    };
  };
}
