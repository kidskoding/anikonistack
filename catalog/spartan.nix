# one bundle per spartan pack (toolkit/packs/*.yaml), named spartan-<pack>
{
  inputs,
  lib,
  ...
}: let
  toolkit = "${inputs.spartan}/toolkit";
  read = import ../lib/pack.nix {inherit lib;};

  packs =
    lib.filterAttrs (_: p: p."coming-soon" or "false" != "true")
    (lib.mapAttrs' (f: _: let
      p = read "${toolkit}/packs/${f}";
    in
      lib.nameValuePair p.name p) (builtins.readDir "${toolkit}/packs"));

  byName = key: path: names: lib.listToAttrs (map (n: lib.nameValuePair (key n) (path n)) names);

  sections = byName (s: "50-spartan/${s}") (s: builtins.readFile "${toolkit}/claude-md/${s}");

  bundle = p: {
    description = p.description or "";
    depends = map (d: "spartan-${d}") (p.depends or []);
    skills = lib.genAttrs (p.skills or []) (n: "${toolkit}/skills/${n}");
    commands = byName (n: "spartan/${n}") (n: "${toolkit}/commands/spartan/${n}.md") (p.commands or []);
    rules = byName (lib.removeSuffix ".md") (r: "${toolkit}/rules/${r}") (p.rules or []);
    subagents = byName (lib.removeSuffix ".md") (a: "${toolkit}/agents/${a}") (p.agents or []);
    context = sections (p."claude-sections" or []);
  };

  bundles = lib.mapAttrs' (n: p: lib.nameValuePair "spartan-${n}" (bundle p)) packs;
in
  # spartan's installer always adds the router command and the header/core/footer sections
  lib.recursiveUpdate bundles {
    spartan-core = {
      commands.spartan = "${toolkit}/commands/spartan.md";
      context = sections ["00-header.md" "01-core.md" "90-footer.md"];
    };
  }
