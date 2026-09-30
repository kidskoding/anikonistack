{
  agents,
  lib,
  ...
}: let
  # loaded as native codex plugins; every other enabled plugin gets its skills flattened in
  native = lib.filter (n: agents.plugins ? ${n}) ["caveman" "ponytail" "superpowers" "last30days"];
  path = {
    # caveman's .codex-plugin manifest lives under plugins/caveman, not the repo root
    caveman = "${agents.plugins.caveman}/plugins/caveman";
  };
in {
  programs.codex = {
    enable = true;

    plugins = map (n: path.${n} or agents.plugins.${n}) native;

    skills =
      agents.skills
      // agents.pluginSkills (lib.subtractLists native (lib.attrNames agents.plugins));
  };
}
