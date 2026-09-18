inputs:
{ agents, ... }:
{
  programs.antigravity-cli = {
    enable = true;

    # No plugin mechanism in the home-manager module; skills only.
    skills = agents.skills
      // agents.pluginSkills [
        "caveman" "ponytail" "superpowers" "firecrawl" "frontend-design"
        "understand-anything" "last30days"
      ];
  };
}
