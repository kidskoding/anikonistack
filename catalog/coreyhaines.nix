{
  inputs,
  skillDirs,
  ...
}: {
  coreyhaines = {
    description = "Corey Haines' marketing and growth skills";
    skills = skillDirs "${inputs.marketingskills}/skills";
  };
}
