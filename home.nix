{ pkgs, ... }:

let
  config = import ./user-config.nix;
  stdenv = pkgs.stdenv;
  fetchgit = pkgs.fetchgit;
in {
  imports = [
    ./vim/neovim.nix
    ./git/git.nix
    ./zsh/zsh.nix
    ./fzf/fzf.nix
    ./services/dropbox.nix
    ./graphical/packages.nix
  ];
  programs.home-manager = {
    enable = true;
  } // (if config.homemanager.development then {
    path = "${config.getDirectory "code"}/home-manager";
  } else {});

  home.extraOutputsToInstall = [ "doc" "info" "devdoc" ];
  home.packages = [
    /* shell environment programs */
    pkgs.w3m
    /* pkgs.postgresql
       pkgs.pspg */
    # pkgs.tmux /* already installed by the nixos module */
    # pkgs.tmux-256colors-terminfo /* own terminfo for tmux */
    pkgs.xsel # required by tmux for copy paste into X clipboard

    /* zsh, direnv is already included */
    pkgs.universal-ctags
    pkgs.cscope
    pkgs.global

    /* shell utilities */
    pkgs.jq
    pkgs.ripgrep # used by the vim
    pkgs.tree
    pkgs.binutils
    pkgs.moreutils
    pkgs.coreutils
    pkgs.utillinux
    pkgs.fd
    pkgs.exa
    pkgs.netcat
    pkgs.unrar
    pkgs.man-pages

    /* system management utilities */
    pkgs.iotop
    pkgs.htop
    pkgs.lsof
    pkgs.ltrace


    /* programming utilities */
    pkgs.gdb
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake

    /* LaTeX */
    pkgs.evince # used by vim for tex preview as well
    pkgs.texlive.combined.scheme-full
  ];

  xdg.configFile."direnv/direnvrc".text = builtins.readFile ./direnv/direnvrc;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".tmux.conf" = {
  text = let
      loadPlugin = plugin: "run-shell ${plugin}/${plugin.name}\n";
      yankPlugin = pkgs.fetchFromGitHub {
          name = "yank.tmux";
          owner = "tmux-plugins";
          repo = "tmux-yank";
          rev = "c6a73eba6bfcde51edf57e1cc5fa12c4c7bd98d9";
          sha256 = "04cnr9chq6lwg6zlqvp0zrbn7mzn8w862r1g5b3hmp8ammdvp07x";
      };
    in ''
      # TMUX CONFIGURATION FILE


      # remap prefix from 'C-b' to 'C-a'
      unbind C-b
      unbind C-a
      set-option -g prefix C-q
      bind-key C-q send-prefix

      # lower the ncurses escape time, for faster mode switch
      # in vim etc.
      set-option -s escape-time 10

      # only set this here, don't set TERM in .profile, for
      # correct termcap in every environment
      # - uses custom tmux-256-colors to make italics work
      set -g default-terminal "screen-256color" # tmux-256color is a terminfo that doesn't really work
      # this should make strikethrough work
      set -as terminal-overrides ',*:sitm=\E[3m' # either this or the custom terminfo...
      # set -as terminal-overrides ',*:smxx=\E[9m' # this should enable strikethrough but doesn't
                                                   # even with the custom terminfo

      # Make sure CTRL-Shift and such works
      set-window-option -g xterm-keys on


      # split panes using | and - and keep the current directory
      # also put the new split at top or right of current pane, like in vim (-b)
      unbind '%'
      unbind '"'
      bind | split-window -b -h -c "#{pane_current_path}"
      bind - split-window -b -v -c "#{pane_current_path}"


      # reload config file
      bind r source-file ~/.tmux.conf \; \
           display-message "reloaded config"

      # mouse integration (not that it's needed  much... but it's nice)
      set -g mouse on
      # set -g mouse-utf8 off

      # have tmux count the windows/panes from 1, not from 0, better keymapping
      set -g base-index 1
      set -g pane-base-index 1

      # increase scrollback
      set-option -g history-limit 10000

      # vi style pane selection
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # vi style pane selection
      bind -r C-h resize-pane -L 11
      bind -r C-j resize-pane -D 7
      bind -r C-k resize-pane -U 7
      bind -r C-l resize-pane -R 11

      ## Yank into system clipboard

      bind-key -r Space copy-mode
      set -g @yank_selection 'clipboard' # use system clipboard 
      ${loadPlugin yankPlugin}
      # use v or space to start selecting
      bind-key -T copy-mode-vi v send-keys -X begin-selection # 
      # use y or enter to copy the selection
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xsel -i --clipboard"
      # use y to yank a line into the clipboard
      bind-key -T copy-mode-vi Y send-keys -X start-of-line \; send-keys -X start-of-line \; send-keys -X end-of-line \; send-keys -X copy-pipe-and-cancel "xsel -i --clipboard"
      # copy selection into clipboard when releasing mouse
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # set terminal window title
      set-option -g set-titles on
      set-option -g set-titles-string "#W:#{pane_current_command} - Alacritty #S"
      # set pane title
      set-option -g pane-border-format "#P: #{pane_current_command}"


      #### COLOUR THEME (Solarized dark)
      # default statusbar colors
      set-option -g status-bg black #base02
      set-option -g status-fg yellow #yellow
      set-option -g status-attr default

      # default window title colors
      set-window-option -g window-status-fg brightblue #base0
      set-window-option -g window-status-bg default
      #set-window-option -g window-status-attr dim

      # active window title colors
      set-window-option -g window-status-current-fg brightred #orange
      set-window-option -g window-status-current-bg default
      #set-window-option -g window-status-current-attr bright

      # pane border
      set-option -g pane-border-fg black #base02
      set-option -g pane-active-border-fg brightgreen #base01

      # message text
      set-option -g message-bg black #base02
      set-option -g message-fg brightred #orange

      # pane number display
      set-option -g display-panes-active-colour blue #blue
      set-option -g display-panes-colour brightred #orange

      # clock
      set-window-option -g clock-mode-colour green #green

      # bell
      set-window-option -g window-status-bell-style fg=black,bg=red #base02, red

      # direnv compability (e.g. fixes issues when having direnv loaded and starting tmux afterwards)
      set-option -g update-environment "DIRENV_DIFF DIRENV_DIR DIRENV_WATCHES"
      set-environment -gu DIRENV_DIFF
      set-environment -gu DIRENV_DIR
      set-environment -gu DIRENV_WATCHES
      set-environment -gu DIRENV_LAYOUT
    '';
  };

  home.file."bin/" = {
    executable = true;
    source = ./bin;
  };

  programs.command-not-found.enable = true;

  systemd.user.startServices = pkgs.stdenv.isLinux;
}
