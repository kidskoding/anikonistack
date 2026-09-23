{agents, ...}: {
  programs.antigravity-cli = {
    enable = true;

    skills =
      agents.skills
      // agents.pluginSkills [
        "caveman"
        "ponytail"
        "superpowers"
        "firecrawl"
        "frontend-design"
        "understand-anything"
        "last30days"
      ];
  };
}
