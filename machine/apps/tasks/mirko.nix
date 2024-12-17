{pkgs, fetchYarnDeps, ...}:
let mirkoPackage = pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "mirko-bot";
  version = "1.0.0";

  src = builtins.fetchGit {
    name = "mirko-bot";
    url = "https://codeberg.org/nicht_eli/mirko.git";
    ref = "main";
    rev = "93e2c344eb169f8277d2b891e2c761c1e9058c32";
  };

  yarnOfflineCache = pkgs.fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-y8w/jydnJvilCAnQyak5mBe6buu1BJ5ZwLvMh2aPNzU=";
  };

  nativeBuildInputs = [
    pkgs.yarnConfigHook
    pkgs.yarnInstallHook
    pkgs.nodejs
  ];
});
in {
  systemd.timers.mirko-bot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Thu,Sat *-*-*06:00:00";
      Persistent = true;
      Unit = "mirko-bot.service";
    };
  };

  systemd.services.mirko-bot = {
    script = "echo ${mirkoPackage}";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
