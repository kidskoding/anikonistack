inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  skillDirs = dir:
    lib.filterAttrs (name: _: builtins.pathExists "${dir}/${name}/SKILL.md")
    (lib.mapAttrs (name: _: "${dir}/${name}") (builtins.readDir dir));

  fromList = f: names: lib.listToAttrs (map (n: lib.nameValuePair n (f n)) names);

  all = import ./skills.nix {inherit inputs lib skillDirs fromList;};

  # a bundle is { skills; plugins; claude = { plugins; commands; rules; agents; context; }; }, every field optional
  bundles =
    lib.mapAttrs (_: skills: {inherit skills;}) all.skills
    // lib.mapAttrs (n: p: {plugins.${n} = p;}) all.plugins
    // lib.mapAttrs (n: p: {claude.plugins.${n} = p;}) all.claudePlugins
    // {inherit (all) spartan;};

  enabled = lib.attrValues (lib.filterAttrs (name: _: config.anikonistack.bundles.${name}.enable) bundles);

  merge = f: lib.foldl' (acc: b: acc // f b) {} enabled;

  duplicates = f: let
    names = lib.concatMap (b: lib.attrNames (f b)) enabled;
  in
    lib.unique (lib.filter (n: lib.count (x: x == n) names > 1) names);

  plugins = merge (b: b.plugins or {});
in {
  imports = [
    ./mcp.nix
    ./agents
  ];

  options.anikonistack.bundles =
    lib.mapAttrs (name: _: {
      enable = lib.mkEnableOption "the ${name} bundle" // {default = true;};
    })
    bundles;

  config = {
    assertions =
      lib.mapAttrsToList (kind: f: let
        dups = duplicates f;
      in {
        assertion = dups == [];
        message = "anikonistack: ${kind} defined by more than one enabled bundle: ${lib.concatStringsSep ", " dups}";
      }) {
        skills = b: b.skills or {};
        plugins = b: (b.plugins or {}) // (b.claude.plugins or {});
        commands = b: b.claude.commands or {};
        rules = b: b.claude.rules or {};
        agents = b: b.claude.agents or {};
      };

    _module.args.agents = {
      inherit inputs skillDirs plugins;

      skills = merge (b: b.skills or {});

      # the `skills/` of those plugins, merged; names of disabled plugins are skipped
      pluginSkills = names:
        lib.foldl' (acc: n: acc // skillDirs "${plugins.${n}}/skills") {}
        (lib.filter (n: plugins ? ${n}) names);

      claude = {
        plugins = plugins // merge (b: b.claude.plugins or {});
        commands = merge (b: b.claude.commands or {});
        rules = merge (b: b.claude.rules or {});
        agents = merge (b: b.claude.agents or {});
        # own claude-md/*.md first (always on, file name order), then enabled bundles'
        context =
          lib.mapAttrsToList (f: _: builtins.readFile (./claude-md + "/${f}")) (builtins.readDir ./claude-md)
          ++ lib.concatMap (b: b.claude.context or []) enabled;
      };

      statusline = lib.getExe (pkgs.writeShellApplication {
        name = "statusline.sh";
        runtimeInputs = [pkgs.jq];
        text = builtins.readFile ./hooks/statusline.sh;
      });
    };
  };
}
