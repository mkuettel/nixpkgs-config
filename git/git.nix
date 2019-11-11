{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    userName = config.name;
    userEmail = config.git.email;
    aliases = {
      "s" = "status";
      "a" = "add";
      "u" = "reset HEAD";
      "unstage" = "reset HEAD";
      "c" = "commit";
      "b" = "branch";
      "d" = "diff";
      "dc" = "diff --cached";
      "dt" = "difftool";
      "l" = "log";
      "co" = "checkout";
      "k" = "checkout";
      "p" = "push";
      "pl" = "pull";
      "f" = "fetch --prune";
      "undo-commit" = "reset --soft HEAD^";
      "fwd" = "forward";
      "forward" = "merge --ff-only";
    };
    ignores = [
      "*~" "*.bak*" # backup files
      ".*.sw?" "tags" # vim swap and tag files
      ".env"  ".direnv/" # directory environment configuration files
      "vendor/" "node_modules/" # package manager directories
      ".DS_Store" # get rid of the mac shit
      "*.log" # you probably never want to commit a log file
    ];
    extraConfig = {
      merge = {
        conflictStyle = "diff3";
      };

      push = {
        default = "simple";
      };

      # see https://stackoverflow.com/questions/41029654/ignore-fsck-zero-padded-file-mode-errors-in-git-clone
      transfer = {
        fsckobjects = true;
      };

      "receive.fsck".zeroPaddedFilemode = "warn";
      "fetch.fsck".zeroPaddedFilemode = "warn";
      "receive.fsck".badTimezone = "warn";
      "fetch.fsck".badTimezone = "warn";

      diff = {
        tool = "nvim -d";
      };
      difftool = {
        prompt = false;
      };
    };
  };
}