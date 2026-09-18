# home-manager module: reproduces the full ~/.claude setup.
#
# Usage in your home-manager flake:
#   inputs.anikonistack.url = "github:kidskoding/anikonistack";
#   imports = [ inputs.anikonistack.homeManagerModules.default ];
#
inputs:
{ config, lib, pkgs, ... }:
let

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

  };

  # CLI tools the skills / MCP servers shell out to
  home.packages = with pkgs; [ gh nodejs starship ];
}
