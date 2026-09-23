{
  programs.mcp = {
    enable = true;
    servers = {
      composio.url = "https://connect.composio.dev/mcp";
      github = {
        url = "https://api.githubcopilot.com/mcp";
        headers.Authorization = "Bearer \${GITHUB_MCP_TOKEN}";
      };
      playwright = {
        command = "npx";
        args = ["@playwright/mcp@latest" "--extension"];
        env.PLAYWRIGHT_MCP_EXTENSION_TOKEN = "\${PLAYWRIGHT_MCP_EXTENSION_TOKEN}";
      };
    };
  };

  programs.claude-code.enableMcpIntegration = true;
  programs.codex.enableMcpIntegration = true;
  programs.opencode.enableMcpIntegration = true;
  programs.antigravity-cli.enableMcpIntegration = true;
}
