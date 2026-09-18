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

  spartanClaudeMd = [
    "00-header" "01-core" "05-database" "11-backend-micronaut"
    "20-frontend-react" "25-ux-design" "30-infrastructure" "40-product"
    "50-ops" "60-research" "90-footer"
  ];

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

  };

  # CLI tools the skills / MCP servers shell out to
  home.packages = with pkgs; [ gh nodejs starship ];
}
