{inputs, ...}: let
  mp = inputs.mattpocock-skills;
in {
  mattpocock = {
    description = "Matt Pocock's engineering and productivity skills";
    skills = {
      ask-matt = "${mp}/skills/engineering/ask-matt";
      claude-handoff = "${mp}/skills/in-progress/claude-handoff";
      code-review = "${mp}/skills/engineering/code-review";
      codebase-design = "${mp}/skills/engineering/codebase-design";
      diagnosing-bugs = "${mp}/skills/engineering/diagnosing-bugs";
      domain-modeling = "${mp}/skills/engineering/domain-modeling";
      git-guardrails-claude-code = "${mp}/skills/misc/git-guardrails-claude-code";
      grill-me = "${mp}/skills/productivity/grill-me";
      grill-with-docs = "${mp}/skills/engineering/grill-with-docs";
      grilling = "${mp}/skills/productivity/grilling";
      handoff = "${mp}/skills/productivity/handoff";
      implement = "${mp}/skills/engineering/implement";
      improve-codebase-architecture = "${mp}/skills/engineering/improve-codebase-architecture";
      loop-me = "${mp}/skills/in-progress/loop-me";
      migrate-to-shoehorn = "${mp}/skills/misc/migrate-to-shoehorn";
      prototype = "${mp}/skills/engineering/prototype";
      research = "${mp}/skills/engineering/research";
      resolving-merge-conflicts = "${mp}/skills/engineering/resolving-merge-conflicts";
      scaffold-exercises = "${mp}/skills/misc/scaffold-exercises";
      setup-matt-pocock-skills = "${mp}/skills/engineering/setup-matt-pocock-skills";
      setup-pre-commit = "${mp}/skills/misc/setup-pre-commit";
      setup-ts-deep-modules = "${mp}/skills/in-progress/setup-ts-deep-modules";
      tdd = "${mp}/skills/engineering/tdd";
      teach = "${mp}/skills/productivity/teach";
      to-spec = "${mp}/skills/engineering/to-spec";
      to-tickets = "${mp}/skills/engineering/to-tickets";
      triage = "${mp}/skills/engineering/triage";
      wayfinder = "${mp}/skills/engineering/wayfinder";
      wizard = "${mp}/skills/engineering/wizard";
      writing-beats = "${mp}/skills/in-progress/writing-beats";
      writing-fragments = "${mp}/skills/in-progress/writing-fragments";
      writing-shape = "${mp}/skills/in-progress/writing-shape";
    };
  };
}
