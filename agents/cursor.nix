{
  agents,
  config,
  lib,
  pkgs,
  ...
}: let
  skills = agents.skills // agents.pluginSkills (lib.attrNames agents.plugins);

  servers = lib.mapAttrs (name: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      extraTransforms = [
        lib.hm.mcp.addType
        (lib.hm.mcp.wrapEnvFilesCommand {inherit pkgs name;})
      ];
    })
  config.programs.mcp.servers;

  envRefs = text:
    lib.concatMapStrings (part:
      if lib.isList part
      then "\${env:${lib.head part}}"
      else part)
    (builtins.split "\\$\\{([A-Za-z_][A-Za-z0-9_]*)}" text);
in {
  home.file =
    lib.mapAttrs' (name: path: lib.nameValuePair ".cursor/skills/${name}" {source = path;}) skills
    // lib.optionalAttrs (servers != {}) {
      ".cursor/mcp.json".text = envRefs (builtins.toJSON {mcpServers = servers;});
    };
}
