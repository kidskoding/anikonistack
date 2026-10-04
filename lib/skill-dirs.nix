{lib}: dir:
lib.filterAttrs (name: _: builtins.pathExists "${dir}/${name}/SKILL.md")
(lib.mapAttrs (name: _: "${dir}/${name}") (builtins.readDir dir))
