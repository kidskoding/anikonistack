{
  anikonistackLib,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.anikonistack.agents.antigravity.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;

      inherit (anikonistackLib.for "antigravity") skills;
    };
  };
}
