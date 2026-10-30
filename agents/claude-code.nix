{
  anikonistackLib,
  config,
  lib,
  ...
}: let
  cfg = config.anikonistack.agents.claude-code;
  s = anikonistackLib.for "claude-code";

  # home-manager wraps every plugin in a derivation of per-entry symlinks, so
  # manifest paths like ./hooks resolve outside the plugin root and Claude Code
  # rejects them. Plugins with their own manifest need no wrapper; link them whole.
  ownManifest = p: builtins.pathExists "${p}/.claude-plugin/plugin.json";
  plugins = lib.attrValues s.plugins;
  dirName = p: builtins.unsafeDiscardStringContext (lib.strings.sanitizeDerivationName (baseNameOf (toString p)));
  directPlugins = lib.listToAttrs (map (p:
    lib.nameValuePair "${config.programs.claude-code.configDir}/skills/${dirName p}" {source = p;})
  (lib.filter ownManifest plugins));
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
      // directPlugins
      // lib.optionalAttrs cfg.gruvbox {
        "${config.programs.claude-code.configDir}/themes/gruvbox.json".source = anikonistackLib.gruvbox;
      };

    programs.claude-code = lib.mkMerge [
      {
        enable = true;
        enableMcpIntegration = true;

        inherit (s) skills commands rules;
        plugins = lib.filter (p: !ownManifest p) plugins;
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
