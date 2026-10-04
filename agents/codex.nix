{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  s = anikonistackLib.for "codex";
in {
  config = lib.mkIf config.anikonistack.agents.codex.enable {
    programs.codex = {
      enable = true;
      enableMcpIntegration = true;

      plugins = lib.attrValues s.plugins;
      inherit (s) skills;
    };
  };
}
