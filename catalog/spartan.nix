# one bundle per spartan pack (toolkit/packs/*.yaml), named spartan-<pack>
{
  inputs,
  lib,
  ...
}: let
  toolkit = "${inputs.spartan}/toolkit";
  read = import ../lib/pack.nix {inherit lib;};

  # keys this catalog reads, plus keys it knowingly ignores; anything else is new upstream and must be looked at
  keys = ["name" "description" "category" "priority" "hidden" "coming-soon" "depends" "commands" "rules" "skills" "agents" "claude-sections" "scripts"];

  readPack = f: let
    p = read "${toolkit}/packs/${f}";
    unknown = lib.subtractLists keys (lib.attrNames p);
  in
    if unknown == []
    then p
    else throw "anikonistack: unknown key(s) ${lib.concatStringsSep ", " unknown} in ${toolkit}/packs/${f}";

  packs =
    lib.filterAttrs (_: p: p."coming-soon" or "false" != "true")
    (lib.mapAttrs' (f: _: let
      p = readPack f;
    in
      lib.nameValuePair p.name p) (lib.filterAttrs (f: _: lib.hasSuffix ".yaml" f) (builtins.readDir "${toolkit}/packs")));

  byName = key: path: names: lib.listToAttrs (map (n: lib.nameValuePair (key n) (path n)) names);

  sections = byName (s: "50-spartan/${s}") (s: builtins.readFile "${toolkit}/claude-md/${s}");

  bundle = p: {
    description = p.description or "";
    # spartan's own resolver always adds core to whatever packs are chosen
    depends = map (d: "spartan-${d}") (lib.unique (lib.optional (p.name != "core") "core" ++ p.depends or []));
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
