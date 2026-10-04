{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  s = anikonistackLib.for "opencode";
in {
  config = lib.mkIf config.anikonistack.agents.opencode.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;

      settings.plugin = lib.mkIf (s.plugins != {}) (lib.attrValues s.plugins);
      inherit (s) skills;
    };
  };
}
