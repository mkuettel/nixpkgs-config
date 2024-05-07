{ pkgs, ... }:

{
  home.packages = [
    pkgs.alacritty
  ];
  xdg.configFile."alacritty/alacritty.toml".text = ''
    ${builtins.readFile ./alacritty.toml}
    ${builtins.readFile ./base16-horizon-dark-256.toml}
  '';
}
