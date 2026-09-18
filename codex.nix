inputs:
{ agents, ... }:
{
  programs.codex = {
    enable = true;

    # Plugins that ship a .codex-plugin manifest. Caveman keeps its codex
    # manifest under plugins/caveman rather than the repo root.
    plugins = [
      "${inputs.caveman}/plugins/caveman"
      agents.plugins.ponytail
      agents.plugins.superpowers
      agents.plugins.last30days
    ];

    # The rest have no codex manifest; expose their skills directly.
    skills = agents.skills
      // agents.pluginSkills [ "firecrawl" "frontend-design" "understand-anything" ];
  };
}
