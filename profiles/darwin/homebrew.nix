{ ... }:

{
  config = {
    homebrew.enable = true;
    # Casks install into the running user's ~/Applications, never /Applications.
    homebrew.caskArgs.appdir = "~/Applications";
    homebrew.casks = [
      # Apple fonts (SF Pro, SF Mono, New York) are not here: their casks
      # install a .pkg, which needs root. `just fonts` unpacks the same
      # packages into ~/Library/Fonts as jav.

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
      # kicad is absent: its cask hard-codes /Applications/KiCad and
      # /Library/Application Support, ignoring appdir, so brew asks for an
      # admin password. Install it from the kicad.org dmg into ~/Applications.
      "racket"
      "utm"

      # Networking
      # Tailscale is deliberately absent: the cask installs a .pkg (needs
      # root) and mas 6 re-executes itself via sudo to install App Store
      # apps, which the jav sudo rule refuses. Install it from the App
      # Store GUI as jav instead.
      "orion"

      # Terminal
      "ghostty"
    ];
  };
}
