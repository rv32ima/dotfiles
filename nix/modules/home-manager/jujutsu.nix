{ pkgs, config, ... }: {
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    programs.jujutsu = {
      enable = true;
      settings = {
        aliases = {
          jj = [ ];
          check = [
            "util"
            "exec"
            "--"
            "bash"
            "-c"
            ''jj diff -r "''${1:-ancestors(@) ~ ancestors(trunk())}" --name-only --no-pager | xargs ${pkgs.prek}/bin/prek run --files''
          ];
          fetch = [
            "git"
            "fetch"
          ];
          pr = [
            "util"
            "exec"
            "jj-pr"
          ];
          rt = [
            "rebase"
            "-d"
            "trunk()"
          ];
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
          init = [
            "git"
            "init"
            "--colocate"
          ];
          track = [
            "bookmark"
            "track"
          ];
        };

        revset-aliases = {
          "why_immutable(r)" = "(r & immutable()) | roots(r:: & immutable_heads())";
          "T" = "trunk()";
        };

        fix.tools.terraform-fmt = {
          command = [
            "terraform"
            "fmt"
            "-"
          ];
          patterns = [ "glob:'**/*.tf'" ];
          enabled = true;
        };
        fix.tools.treefmt = {
          command = [
            "${pkgs.treefmt}/bin/treefmt"
            "--stdin"
          ];
          enabled = true;
          patterns = [ "glob:**/*" ];
        };
        fix.tools.keep-sorted = {
          command = [
            "${pkgs.keep-sorted}/bin/keep-sorted"
            "-"
          ];
          patterns = [ "glob:'**/*'" ];
          enabled = true;
        };
        ui = {
          merge-editor = "vimdiff";
        };
      };
    };
  };
}
