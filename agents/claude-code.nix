{
  anikonistack,
  config,
  lib,
  ...
}: let
  cfg = config.anikonistack.agents.claude-code;
  s = anikonistack.for "claude-code";
in {
  options.anikonistack.agents.claude-code = lib.mkOption {
    type = lib.types.submodule {
      options.statusline = lib.mkEnableOption "the anikonistack statusline (hooks/statusline.sh)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = lib.mkMerge [
      {
        enable = true;
        enableMcpIntegration = true;

        inherit (s) skills plugins commands rules;
        agents = s.subagents;
        context = lib.concatStringsSep "\n" s.context;
      }
      (lib.mkIf cfg.statusline {
        hooks."statusline.sh" = anikonistack.statusline;
        settings.statusLine = {
          type = "command";
          command = "bash \"${config.programs.claude-code.configDir}/hooks/statusline.sh\"";
        };
      })
    ];
  };
}
