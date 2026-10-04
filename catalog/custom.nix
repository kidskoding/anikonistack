{
  lib,
  skillDirs,
  ...
}: {
  custom = {
    description = "this repo's own skills and CLAUDE.md sections";
    skills = skillDirs ../skills;
    context = lib.mapAttrs' (f: _: lib.nameValuePair "00-custom/${f}" (builtins.readFile (../claude-md + "/${f}"))) (builtins.readDir ../claude-md);
  };
}
