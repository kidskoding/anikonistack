{lib}: let
  skillDirs = import ./skill-dirs.nix {inherit lib;};

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
      scripts = b: b.scripts;
      context = b: b.context;
    };

    entries = kind:
      map (n: {
        bundle = n;
        attrs = removeAttrs (kinds.${kind} catalog.${n}) skip;
      })
      selected;

    merged = kind: lib.foldl' (acc: e: acc // e.attrs) {} (entries kind);

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

    nativeSkips = lib.concatMap (n: let
      b = catalog.${n};
    in
      lib.optionals (native b && skip != []) (map (s: "${s} (plugin bundle ${n})") (lib.intersectLists skip (lib.attrNames (pluginSkills b)))))
    selected;
  in {
    plugins = lib.listToAttrs (lib.concatMap (n:
      lib.optional (native catalog.${n}) (lib.nameValuePair n catalog.${n}.native.${agent}))
    selected);
    skills = merged "skills";
    commands = merged "commands";
    rules = merged "rules";
    subagents = merged "subagents";
    scripts = merged "scripts";
    context = lib.attrValues (merged "context");
    conflicts = lib.concatMap conflicts (lib.attrNames kinds);
    inherit nativeSkips;
  };
}
