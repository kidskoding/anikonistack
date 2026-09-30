{
  agents,
  config,
  lib,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = lib.mkDefault agents.inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      model = "claude-opus-5-5[1m]";
      modelSettings.claude-opus-5-5.effortLevel = "high";
      effortLevel = "xhigh";
      theme = "dark";
      tui = "fullscreen";
      skipWorkflowUsageWarning = true;
      agentPushNotifEnabled = true;
      env.DISABLE_AUTOUPDATER = "1";
      permissions.allow = [
        "Bash(git commit*)"
        "Bash(git push*)"
        "Bash(git add*)"
        "Bash(git status*)"
        "Bash(git diff*)"
        "Bash(git log*)"
      ];
      statusLine = {
        type = "command";
        command = "bash \"${config.programs.claude-code.configDir}/hooks/statusline.sh\"";
      };
    };

    context = lib.concatStringsSep "\n" agents.claude.context;

    inherit (agents) skills;
    inherit (agents.claude) plugins commands rules agents;

    hooks."statusline.sh" = agents.statusline;
  };

  home.packages = with pkgs; [gh nodejs starship];
}
