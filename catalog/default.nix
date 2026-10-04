# every bundle, all fields filled in: { <bundle> = { description; depends; skills; plugin; native; commands; rules; subagents; context; }; }
{
  inputs,
  lib,
}: let
  args = {
    inherit inputs lib;
    skillDirs = import ../lib/skill-dirs.nix {inherit lib;};
  };

  raw = lib.foldl' (acc: f: acc // import f args) {} [
    ./custom.nix
    ./mattpocock.nix
    ./obsidian.nix
    ./extras.nix
    ./plugins.nix
    ./spartan.nix
  ];

  # claude code loads every plugin natively
  fill = b:
    {
      description = "";
      depends = [];
      skills = {};
      plugin = null;
      commands = {};
      rules = {};
      subagents = {};
      context = {};
    }
    // b
    // {
      native = lib.optionalAttrs (b ? plugin) {claude-code = b.plugin;} // b.native or {};
    };
in
  lib.mapAttrs (_: fill) raw
