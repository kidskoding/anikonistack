inputs:
{
  imports = [
    (import ./claude-code.nix inputs)
    (import ./codex.nix inputs)
    (import ./opencode.nix inputs)
    (import ./antigravity.nix inputs)
  ];
}
