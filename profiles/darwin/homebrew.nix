{ ... }:

{
  config = {
    homebrew.enable = true;
    homebrew.casks = [
      # Fonts
      "font-new-york"
      "font-sf-mono"
      "font-sf-pro"

      # Media
      "audacity"
      "iina"

      # Privacy
      "mullvad-browser"
      "signal"
      "tor-browser"

      # Productivity
      "anki"
      "notion"
      "obsidian"
      "zotero"

      # Security
      "pareto-security"

      # Development
      "kicad"
      "racket"
      "utm"

      # Networking
      "orion"
      "tailscale-app"

      # Terminal
      "ghostty"
    ];
  };
}
