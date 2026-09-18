inputs:
{ agents, ... }:
{
  programs.opencode = {
    enable = true;

    # ponytail and superpowers ship OpenCode plugins that register their own
    # skills and commands, so their skills are not duplicated below.
    settings.plugin = [
      "${agents.plugins.ponytail}/.opencode/plugins/ponytail.mjs"
      "${agents.plugins.superpowers}/.opencode/plugins/superpowers.js"
    ];

    skills = agents.skills
      // agents.pluginSkills [ "caveman" "firecrawl" "frontend-design" "understand-anything" "last30days" ];
  };
}
