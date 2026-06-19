{ pkgs, config, ... }: {
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    programs.jujutsu = {
      enable = true;
      settings = {
        aliases = {
          check = [
            "util"
            "exec"
            "--"
            "bash"
            "-c"
            ''jj diff -r "''${1:-ancestors(@) ~ ancestors(trunk())}" --name-only --no-pager | xargs ${pkgs.prek}/bin/prek run --files''
          ];
        };
        fix.tools.treefmt = {
          command = [
            "${pkgs.treefmt}/bin/treefmt"
            "--stdin"
          ];
          enabled = true;
          patterns = [ "glob:**/*" ];
        };
        ui = {
          merge-editor = "vimdiff";
        };
      };
    };
  };
}
