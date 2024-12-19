{config, lib, pkgs, ...}:
let
  generateBackupConfig = backupName: backupLocations: {
    sops.secrets."restic/${backupName}-password" = {};

    services.restic.backups."${backupName}-local" = {
      initialize = true;
      paths = backupLocations;
      repository = "/var/lib/restic/${backupName}";
      passwordFile = config.sops.secrets."restic/${backupName}-password".path;
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 5"
      ];
      timerConfig.OnCalendar = "*-*-* 4:00:00";
    };
  };

  allBackups = lib.attrsets.mergeAttrsList (lib.attrsets.mapAttrsToList generateBackupConfig config.backups);

in {
  options = {
    backups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    };
  };
}
