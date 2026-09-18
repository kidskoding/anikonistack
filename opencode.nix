inputs:
{ agents, ... }:
{
  programs.opencode = {
    enable = true;

    # these two register their own skills, so they are left out of `skills` below
    settings.plugin = [
      "${agents.plugins.ponytail}/.opencode/plugins/ponytail.mjs"
      "${agents.plugins.superpowers}/.opencode/plugins/superpowers.js"
    ];

    skills = agents.skills
      // agents.pluginSkills [ "caveman" "firecrawl" "frontend-design" "understand-anything" "last30days" ];
  };
}
