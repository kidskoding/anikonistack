{agents, ...}: {
  programs.antigravity-cli = {
    enable = true;

    skills = agents.skills // agents.pluginSkills (builtins.attrNames agents.plugins);
  };
}
