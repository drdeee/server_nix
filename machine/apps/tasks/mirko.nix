{pkgs, ...}:
let
  mirkoSrc = builtins.fetchGit {
    name = "mirko-bot";
    url = "https://codeberg.org/nicht_eli/mirko.git";
    ref = "main";
    rev = "93e2c344eb169f8277d2b891e2c761c1e9058c32";
  };
in {
  environment.systemPackages = with pkgs; [
    nodejs_22
    yarn
  ];

  systemd.timers.mirko-bot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Thu,Sat *-*-*06:00:00";
      Persistent = true;
      Unit = "mirko-bot.service";
    };
  };

  systemd.services.mirko-bot = {
    serviceConfig = {
      User = "tasks";

      WorkingDirectory = mirkoSrc;

      ExecStartPre = "${pkgs.yarn}/bin/yarn install --frozen-lockfile";
      ExecStart = "${pkgs.yarn}/bin/yarn node ${mirkoSrc}/index.js";
    };
  };
}
