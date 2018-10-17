{ pkgs, ... }:

let
  config = import ./user-config.nix;
  stdenv = pkgs.stdenv;
  fetchgit = pkgs.fetchgit;
  faience-ng-icon-theme = stdenv.mkDerivation rec {
    name = "${pname}-${version}";
    pname = "faience-ng-icon-theme";
    version = "v${releasedate}";
    releasedate = "20180126";
    src =  pkgs.fetchurl {
      url = "https://github.com/faience/${pname}/releases/download/${version}/${pname}-${releasedate}.tar.gz";
      sha256 = "0szpzclsanfjqqaza45am4qfykfprxz4fs5q8hw159xflk91fqv4";
    };
    sourceRoot = ".";
    postUnpack = ''
      mkdir theme
      mv Faience* theme/
    '';
    installPhase = ''
      mkdir -p $out/share/icons
      find theme -mindepth 1 -maxdepth 1 -type d -iname 'Faience-ng*' | while IFS= read dir
      do
        cp -R "$dir" $out/share/icons
        # ${pkgs.gtk2}/bin/gtk-update-icon-cache "$out/share/icons/$dir" 
      done
    '';
  };

  griffin-ghost-icon-theme= stdenv.mkDerivation rec {
    name = "${pname}-${version}";
    pname = "griffin-ghost-icon-theme";
    version = "v${releasedate}";
    releasedate = "20180126";
    src =  pkgs.fetchFromGitHub {
      owner = "Shenron007";
      repo = "Griffin-Icons";
      rev = "5cc20750a79dc9897e67f08ae5d1b6a26ac6e322";
      sha256 = "0ayg1vzlad6zjvaizkanc6vjyznv4af0yd0lpyi7h1zzw17alsbx";
    };
    installPhase = ''
      mkdir -p $out/share/icons/Griffin-Ghost
      cp -R ./* $out/share/icons/Griffin-Ghost
      # ${pkgs.gtk2}/bin/gtk-update-icon-cache "$out/share/icons/$dir"
    '';
  };
in {
  programs.home-manager.enable = true;
  programs.home-manager.path = if config.homemanager.development
      then "${config.getDirectory "code"}/home-manager"
      else config.homemanager.repo "http";

  home.extraOutputsToInstall = [ "doc" "info" "devdoc" ];
  home.packages = [
    /* basic graphical programs */
    pkgs.feh
    (pkgs.keepass.override { xdotool = pkgs.xdotool; })
    pkgs.meld
    pkgs.qutebrowser

    /* heavier graphical programs */
    pkgs.dropbox
    pkgs.clementine
    pkgs.firefox
    pkgs.thunderbird

    /* theming stuff */
    faience-ng-icon-theme
    griffin-ghost-icon-theme

    /* shell environment programs */
    # pkgs.tmux /* already installed by the nixos module */
    pkgs.xsel # required by tmux for copy paste into X clipboard

    /* zsh, direnv is already included */
    /* there is also still a vim in the nixos configuration :/ share it with root??? */
    pkgs.nix-zsh-completions
    (pkgs.vim_configurable.override {
      pythonSupport = true; # needed for YouCompleteMe Plugin
      python = pkgs.python3; # needed for YouCompleteMe Plugin
      cscopeSupport = true; # gutenberg plugin uses cscope
    })
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

    /* system management utilities */
    pkgs.iotop
    pkgs.htop
    pkgs.lsof
    pkgs.ltrace

    /* programming utilities */
    pkgs.gdb
    pkgs.gcc
  ];

  programs.rofi = {
    enable = true;
    borderWidth = 1;
    lines = 50;
    width = 30;
    padding = 1;
    rowHeight = 1;
    separator = "solid";
    scrollbar = false;
    location = "top-right";
    xoffset = 0; # 150; # right beside the xfce panel
    yoffset = 0;
    colors = let
      red = "argb:90e01010";
      white = "#a0a0a0";
    in {
      window = {
        background = "argb:e0101010";
        border = red;
        separator = red;
      };

      rows = {
        normal = {
          foreground = white;
          background = "argb:00000000";
          backgroundAlt = "argb:90101010";
          highlight = {
            background = red;
            foreground = white;
          };
        };
      };
    };
  };

  programs.git = {
    enable = true;
    userName = config.name;
    userEmail = config.git.email;
    aliases = {
      "s" = "status";
      "a" = "add";
      "c" = "commit";
      "b" = "branch";
      "d" = "difftool";
      "co" = "checkout";
      "gd" = "diff";
      "gp" = "push";
      "gl" = "pull";
      "prune" = "fetch --prune";
      "undo" = "reset --soft HEAD^";
      "forward" = "merge --ff-only";
    };
    ignores = [ "*~"  ".*.sw?" ".env" ];
    extraConfig = {
      merge = {
        conflictStyle = "diff3";
      };

      push = {
        default = "simple";
      };

      transfer = {
        fsckobjects = true;
      };

      diff = {
        tool = "vimdiff";
      };
      difftool = {
        prompt = false;
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    defaultOptions = [ "--height" "40%" "--border" ];
    fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
    fileWidgetOptions = [ "--preview" "'file {}; head {}'" ];
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    changeDirWidgetOptions = [ "--preview" "'tree -C {} | head -200'" ];
    historyWidgetOptions = [ "--sort" "--exact" ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    shellAliases = {
      "vi" = "vim";
      "ll" = "ls -lAtr";
      "gs" = "git status";
      "ga" = "git add";
      "gc" = "git commit";
      "gb" = "git branch";
      "gco" = "git checkout";
      "gd" = "git diff";
      "gp" = "git push";
      "gl" = "git pull";
      # make alias expansion work with the following commands as prefix
      "xargs" = "xargs ";
      "sudo" = "sudo ";
      "home-config" = "vim ~/.config/nixpkgs/home.nix";
      "system-config" = "sudo vim /etc/nixos/configuration.nix";
      };
      history = {
        ignoreDups = true;
        share = true;
        save = 100000;
      };

      oh-my-zsh= {
        enable = true;
        plugins = [ "git" "sudo" "dircycle" "composer" ];
        /* ugly hack: oh my zsh only wants a relative path, so lets go bback to the system root */
        theme = "../../../../../../../../../../../${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k";
      };

      sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
        FZF_TMUX = "1";
        FZF_TMUX_HEIGHT = "30%";
        # for times the escape needed, because \ is not escaped! when pasting
        # into the bash file
        FZF_COMPLETION_TRIGGER = "\\\\";
      };
      initExtra = ''
        # disable standard terminal function CTRL-Q and CTRL-S
        # to stop output and resume
        stty -ixon

        # use the vi keymap
        setopt vi

        if [ -e "$HOME/.zprofile" ]; then
            source "$HOME/.zprofile"
        fi

        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time status root_indicator)
        POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(dir vcs)
        POWERLEVEL9K_STATUS_VERBOSE=true

        # case sensitive completion, etc.
        CASE_SENSITIVE=true
        # auto-command correction
        ENABLE_CORRECTION=true
        # don't show if files are dirty in a git repo
        # as it takes a long time
        DISABLE_UNTRACKED_FILES_DIRTY=true

        # make sure prompt gets printed on a new line
        setopt PROMPT_SP
        setopt PROMPT_CR
        export PROMPT_EOL_MARK=%B%S%#%s%b

        f() {
          local searchterm="''${1:-""}"
          shift
          local out="$(rg -n "$searchterm" "$@" | fzf | cut -d: -f1-2)"
          local file="''${out%:*}"
          if [ -n "$file" ]; then
            "$EDITOR" "$file" +"$(printf "%s\n" "$out" | cut -d: -f2)"
          fi
          return $?
        }
        zle -N fzf-search-files
        bindkey '^F' fzf-search-files

        # shift-tab : go backward in menu (invert of tab)
        bindkey '^[[Z' reverse-menu-complete

        # make sure the FZF keybindings work
        bindkey '^N' fzf-completion
        bindkey '^P' fzf-file-widget
        bindkey '\ec' fzf-cd-widget
        bindkey '^R' fzf-history-widget

        # make most keybindings also work in vim normal mode
        bindkey -M vicmd '^N' fzf-completion
        bindkey -M vicmd '^P' fzf-file-widget
        bindkey -M vicmd '\ec' fzf-cd-widget
        bindkey -M vicmd '^R' fzf-history-widget

        # common emacs keybindings for insert mode
        bindkey -M viins '^A' beginning-of-line
        bindkey -M viins '^E' end-of-line
        bindkey -M viins '^F' forward-char
        bindkey -M viins '^B' backward-char
        bindkey -M viins '^W' kill-word
        bindkey -M viins '^K' kill-line
        bindkey -M viins '^T' transpose-chars
        bindkey -M viins '^[f' forward-word
        bindkey -M viins '^[b' backward-word
        bindkey '^[[1;5C' forward-word # arrow-key right
        bindkey '^[[1;5D' backward-word # arrow-key left

        # in some terminals the delete character doesn't
        # work properly, so make sure it's bound
        bindkey    "^[[3~"          delete-char
        bindkey    "^[3;5~"         delete-char

        # start tmux automatically
        if command tmux -V 2>&1 >/dev/null; then
          # This Environment variable is checked in order
          # to avoid nesting. Because when tmux starts a new
          # shell in it, it will try to launch tmux again!
          if [ -z "$TMUX" ]; then
            tmux
          fi
        fi
    '';
  };

  programs.gnome-terminal = {
     enable = false;
     profile."Default" = {
       default = true;
       font = "Source Code Pro For Powerline";
       scrollbackLines = 1000;
       visibleName = "GTerm";
       showScrollbar = false;
     };
     showMenubar = false;
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
      set -g default-terminal "screen-256color"

      # split panes using | and -
      unbind '%'
      unbind '"'
      bind | split-window -h
      bind - split-window -v

      # reload config file
      bind r source-file ~/.tmux.conf \; \
           display-message "reloaded config"

      # mouse integration (not that it's needed  much... but it's nice)
      set -g mouse on
      # set -g mouse-utf8 off

      # have tmux count the windows/panes from 1, not from 0, better keymapping
      set -g base-index 1
      set -g pane-base-index 1


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
    '';
  };

  home.file.".vimrc" = let
    languages = {
      "nix" = {
        indent = { size = 2; useTabs = false; cIndent = true; };
        makeCommands = [
          { filePattern = "**/.config/nixpkgs,*.nix"; makeprg = "home-manager\\ switch"; }
          { filePattern = "**/nixos,*.nix"; makeprg = "nixos-rebuild\\ switch"; }
          { filePattern = "*"; makeprg = "nix-repl"; }
        ];
        fileSearchPath = [ "/etc/nixos" "~/.config/nixpkgs" ];
      };
      "python" = {
        indent = { useTabs = true; };
      };
    };

    getOrDefault = key: attrset: defaultValue:
      if builtins.hasAttr key attrset
        then builtins.getAttr key attrset
        else defaultValue;

    # general function which can generate
    # vim config for an option for all languages
    generateAllVimConfigLanguageOptions = option: vimConfigFunc:
      let generateLanguageOptions = lang: languageOptions:
        if builtins.hasAttr option languageOptions
          then vimConfigFunc lang (builtins.getAttr option languageOptions)
          else ""; # just generate an empty string if no option is set
      in builtins.concatStringsSep "\n" (stdenv.lib.mapAttrsToList generateLanguageOptions languages);

    indentVimConfig = let
        vimConfigFunc = lang: indentOption: let
          indent = toString (getOrDefault "size" indentOption 4); # default tab size
          tabsOption = getOrDefault "useTabs" indentOption false; # don't use tabs per default
          cIndent = if getOrDefault "cIndent" indentOption false # use smartindent as default
              then "cindent"
              else "smartindent";
        in ''
          " autocmd FileType ${lang} * set expandtab tabstop=${indent} softtabstop=${indent} shiftwidth=${indent} ${cIndent}
          ${if tabsOption then "\"autocmd FileType ${lang} * set noexpandtab" else ""
          }'';
      in generateAllVimConfigLanguageOptions "indent" vimConfigFunc;

    makeCommandsVimConfig = let
        vimConfigFunc = lang: makeCommandsOption: let
          makeCommand = makeCommandOption: let
            pattern = getOrDefault "filePattern" makeCommandOption "*";
          in ''" autocmd FileType ${lang} ${pattern} set makeprg=${makeCommandOption.makeprg}'';
        in builtins.concatStringsSep "\n" (map makeCommand makeCommandsOption);
      in generateAllVimConfigLanguageOptions "makeCommands" vimConfigFunc;

    fileSearchPathVimConfig = let
        vimConfigFunc = lang: fileSearchPathOption:
          let path = builtins.concatStringsSep "," fileSearchPathOption;
          in ''"autocmd FileType ${lang} * set path+=${path}'';
      in generateAllVimConfigLanguageOptions "fileSearchPath" vimConfigFunc;

  in {
    text = ''
      ${builtins.readFile ./vim/vimrc};

      " nix generated, language specific file search path configurations
      ${fileSearchPathVimConfig}

      " nix generated, language specific makeprg configurations
      ${makeCommandsVimConfig}

      " nix generated, language specific indentation configuration
      ${indentVimConfig}

      let g:livepreview_previewer = '${pkgs.evince}'
    '';
  };

  programs.command-not-found.enable = true;

  systemd.user.services = {
    dropbox = {
      Unit = {
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };

      Service = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
  systemd.user.startServices = true;
}
