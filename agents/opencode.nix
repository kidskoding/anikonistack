{
  agents,
  lib,
  ...
}: let
  # these register their own skills, so they are left out of `skills` below
  native = {
    ponytail = "${agents.plugins.ponytail}/.opencode/plugins/ponytail.mjs";
    superpowers = "${agents.plugins.superpowers}/.opencode/plugins/superpowers.js";
  };
  enabled = lib.filter (n: agents.plugins ? ${n}) ["ponytail" "superpowers"];
in {
  programs.opencode = {
    enable = true;

    settings.plugin = map (n: native.${n}) enabled;

    skills =
      agents.skills
      // agents.pluginSkills (lib.subtractLists enabled (lib.attrNames agents.plugins));
  };
}
