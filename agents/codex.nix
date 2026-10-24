{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  s = anikonistackLib.for "codex";

  configDir =
    if config.home.preferXdgDirectories
    then "${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/codex"
    else ".codex";
in {
  config = lib.mkIf config.anikonistack.agents.codex.enable {
    programs.codex = {
      enable = true;
      enableMcpIntegration = true;

      plugins = lib.attrValues s.plugins;
      inherit (s) skills;
    };

    home.file = anikonistackLib.linkSkills "${configDir}/skills" s.live;
  };
}
