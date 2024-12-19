{pkgs, config, ...}:
let
  mirkoReminders = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "mirko-reminders";
    version = "1.0.0";

    src = builtins.fetchGit {
      name = "mirko-reminders";
      url = "https://codeberg.org/nicht_eli/mirko.git";
      ref = "main";
    };

    nativeBuildInputs = [
      pkgs.nodejs_23
      pkgs.yarnConfigHook
      pkgs.yarnInstallHook
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp -r index.js package.json $out/
      cp -r node_modules $out/node_modules
    '';

    yarnOfflineCache = pkgs.fetchYarnDeps {
      yarnLock = finalAttrs.src + "/yarn.lock";
      hash = "sha256-y8w/jydnJvilCAnQyak5mBe6buu1BJ5ZwLvMh2aPNzU=";
    };
  });
in {

  sops.secrets."tasks/mirko-reminders" = {
    owner = "tasks";
  };

  systemd.services.mirko-reminders = {
    serviceConfig = {
      User = "tasks";
      ExecStart = "${pkgs.nodejs}/bin/node ${mirkoReminders}/index.js";
      EnvironmentFile = [
        config.sops.secrets."tasks/mirko-reminders".path
      ];
      Type = "oneshot";
    };
    startAt = "Thu,Sat *-*-* 06:00:00";
  };
}
