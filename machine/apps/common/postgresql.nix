let
  backupLocation = "/var/backup/postgresql";
in
{
  services.postgresql = {
    enable = true;
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = backupLocation;
    startAt = "*-*-* 3:30:00";
  };

  backups.paths = [
    backupLocation
  ];
}
