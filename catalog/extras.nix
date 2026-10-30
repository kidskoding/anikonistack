{inputs, ...}: {
  extras = {
    description = "single skills from assorted repos";
    skills = {
      find-skills = "${inputs.vercel-skills}/skills/find-skills";
      presenterm = "${inputs.lanej-dotfiles}/ai/skills/presenterm";
      tui-designer = "${inputs.ckorhonen-skills}/skills/tui-designer";
      typst = "${inputs.typst-claude-skill}/skills/typst";
      graphify = "${inputs.graphify}/graphify/skill.md";
      design-taste-frontend = "${inputs.taste-skill}/skills/taste-skill";
      impeccable = "${inputs.impeccable}/.agents/skills/impeccable";
    };
  };
}
