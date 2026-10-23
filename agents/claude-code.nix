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
          base = "dark-ansi";
          overrides = {
            userMessageBackground = "#282828";
            userMessageBackgroundHover = "#3c3836";
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
            diffAdded = "#3d4220";
            diffAddedDimmed = "#32361a";
            diffAddedWord = "#5b6b1f";
            diffRemoved = "#4a2523";
            diffRemovedDimmed = "#3c1f1e";
            diffRemovedWord = "#7c2b27";
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
