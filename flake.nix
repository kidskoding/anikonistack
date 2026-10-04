{
  description = "a declarative and reproducible setup for coding agents!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # skill repos
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    lanej-dotfiles = {
      url = "github:lanej/dotfiles";
      flake = false;
    };
    ckorhonen-skills = {
      url = "github:ckorhonen/claude-skills";
      flake = false;
    };
    graphify = {
      url = "github:Graphify-Labs/graphify";
      flake = false;
    };
    typst-claude-skill = {
      url = "github:ChanMeng666/typst-claude-skill";
      flake = false;
    };
    obsidian-skills = {
      url = "github:kepano/obsidian-skills";
      flake = false;
    };

    # spartan AI toolkit
    spartan = {
      url = "github:c0x12c/ai-toolkit/v1.27.0";
      flake = false;
    };

    # plugins
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    firecrawl-plugin = {
      url = "github:firecrawl/firecrawl-claude-plugin";
      flake = false;
    };
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };
    caveman = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
    claude-duet = {
      url = "github:bokuhe/claude-duet";
      flake = false;
    };
    understand-anything = {
      url = "github:Egonex-AI/Understand-Anything";
      flake = false;
    };
    last30days = {
      url = "github:mvanhorn/last30days-skill";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    inherit (nixpkgs) lib;
    resolve = import ./lib/resolve.nix {inherit lib;};
  in {
    homeManagerModules.default = import ./module.nix inputs;

    checks.x86_64-linux.catalog = let
      catalog = import ./catalog {inherit inputs lib;};

      paths = b:
        lib.concatMap lib.attrValues [b.skills b.commands b.rules b.subagents b.scripts b.native (resolve.pluginSkills b)]
        ++ lib.optional (b.plugin != null) b.plugin;

      missing = lib.filter (p: !builtins.pathExists p) (lib.concatMap paths (lib.attrValues catalog));
    in
      if missing != []
      then throw "anikonistack: catalog points at missing paths:\n${lib.concatStringsSep "\n" missing}"
      else builtins.deepSeq (lib.mapAttrs (_: b: b.context) catalog) (pkgs.runCommand "anikonistack-catalog" {} "touch $out");
  };
}
