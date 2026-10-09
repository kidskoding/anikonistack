{
  anikonistackLib,
  config,
  lib,
  options,
  ...
}: let
  s = anikonistackLib.for "codex";

  configDir =
    if config.home.preferXdgDirectories
    then "${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/codex"
    else ".codex";
in {
  config = lib.mkIf config.anikonistack.agents.codex.enable {
    programs.codex =
      {
        enable = true;
        enableMcpIntegration = true;

        inherit (s) skills;
      }
      # older home-manager releases have no programs.codex.plugins
      // lib.optionalAttrs (options.programs.codex ? plugins) {
        plugins = lib.attrValues s.plugins;
      };

    home.file = anikonistackLib.linkSkills "${configDir}/skills" s.live;
  };
}
