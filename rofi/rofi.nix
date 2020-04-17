{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    font = "Monoid HalfTight Regular 16";
    borderWidth = 1;
    lines = 53;
    width = 25;
    padding = 1;
    rowHeight = 1;
    separator = "solid";
    scrollbar = false;
    location = "top-right";
    xoffset = 0; # 150; # right beside the xfce panel
    yoffset = 0;
    # use base16-horizon-dark as the theme
    extraConfig = ''
      ! TAKEN FROM https://gitlab.com/0xdec/base16-rofi/-/blob/master/themes/base16-horizon-dark.config

      ! Base16 Horizon Dark
      ! Author: Michaël Ball (http://github.com/michael-ball/)

      ! base00: #1c1e26
      ! base01: #232530
      ! base02: #2e303e
      ! base03: #6f6f70
      ! base04: #9da0a2
      ! base05: #cbced0
      ! base06: #dcdfe4
      ! base07: #e3e6ee
      ! base08: #e93c58
      ! base09: #e58d7d
      ! base0A: #efb993
      ! base0B: #efaf8e
      ! base0C: #24a8b4
      ! base0D: #df5273
      ! base0E: #b072d1
      ! base0F: #e4a382

      ! Enable the extended coloring options
      rofi.color-enabled: true

      ! Property Name     BG       Border   Separator
      rofi.color-window:  #232530, #232530, #1c1e26

      ! Property Name     BG       FG       BG-alt   Head-BG  Head-FG
      rofi.color-normal:  #232530, #cbced0, #232530, #232530, #e3e6ee
      rofi.color-active:  #232530, #df5273, #232530, #232530, #df5273
      rofi.color-urgent:  #232530, #e93c58, #232530, #232530, #e93c58

      ! Set the desired separator style
      rofi.separator-style: solid
    '';
  };
}
