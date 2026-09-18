inputs:
{ lib, pkgs, ... }:
let
  skillDirs = dir:
    lib.filterAttrs (name: _: builtins.pathExists "${dir}/${name}/SKILL.md")
      (lib.mapAttrs (name: _: "${dir}/${name}") (builtins.readDir dir));

  plugins = import ./plugins.nix inputs;
in
{
  imports = [
    ./mcp.nix
    ./agents
  ];

  _module.args.agents = {
    inherit inputs skillDirs plugins;

    skills = import ./skills.nix { inherit inputs lib skillDirs; };

    pluginSkills = names:
      lib.foldl' (acc: n: acc // skillDirs "${plugins.${n}}/skills") { } names;

    statusline = lib.getExe (pkgs.writeShellApplication {
      name = "statusline.sh";
      runtimeInputs = [ pkgs.jq ];
      text = builtins.readFile ./hooks/statusline.sh;
    });
  };
}
