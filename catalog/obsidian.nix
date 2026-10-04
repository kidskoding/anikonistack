{
  inputs,
  lib,
  ...
}: {
  obsidian = {
    description = "kepano's Obsidian skills";
    skills = lib.genAttrs [
      "obsidian-markdown"
      "obsidian-bases"
      "obsidian-cli"
      "json-canvas"
      "defuddle"
    ] (n: "${inputs.obsidian-skills}/skills/${n}");
  };
}
