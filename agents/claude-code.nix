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
            inverseText = "#282828";
            inactive = "#a89984";
            inactiveShimmer = "#bdae93";
            subtle = "#665c54";
            background = "#8ec07c";
            claude = "#fe8019";
            claudeShimmer = "#fda856";
            claudeBlue_FOR_SYSTEM_SPINNER = "#83a598";
            claudeBlueShimmer_FOR_SYSTEM_SPINNER = "#adc0a8";
            clawd_body = "#fb4934";
            clawd_background = "#282828";
            autoAccept = "#d3869b";
            autoAcceptShimmer = "#e1abaa";
            skill = "#d3869b";
            bashBorder = "#d3869b";
            permission = "#83a598";
            permissionShimmer = "#adc0a8";
            planMode = "#8ec07c";
            ide = "#458588";
            promptBorder = "#665c54";
            promptBorderShimmer = "#928374";
            suggestion = "#83a598";
            remember = "#83a598";
            success = "#b8bb26";
            error = "#fb4934";
            warning = "#fabd2f";
            warningShimmer = "#facf64";
            merged = "#d3869b";
            professionalBlue = "#83a598";
            chromeYellow = "#fabd2f";
            rate_limit_fill = "#83a598";
            rate_limit_empty = "#504945";
            fastMode = "#fe8019";
            fastModeShimmer = "#fda856";
            effortUltra = "#d3869b";
            briefLabelYou = "#83a598";
            briefLabelClaude = "#fe8019";
            red_FOR_SUBAGENTS_ONLY = "#fb4934";
            blue_FOR_SUBAGENTS_ONLY = "#83a598";
            green_FOR_SUBAGENTS_ONLY = "#b8bb26";
            yellow_FOR_SUBAGENTS_ONLY = "#fabd2f";
            purple_FOR_SUBAGENTS_ONLY = "#d3869b";
            orange_FOR_SUBAGENTS_ONLY = "#fe8019";
            pink_FOR_SUBAGENTS_ONLY = "#b16286";
            cyan_FOR_SUBAGENTS_ONLY = "#8ec07c";
            rainbow_red = "#fb4934";
            rainbow_orange = "#fe8019";
            rainbow_yellow = "#fabd2f";
            rainbow_green = "#b8bb26";
            rainbow_blue = "#83a598";
            rainbow_indigo = "#458588";
            rainbow_violet = "#d3869b";
            rainbow_red_shimmer = "#fb8467";
            rainbow_orange_shimmer = "#fda856";
            rainbow_yellow_shimmer = "#facf64";
            rainbow_green_shimmer = "#cfce5e";
            rainbow_blue_shimmer = "#adc0a8";
            rainbow_indigo_shimmer = "#85ab9e";
            rainbow_violet_shimmer = "#e1abaa";
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
