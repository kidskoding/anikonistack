{inputs, ...}: {
  extras = {
    description = "single skills from assorted repos";
    skills = {
      find-skills = "${inputs.vercel-skills}/skills/find-skills";
      presenterm = "${inputs.lanej-dotfiles}/claude/skills/presenterm";
      tui-designer = "${inputs.ckorhonen-skills}/skills/tui-designer";
      typst = "${inputs.typst-claude-skill}/skills/typst";
      graphify = "${inputs.graphify}/graphify/skill.md";
    };
  };
}
