inputs:
{ agents, ... }:
{
  programs.opencode = {
    enable = true;

    settings.plugin = [
      "${agents.plugins.ponytail}/.opencode/plugins/ponytail.mjs"
      "${agents.plugins.superpowers}/.opencode/plugins/superpowers.js"
    ];

    skills = agents.skills
      // agents.pluginSkills [ "caveman" "firecrawl" "frontend-design" "understand-anything" "last30days" ];
  };
}
