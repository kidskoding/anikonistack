{inputs, ...}: {
  superpowers = {
    description = "obra's superpowers workflow skills";
    plugin = inputs.superpowers;
    native = {
      codex = inputs.superpowers;
      opencode = "${inputs.superpowers}/.opencode/plugins/superpowers.js";
    };
  };

  firecrawl = {
    description = "Firecrawl web scraping and search";
    plugin = inputs.firecrawl-plugin;
  };

  frontend-design = {
    description = "Anthropic's frontend-design plugin";
    plugin = "${inputs.claude-plugins-official}/plugins/frontend-design";
  };

  caveman = {
    description = "terse caveman-style output";
    plugin = inputs.caveman;
    # the .codex-plugin manifest lives under plugins/caveman, not the repo root
    native.codex = "${inputs.caveman}/plugins/caveman";
  };

  ponytail = {
    description = "ponytail plugin";
    plugin = inputs.ponytail;
    native = {
      codex = inputs.ponytail;
      opencode = "${inputs.ponytail}/.opencode/plugins/ponytail.mjs";
    };
  };

  understand-anything = {
    description = "codebase knowledge graphs";
    plugin = "${inputs.understand-anything}/understand-anything-plugin";
  };

  last30days = {
    description = "research what happened in the last 30 days";
    plugin = inputs.last30days;
    native.codex = inputs.last30days;
  };

  duet = {
    description = "claude-duet commands (Claude Code only)";
    plugin = "${inputs.claude-duet}/plugins/duet";
  };
}
