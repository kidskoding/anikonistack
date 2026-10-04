# reads the YAML subset spartan's packs/*.yaml use: `key: value`, `key: []`, and `key:` followed by `  - item` lines
{lib}: file: let
  unquote = s: let
    m = builtins.match ''"(.*)"'' s;
  in
    if m == null
    then s
    else lib.head m;

  lines = lib.filter (l: builtins.match "[[:space:]]*(#.*)?" l == null) (lib.splitString "\n" (builtins.readFile file));

  # flow lists, inline comments and trailing spaces are valid YAML this reader would misread
  checked = line: value:
    if (lib.hasPrefix "[" value && value != "[]") || lib.hasInfix " #" value || builtins.match ".*[[:space:]]" value != null
    then throw "anikonistack: unsupported YAML in ${file}: ${line}"
    else value;

  step = acc: line: let
    item = builtins.match "[[:space:]]+- (.*)" line;
    pair = builtins.match "([A-Za-z0-9_-]+):[[:space:]]*(.*)" line;
  in
    if item != null && acc.current != null
    then acc // {result = acc.result // {${acc.current} = acc.result.${acc.current} ++ [(unquote (checked line (lib.head item)))];};}
    else if pair == null
    then throw "anikonistack: unrecognised line in ${file}: ${line}"
    else let
      key = lib.elemAt pair 0;
      value = checked line (lib.elemAt pair 1);
    in
      if value == ""
      then {
        current = key;
        result = acc.result // {${key} = [];};
      }
      else {
        current = null;
        result =
          acc.result
          // {
            ${key} =
              if value == "[]"
              then []
              else unquote value;
          };
      };
in
  (lib.foldl' step {
      current = null;
      result = {};
    }
    lines).result
