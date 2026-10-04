{
  anikonistack,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.anikonistack.agents.antigravity.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;

      inherit (anikonistack.for "antigravity") skills;
    };
  };
}
