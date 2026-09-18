{
  description = "anikonistack — declarative Claude Code setup (home-manager module)";

  inputs = {
    # claude-code binary (tracks upstream releases faster than nixpkgs)
    claude-code-nix.url = "github:sadjow/claude-code-nix";

    # skill repos (were installed with `npx skills add ...`)
    mattpocock-skills = { url = "github:mattpocock/skills"; flake = false; };
    vercel-skills     = { url = "github:vercel-labs/skills"; flake = false; };
    lanej-dotfiles    = { url = "github:lanej/dotfiles"; flake = false; };

    # Spartan AI Toolkit (was installed with `npx @c0x12c/ai-toolkit`)
    spartan = { url = "github:c0x12c/ai-toolkit/v1.27.0"; flake = false; };

  };

  outputs = { self, ... }@inputs: {
    homeManagerModules = rec {
      claude-code = import ./nix/claude-code.nix inputs;
      default = claude-code;
    };
  };
}
