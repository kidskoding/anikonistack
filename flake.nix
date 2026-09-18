{
  description = "anikonistack — declarative Claude Code setup (home-manager module)";

  inputs = {
    # claude-code binary (tracks upstream releases faster than nixpkgs)
    claude-code-nix.url = "github:sadjow/claude-code-nix";

    # skill repos (were installed with `npx skills add ...`)
    mattpocock-skills = { url = "github:mattpocock/skills"; flake = false; };
    vercel-skills     = { url = "github:vercel-labs/skills"; flake = false; };
    lanej-dotfiles    = { url = "github:lanej/dotfiles"; flake = false; };
    ckorhonen-skills  = { url = "github:ckorhonen/claude-skills"; flake = false; };
    graphify          = { url = "github:Graphify-Labs/graphify"; flake = false; };

    # Spartan AI Toolkit (was installed with `npx @c0x12c/ai-toolkit`)
    spartan = { url = "github:c0x12c/ai-toolkit/v1.27.0"; flake = false; };

    # plugins (were installed with `/plugin install ...`)
    superpowers             = { url = "github:obra/superpowers"; flake = false; };
    firecrawl-plugin        = { url = "github:firecrawl/firecrawl-claude-plugin"; flake = false; };
    claude-plugins-official = { url = "github:anthropics/claude-plugins-official"; flake = false; };
    caveman                 = { url = "github:JuliusBrussee/caveman"; flake = false; };
    ponytail                = { url = "github:DietrichGebert/ponytail"; flake = false; };
    claude-duet             = { url = "github:bokuhe/claude-duet"; flake = false; };
    understand-anything     = { url = "github:Egonex-AI/Understand-Anything"; flake = false; };
    last30days              = { url = "github:mvanhorn/last30days-skill"; flake = false; };
  };

  outputs = { self, ... }@inputs: {
    homeManagerModules.default = import ./home-manager.nix inputs;
  };
}
