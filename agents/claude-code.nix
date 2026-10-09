{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  cfg = config.anikonistack.agents.claude-code;
  s = anikonistackLib.for "claude-code";
in {
  options.anikonistack.agents.claude-code = lib.mkOption {
    type = lib.types.submodule {
      options.statusline = lib.mkEnableOption "the anikonistack statusline (hooks/statusline.sh)";
      options.gruvbox = lib.mkEnableOption "the gruvbox theme";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file =
      lib.mapAttrs' (rel: source:
        lib.nameValuePair "${config.programs.claude-code.configDir}/scripts/${rel}" {inherit source;})
      s.scripts
      // anikonistackLib.linkSkills "${config.programs.claude-code.configDir}/skills" s.live
      // lib.optionalAttrs cfg.gruvbox {
        "${config.programs.claude-code.configDir}/themes/gruvbox.json".source = anikonistackLib.gruvbox;
      };

    programs.claude-code = lib.mkMerge [
      {
        enable = true;
        enableMcpIntegration = true;

        inherit (s) skills commands rules;
        plugins = lib.attrValues s.plugins;
        agents = s.subagents;
        context = lib.concatStringsSep "\n" s.context;
      }
      (lib.mkIf cfg.gruvbox {
        settings.theme = "custom:gruvbox";
      })
      (lib.mkIf cfg.statusline {
        hooks."statusline.sh" = anikonistackLib.statusline;
        settings.statusLine = {
          type = "command";
          command = "bash \"${config.programs.claude-code.configDir}/hooks/statusline.sh\"";
        };
      })
    ];
  };
}
