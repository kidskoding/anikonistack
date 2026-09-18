inputs:
{ agents, ... }:
{
  programs.codex = {
    enable = true;

    plugins = [
      "${inputs.caveman}/plugins/caveman"
      agents.plugins.ponytail
      agents.plugins.superpowers
      agents.plugins.last30days
    ];

    skills = agents.skills
      // agents.pluginSkills [ "firecrawl" "frontend-design" "understand-anything" ];
  };
}
