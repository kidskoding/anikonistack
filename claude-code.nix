# Secrets are NOT in here. Export before launching claude:
#   GITHUB_MCP_TOKEN, PLAYWRIGHT_MCP_EXTENSION_TOKEN
# (Claude Code expands ${VAR} inside the generated MCP config at load time.)
inputs:
{ agents, config, lib, pkgs, ... }:
let
  spartan = "${inputs.spartan}/toolkit";

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
in
{
  programs.claude-code = {
    enable = true;
    # From the claude-code-nix flake, not nixpkgs. mkDefault so you can override:
    #   programs.claude-code.package = pkgs.claude-code;
    package = lib.mkDefault inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      model = "claude-fable-5-1[1m]";
      modelSettings.claude-fable-5-1.effortLevel = "high";
      effortLevel = "xhigh";
      theme = "dark";
      tui = "fullscreen";
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
      [ (builtins.readFile ./claude-md/00-eli5.md) ]
      ++ map (s: builtins.readFile "${spartan}/claude-md/${s}.md") spartanClaudeMd
    );

    # Personal plugins (Claude Code >= 2.1.157). Each exposes its own
    # skills/agents/commands/hooks. Replaces `/plugin install` + plugin cache.
    inherit (agents) plugins skills;

    # Spartan: commands/spartan.md + commands/spartan/<cmd>.md
    commands = { spartan = "${spartan}/commands/spartan.md"; }
      // lib.listToAttrs (map
        (n: lib.nameValuePair "spartan/${n}" "${spartan}/commands/spartan/${n}.md")
        spartanCommands);

    rules = fromList (n: "${spartan}/rules/${n}.md") spartanRules;
    agents = fromList (n: "${spartan}/agents/${n}.md") spartanAgents;

    hooks."statusline.sh" = agents.statusline;

    mcpServers = {
      composio = { type = "http"; url = "https://connect.composio.dev/mcp"; };
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp";
        headers.Authorization = "Bearer \${GITHUB_MCP_TOKEN}";
      };
      playwright = {
        type = "stdio";
        command = "npx";
        args = [ "@playwright/mcp@latest" "--extension" ];
        env.PLAYWRIGHT_MCP_EXTENSION_TOKEN = "\${PLAYWRIGHT_MCP_EXTENSION_TOKEN}";
      };
    };
  };

  # CLI tools the skills / MCP servers shell out to
  home.packages = with pkgs; [ gh nodejs starship ];
}
