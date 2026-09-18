{
  description = "anikonistack — declarative Claude Code setup (home-manager module)";

  inputs = {
    # claude-code binary (tracks upstream releases faster than nixpkgs)
    claude-code-nix.url = "github:sadjow/claude-code-nix";

  };

  outputs = { self, ... }@inputs: {
    homeManagerModules = rec {
      claude-code = import ./nix/claude-code.nix inputs;
      default = claude-code;
    };
  };
}
