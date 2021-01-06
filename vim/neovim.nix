{ pkgs, ...}:

let
  phpPackages = pkgs.php74Packages; # I can use at least php 7.4 everywhere now I think
in {
  programs.zsh = {
      sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };
  };

  home.packages = with pkgs; [
    neovim-remote # control nvim processes from terminal
    proselint # lint text data

    clang # ALE linter for C/C++ 
    shellcheck # linter for shell scripts
    shfmt # ale fixer for shell scripts
    pythonPackages.sqlparse # ALE lint sql code (postgresql)
    python37Packages.pylint # ALE lint python code # doesn't work because python enchant dependency has problems with python 2.7?
    python37Packages.python-language-server # coc-python
    ripgrep # Used in vim-ripgrep plugin to provide :Rg command
    plantuml # for building plantuml files
    vim-vint # Ale Linter lint vimscript/vimrc
    racket # scheme dialect in use

    nixpkgs-fmt # ale fixer (nixfmt exists as well)

    bibclean # fix format BibTex bibliography files
   # python-language-server

    ## rust programming
    # rls
    # rustc
    # cargo
    rustup # toolchain installer, conflicts with others..
  ] ++ (with phpPackages; [
    php # ALE linter for php files
    phpcs # ALE fixer for php files
    composer # PHP-Package manager (essential for development and for ale to have vendor/bin/<executable>)
  ]);

  xdg.configFile."nvim/coc-settings.json".text = ''
  {
    "suggest.enablePreview":  true,
    "diagnostic.displayByAle": true,
    "codeLens.enable": true,
    "languageserver": {
      "psalmls": {
        "command": "vendor/bin/psalm-language-server",
        "args": ["--find-dead-code", "--disable-on-change=100000", "--use-extended-diagnostic-codes", "--verbose"],
        "filetypes": ["php"],
        "rootPatterns": ["psalm.xml", "psalm.xml.dist"],
        "requireRootPattern": true,
        "trace.server": "verbose"
      }
    },
  }
  '';

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    withPython = false;
    withNodeJs = true;
    withRuby = false;
    extraPython3Packages = (ps: with ps; [
      pynvim
    ]);
    plugins = with pkgs.vimPlugins; [
      # the best of the junegunn plugins
      vim-easy-align
      fzfWrapper
      fzf-vim

      # tome good tpope plugins
      vim-vinegar # browse directory where file resides by pressing "-"
      vim-surround # add surround keybindings
      vim-eunuch # unix file management
      vim-markdown

      vim-nix # nix language support

      indentLine # show indentlines

      # Tmux Integration
      vim-tmux-focus-events

      # Git Integration
      vim-fugitive
      vim-rhubarb # Github Integration, e.g. :Gbrowse

      # Status bar
      vim-airline
      vim-airline-themes

      # LanguageClient-neovim
      coc-nvim
      coc-vimtex
      coc-python # achtung: benötigt :CocCommand python.setInterpreter pythonXX
      coc-css
      coc-html
      coc-java
      coc-yaml
      coc-json
      coc-neco
      coc-fzf
      coc-git
      coc-yank
      coc-rls # requires rustup package

      # install plugin to be able to install any base16 theme
      # but we just just horizon-dark
      base16-vim

      # asynchronous syntax checker and fixer
      ale

      # language specific stuff
      plantuml-syntax
      vimtex # LaTeX
      sved

      # Snippets
      UltiSnips
      coc-snippets
      vim-snippets
      neosnippet-snippets

      # Autocompletion
      # neocomplete  # currently doesn't work because this neovim apparently has no lua? Even though it seems to use luajit..
      deoplete-nvim
      neco-vim
      deoplete-dictionary
      deoplete-zsh
      deoplete-clang
      cpsm # fast fuzzy matching for completion
      tmux-complete-vim # complete in vim from tmux panes
      context_filetype-vim
      coc-pairs
      coc-neco
      # nvim-lsp isused as the language server Language Server
      # deoplete-lsp # nvim-lsp integration

      # (pkgs.fetchUrl {
      #   url = "https://github.com/thomasfaingnaert/vim-lsp-ultisnips/archive/494cd3c16b1d590e10c66d6cc10ace4dfe094085.zip";
      #   sha256 = "1pl3gwzr5691jbm5f2fmicgqjzr4pvq7bl1fry7jbldr6ab74san";
      # })
      #

      # display documentation
      echodoc

      # easier commenting blocks (CTRL-/ CTRL-/ toggles line or selectino)
      tcomment_vim

      # saving vim sessions
      vim-obsession
    ];
    extraConfig = import ./config.nix {
      inherit pkgs;
    };
    package = pkgs.neovim-unwrapped;
  };

  /** install the few vim-plug plugins in a non-reproducable way
   automatically upon 'home-manager switch' by running neovim
   in headless mode to run :PlugInstall
  */
  home.activation = {
    neovimPlugInstall = lib.hm.dag.entryAfter ["installPackages"] ''
      # plugin update rev 1
      # update the number above to force plugin updates, and if it works do it on all
      # machines to have a chance at getting the same setup. Or better yet create a nix derivation for them :)
      $DRY_RUN_CMD nvim -c ':PlugInstall' -c ':PlugDiff' -c ':PlugClean' -c ':q!' -c 'q!' --headless
    '';
  };

}
