# one agent's content from a bundle list:
# { plugins = { <bundle> = <path>; }; skills; commands; rules; subagents; context = [ <text> ]; conflicts = [ <string> ]; }
{lib}: let
  skillDirs = import ./skill-dirs.nix {inherit lib;};

  # the skills/ of a plugin, for agents that cannot load it natively
  pluginSkills = b:
    if b.plugin != null && builtins.pathExists "${b.plugin}/skills"
    then skillDirs "${b.plugin}/skills"
    else {};
in {
  inherit pluginSkills;

  for = {
    catalog,
    agent,
    bundles,
    skip,
  }: let
    selected = map (x: x.key) (lib.genericClosure {
      startSet = map (key: {inherit key;}) bundles;
      operator = item: map (key: {inherit key;}) catalog.${item.key}.depends;
    });

    native = b: b.native ? ${agent};

    kinds = {
      skills = b:
        b.skills
        // lib.optionalAttrs (!native b) (pluginSkills b);
      commands = b: b.commands;
      rules = b: b.rules;
      subagents = b: b.subagents;
      context = b: b.context;
    };

    entries = kind:
      map (n: {
        bundle = n;
        attrs = kinds.${kind} catalog.${n};
      })
      selected;

    merged = kind: lib.foldl' (acc: e: acc // e.attrs) {} (entries kind);

    # the same name from two bundles only clashes when it points at different files
    conflicts = kind: let
      owners = lib.zipAttrs (map (e:
        lib.mapAttrs (_: value: {
          inherit (e) bundle;
          value = toString value;
        })
        e.attrs) (entries kind));
    in
      lib.concatLists (lib.mapAttrsToList (name: os:
        lib.optional (lib.length (lib.unique (map (o: o.value) os)) > 1)
        "${kind} ${name}: ${lib.concatStringsSep ", " (map (o: o.bundle) os)}")
      owners);

    drop = kind: removeAttrs (merged kind) skip;
  in {
    plugins = lib.listToAttrs (lib.concatMap (n:
      lib.optional (native catalog.${n}) (lib.nameValuePair n catalog.${n}.native.${agent}))
    selected);
    skills = drop "skills";
    commands = drop "commands";
    rules = drop "rules";
    subagents = drop "subagents";
    context = lib.attrValues (merged "context");
    conflicts = lib.concatMap conflicts (lib.attrNames kinds);
  };
}
