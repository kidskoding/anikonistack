{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  s = anikonistackLib.for "antigravity";
in {
  config = lib.mkIf config.anikonistack.agents.antigravity.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;

      inherit (s) skills;
    };

    home.file = anikonistackLib.linkSkills ".gemini/config/skills" s.live;
  };
}
