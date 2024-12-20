{ pkgs, lib, ... }:
let
  pnpm = pkgs.pnpm_9;
  etherpad = pkgs.stdenv.mkDerivation {
    name = "etherpad";
    version = "2.2.6";

    src = builtins.fetchGit {
      name = "etherpad-lite";
      url = "https://github.com/ether/etherpad-lite";
      rev = "0c68ddce1e92711151e9ede7cf5a83b5741dc554";
      ref = "master";
    };

    nativeBuildInputs = [
      pkgs.nodejs_23
      pnpm
    ];

    installPhase = ''
      ${pnpm}/bin/pnpm i
      ${pnpm}/bin/pnpm run build:etherpad

      mkdir -p $out/bin
      cp -r * $out/
    '';
  };
in
{
  config = {
    systemd.services.etherpad = {
      serviceConfig = {
        User = "tasks";
        ExecStart = "${pnpm}/bin/pnpm run prod";
        WorkingDirectory = etherpad;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
