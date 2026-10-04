{
  anikonistackLib,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (anikonistackLib.for "cursor") skills;

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
  config.home.file = lib.mkIf config.anikonistack.agents.cursor.enable (
    lib.mapAttrs' (name: path: lib.nameValuePair ".cursor/skills/${name}" {source = path;}) skills
    // lib.optionalAttrs (config.programs.mcp.enable && servers != {}) {
      ".cursor/mcp.json".text = envRefs (builtins.toJSON {mcpServers = servers;});
    }
  );
}
