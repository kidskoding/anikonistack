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
      // lib.optionalAttrs cfg.gruvbox {
        "${config.programs.claude-code.configDir}/themes/gruvbox.json".text = builtins.toJSON {
          name = "Gruvbox";
          base = "dark";
          overrides = {
            userMessageBackground = "#3c3836";
            userMessageBackgroundHover = "#504945";
            bashMessageBackgroundColor = "#282828";
            memoryBackgroundColor = "#282828";
            selectionBg = "#504945";
            composerSidebarBackground = "#282828";
            text = "#ebdbb2";
            inactive = "#a89984";
            subtle = "#665c54";
            claude = "#fe8019";
            promptBorder = "#504945";
            success = "#b8bb26";
            error = "#fb4934";
            warning = "#fabd2f";
            diffAdded = "#4f5520";
            diffAddedDimmed = "#3a3e1c";
            diffAddedWord = "#79740e";
            diffRemoved = "#5c2a26";
            diffRemovedDimmed = "#3f2220";
            diffRemovedWord = "#9d0006";
          };
        };
      };

    programs.claude-code = lib.mkMerge [
      {
        enable = true;
        enableMcpIntegration = true;

        inherit (s) skills plugins commands rules;
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
