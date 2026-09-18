# home-manager module: reproduces the full ~/.claude setup.
#
# Usage in your home-manager flake:
#   inputs.anikonistack.url = "github:kidskoding/anikonistack";
#   imports = [ inputs.anikonistack.homeManagerModules.default ];
#
inputs:
{ config, lib, pkgs, ... }:
let
  spartan = "${inputs.spartan}/toolkit";
  mp = inputs.mattpocock-skills;

  # Spartan packs in use: core database shared-backend backend-micronaut
  # frontend-react ux-design infrastructure product ops research.
  # Lists below are the union of those packs' manifests (toolkit/packs/*.yaml).
  spartanCommands = [
    "spec" "plan" "build" "debug" "onboard" "daily" "context-save" "magic-doc"
    "memory-consolidate" "update" "pr-ready" "ship-pr" "codex" "commit-message"
    "commit-message-with-codex" "ship-pr-codex" "init-project" "init-rules"
    "scan-rules" "lint-rules" "careful" "freeze" "unfreeze" "guard" "sessions"
    "contribute" "gate-review" "epic" "brownfield" "migration" "kotlin-service"
    "review" "testcontainer" "next-app" "next-feature" "fe-review"
    "figma-to-code" "e2e" "qa" "js-security" "ux" "tf-scaffold" "tf-module"
    "tf-review" "tf-plan" "tf-deploy" "tf-import" "tf-drift" "tf-cost"
    "tf-security" "think" "validate" "teardown" "interview" "lean-canvas"
    "brainstorm" "web-to-prd" "deploy" "env-setup" "ops-investigate-alert"
    "ops-oncall-log" "startup" "kickoff" "deep-dive" "fundraise" "research"
    "pitch" "outreach" "content" "write"
  ];
  spartanRules = [
    "core/NAMING_CONVENTIONS" "core/TIMEZONE" "core/SKILL_AUTHORING"
    "database/SCHEMA" "database/ORM_AND_REPO" "database/TRANSACTIONS"
    "shared-backend/ARCHITECTURE"
    "backend-micronaut/KOTLIN" "backend-micronaut/CONTROLLERS"
    "backend-micronaut/SERVICES_AND_BEANS" "backend-micronaut/API_DESIGN"
    "backend-micronaut/RETROFIT_PLACEMENT" "backend-micronaut/BATCH_PROCESSING"
    "frontend-react/FRONTEND" "ux-design/DESIGN_PROCESS"
    "infrastructure/STRUCTURE" "infrastructure/MODULES"
    "infrastructure/STATE_AND_BACKEND" "infrastructure/NAMING"
    "infrastructure/SECURITY" "infrastructure/VARIABLES" "infrastructure/PROVIDERS"
  ];
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
  spartanAgents = [
    "phase-reviewer" "micronaut-backend-expert" "solution-architect-cto"
    "design-critic" "ai-designer" "infrastructure-expert" "sre-architect"
    "idea-killer" "research-planner"
  ];
  spartanClaudeMd = [
    "00-header" "01-core" "05-database" "11-backend-micronaut"
    "20-frontend-react" "25-ux-design" "30-infrastructure" "40-product"
    "50-ops" "60-research" "90-footer"
  ];

  # name -> path attrset from a list
  fromList = f: names: lib.listToAttrs (map (n: lib.nameValuePair n (f n)) names);

  # own skills: every directory under ../skills
  ownSkills = lib.mapAttrs (n: _: ../skills + "/${n}")
    (lib.filterAttrs (_: t: t == "directory") (builtins.readDir ../skills));
in
{
  programs.claude-code = {
    enable = true;
    # From the claude-code-nix flake, not nixpkgs. mkDefault so you can override:
    #   programs.claude-code.package = pkgs.claude-code;
    package = lib.mkDefault inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      model = "claude-fable-5-1[1m]";
      effortLevel = "high";
      theme = "dark";
      tui = "default";
      skipWorkflowUsageWarning = true;
      agentPushNotifEnabled = true;
      env.DISABLE_AUTOUPDATER = "1";
      permissions.allow = [
        "Bash(git commit*)" "Bash(git push*)" "Bash(git add*)"
        "Bash(git status*)" "Bash(git diff*)" "Bash(git log*)"
      ];
      statusLine = {
        type = "command";
        command = "bash \"${config.programs.claude-code.configDir}/hooks/statusline.sh\"";
      };
      # caveman + ponytail hooks come from the plugins themselves (plugin.json).
      # The discord-status hook from the old Mac (npx claude-code-discord-status)
      # is intentionally dropped; re-add under `hooks` here if wanted.
    };

    # CLAUDE.md = own eli5 header + Spartan sections for the packs above
    context = lib.concatStringsSep "\n" (
      [ (builtins.readFile ../claude-md/00-eli5.md) ]
      ++ map (s: builtins.readFile "${spartan}/claude-md/${s}.md") spartanClaudeMd
    );

    # Personal plugins (Claude Code >= 2.1.157). Each exposes its own
    # skills/agents/commands/hooks. Replaces `/plugin install` + plugin cache.
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

    # Skills. firecrawl-* and last30days standalone skills are omitted: the
    # plugins above already ship them (and names must be unique).
    skills = ownSkills
      // fromList (n: "${spartan}/skills/${n}") spartanSkills
      // {
        # mattpocock/skills (paths from ~/.agents/.skill-lock.json, Sept 2026)
        ask-matt = "${mp}/skills/engineering/ask-matt";
        batch-grill-me = "${mp}/skills/in-progress/batch-grill-me";
        claude-handoff = "${mp}/skills/in-progress/claude-handoff";
        code-review = "${mp}/skills/engineering/code-review";
        codebase-design = "${mp}/skills/engineering/codebase-design";
        design-an-interface = "${mp}/skills/deprecated/design-an-interface";
        diagnosing-bugs = "${mp}/skills/engineering/diagnosing-bugs";
        domain-modeling = "${mp}/skills/engineering/domain-modeling";
        edit-article = "${mp}/skills/personal/edit-article";
        git-guardrails-claude-code = "${mp}/skills/misc/git-guardrails-claude-code";
        grill-me = "${mp}/skills/productivity/grill-me";
        grill-with-docs = "${mp}/skills/engineering/grill-with-docs";
        grilling = "${mp}/skills/productivity/grilling";
        handoff = "${mp}/skills/productivity/handoff";
        implement = "${mp}/skills/engineering/implement";
        improve-codebase-architecture = "${mp}/skills/engineering/improve-codebase-architecture";
        loop-me = "${mp}/skills/in-progress/loop-me";
        migrate-to-shoehorn = "${mp}/skills/misc/migrate-to-shoehorn";
        obsidian-vault = "${mp}/skills/personal/obsidian-vault";
        prototype = "${mp}/skills/engineering/prototype";
        qa = "${mp}/skills/deprecated/qa";
        request-refactor-plan = "${mp}/skills/deprecated/request-refactor-plan";
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
        ubiquitous-language = "${mp}/skills/deprecated/ubiquitous-language";
        wayfinder = "${mp}/skills/engineering/wayfinder";
        wizard = "${mp}/skills/in-progress/wizard";
        writing-beats = "${mp}/skills/in-progress/writing-beats";
        writing-fragments = "${mp}/skills/in-progress/writing-fragments";
        writing-great-skills = "${mp}/skills/productivity/writing-great-skills";
        writing-shape = "${mp}/skills/in-progress/writing-shape";
        # others
        find-skills = "${inputs.vercel-skills}/skills/find-skills";
        presenterm = "${inputs.lanej-dotfiles}/claude/skills/presenterm";
      };

    # Spartan: commands/spartan.md + commands/spartan/<cmd>.md
    commands = { spartan = "${spartan}/commands/spartan.md"; }
      // lib.listToAttrs (map
        (n: lib.nameValuePair "spartan/${n}" "${spartan}/commands/spartan/${n}.md")
        spartanCommands);

    rules = fromList (n: "${spartan}/rules/${n}.md") spartanRules;
    agents = fromList (n: "${spartan}/agents/${n}.md") spartanAgents;

    hooks."statusline.sh" = ../hooks/statusline.sh;

  };

  # CLI tools the skills / MCP servers shell out to
  home.packages = with pkgs; [ gh nodejs starship ];
}
