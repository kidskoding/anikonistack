{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  s = anikonistackLib.for "github-copilot-cli";
in {
  config = lib.mkIf config.anikonistack.agents.github-copilot-cli.enable {
    programs.github-copilot-cli = {
      enable = true;
      enableMcpIntegration = true;

      inherit (s) skills;
      context = lib.concatStringsSep "\n" s.context;
    };
  };
}
