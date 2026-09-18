{ agents, ... }:
{
  programs.codex = {
    enable = true;

    plugins = [
      # caveman's .codex-plugin manifest lives under plugins/caveman, not the repo root
      "${agents.inputs.caveman}/plugins/caveman"
      agents.plugins.ponytail
      agents.plugins.superpowers
      agents.plugins.last30days
    ];

    skills = agents.skills
      // agents.pluginSkills [ "firecrawl" "frontend-design" "understand-anything" ];
  };
}
