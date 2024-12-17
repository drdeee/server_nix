{
  imports = [
    ./mirko.nix
  ];

  users.users.tasks = {
    isSystemUser = true;
    group = "tasks";
  };
  users.groups.tasks = {};
}
