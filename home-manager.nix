# home-manager module: every coding agent (claude-code, codex, opencode,
# antigravity) fed from the same skills and plugins.
#
# Usage in your home-manager flake:
#   inputs.anikonistack.url = "github:kidskoding/anikonistack";
#   imports = [ inputs.anikonistack.homeManagerModules.default ];
inputs:
{ lib, pkgs, ... }:
let
  spartan = "${inputs.spartan}/toolkit";
  mp = inputs.mattpocock-skills;

  # every <dir>/<name>/SKILL.md -> { name = "<dir>/<name>"; }
  skillDirs = dir:
    lib.filterAttrs (name: _: builtins.pathExists "${dir}/${name}/SKILL.md")
      (lib.mapAttrs (name: _: "${dir}/${name}") (builtins.readDir dir));

  # name -> path attrset from a list
  fromList = f: names: lib.listToAttrs (map (n: lib.nameValuePair n (f n)) names);

  # Spartan packs in use: core database shared-backend backend-micronaut
  # frontend-react ux-design infrastructure product ops research.
  spartanSkills = [
    "database-patterns" "database-table-creator" "api-endpoint-creator"
    "backend-api-design" "kotlin-best-practices" "testing-strategies"
    "security-checklist" "browser-qa" "js-security-audit" "design-intelligence"
    "design-workflow" "terraform-service-scaffold" "terraform-module-creator"
    "terraform-review" "terraform-security-audit" "terraform-best-practices"
    "web-to-prd" "ops-investigate-alert" "ops-oncall-log" "brainstorm"
    "idea-validation" "market-research" "competitive-teardown" "deep-research"
    "investor-materials" "investor-outreach" "article-writing" "content-engine"
    "startup-pipeline"
  ];

  # Plugin sources in Claude Code plugin layout (.claude-plugin/plugin.json).
  plugins = {
    superpowers = inputs.superpowers;
    firecrawl = inputs.firecrawl-plugin;
    frontend-design = "${inputs.claude-plugins-official}/plugins/frontend-design";
    caveman = inputs.caveman;
    ponytail = inputs.ponytail;
    duet = "${inputs.claude-duet}/plugins/duet";
    understand-anything = "${inputs.understand-anything}/understand-anything-plugin";
    last30days = inputs.last30days;
  };
in
{
  imports = [
    (import ./claude-code.nix inputs)
    (import ./codex.nix inputs)
    (import ./opencode.nix inputs)
    (import ./antigravity.nix inputs)
  ];

  _module.args.agents = {
    inherit skillDirs plugins;

    # skills/ of the named plugins, merged. For agents without a plugin
    # mechanism, or for plugins that lack that agent's manifest.
    pluginSkills = names:
      lib.foldl' (acc: n: acc // skillDirs "${plugins.${n}}/skills") { } names;

    # hooks/statusline.sh with jq on PATH; setup.sh (non-nix) uses the file directly.
    statusline = lib.getExe (pkgs.writeShellApplication {
      name = "statusline.sh";
      runtimeInputs = [ pkgs.jq ];
      text = builtins.readFile ./hooks/statusline.sh;
    });

    # Skills. firecrawl-* and last30days standalone skills are omitted: the
    # plugins above already ship them (and names must be unique).
    skills = skillDirs ./skills
      // fromList (n: "${spartan}/skills/${n}") spartanSkills
      // {
        # mattpocock/skills (paths from ~/.agents/.skill-lock.json, Sept 2026)
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
        # others
        find-skills = "${inputs.vercel-skills}/skills/find-skills";
        presenterm = "${inputs.lanej-dotfiles}/claude/skills/presenterm";
        tui-designer = "${inputs.ckorhonen-skills}/skills/tui-designer";
        graphify = "${inputs.graphify}/graphify/skill.md";
      };
  };
}
