inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.anikonistack;

  catalog = import ./catalog {inherit inputs lib;};
  resolve = import ./lib/resolve.nix {inherit lib;};

  agentNames = ["claude-code" "codex" "opencode" "antigravity" "cursor"];

  bundleList = lib.types.listOf (lib.types.enum (lib.attrNames catalog));

  legacy = builtins.isAttrs cfg.bundles;

  enabled = lib.filter (a: cfg.agents.${a}.enable) agentNames;

  forAgent = agent:
    resolve.for {
      inherit catalog agent;
      inherit (cfg.agents.${agent}) bundles skip;
    };

  names = f: lib.unique (lib.concatMap f (lib.attrValues catalog));

  skips = lib.unique (cfg.skip ++ lib.concatMap (a: cfg.agents.${a}.skip) agentNames);

  notBundleNames = lib.subtractLists (names (b: lib.concatMap lib.attrNames [b.skills b.commands b.rules b.subagents b.scripts])) skips;
  unknownSkips =
    if notBundleNames == []
    then []
    else lib.subtractLists (names (b: lib.attrNames (resolve.pluginSkills b))) notBundleNames;
in {
  imports = [./agents];

  options.anikonistack = {
    bundles = lib.mkOption {
      type = lib.types.either bundleList (lib.types.attrsOf lib.types.anything);
      default = [];
      example = ["custom" "superpowers" "spartan-core"];
      description = "Bundles every enabled agent gets, unless the agent sets its own `bundles`.";
    };

    skip = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["resolving-merge-conflicts"];
      description = "Single skills, commands, rules or subagents to remove after merging bundles.";
    };

    agents = lib.genAttrs agentNames (name:
      lib.mkOption {
        default = {};
        description = "What anikonistack writes for ${name}.";
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "anikonistack for ${name}";
            bundles = lib.mkOption {
              type = bundleList;
              default =
                if legacy
                then []
                else cfg.bundles;
              defaultText = lib.literalExpression "config.anikonistack.bundles";
              description = "Bundles for ${name}; replaces `anikonistack.bundles`.";
            };
            skip = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = cfg.skip;
              defaultText = lib.literalExpression "config.anikonistack.skip";
              description = "Names to skip for ${name}; replaces `anikonistack.skip`.";
            };
          };
        };
      });
  };

  config = {
    assertions =
      [
        {
          assertion = !legacy;
          message = "anikonistack.bundles.<name>.enable was removed. Use anikonistack.bundles = [ … ] and anikonistack.agents.<name>.enable. See the README.";
        }
        {
          assertion = unknownSkips == [];
          message = "anikonistack: unknown skip name(s): ${lib.concatStringsSep ", " unknownSkips}";
        }
      ]
      ++ map (agent: let
        conflicts = (forAgent agent).conflicts;
      in {
        assertion = conflicts == [];
        message = "anikonistack (${agent}): the same name comes from more than one bundle:\n${lib.concatStringsSep "\n" conflicts}";
      })
      enabled;

    warnings = lib.concatMap (agent:
      map (s: "anikonistack (${agent}): skip ${s} has no effect, the plugin loads natively; leave out its bundle instead")
      (forAgent agent).nativeSkips)
    enabled;

    _module.args.anikonistackLib = {
      inherit inputs;
      for = forAgent;

      statusline = lib.getExe (pkgs.writeShellApplication {
        name = "statusline.sh";
        runtimeInputs = [pkgs.jq];
        text = builtins.readFile ./hooks/statusline.sh;
      });
    };
  };
}
