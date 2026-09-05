alias s := switch
alias r := rollback
alias b := build
alias u := upgrade
alias d := deploy
alias f := fonts

flake := "/Users/$USER/Sources/dotfiles"
host := "Javs-MacBook-Air"

switch:
    sudo darwin-rebuild switch --flake {{flake}}

rollback:
    sudo darwin-rebuild switch --rollback

build:
    nix build {{flake}}#darwinConfigurations.{{host}}.system --no-link --print-out-paths

deploy target:
    nixos-rebuild switch --build-host root@{{target}} --target-host root@{{target}} --flake {{flake}}#{{target}} --no-reexec --use-substitutes

update:
    nix flake update

upgrade:
    sudo determinate-nixd upgrade
    brew upgrade

gc:
    nix-collect-garbage --delete-older-than 14d
    sudo nix-collect-garbage --delete-older-than 14d
    sudo nix store optimise

# Unpack Apple's SF Pro, SF Mono and New York .pkg installers (which need root) into ~/Library/Fonts
fonts:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    mkdir -p ~/Library/Fonts
    for name in SF-Pro SF-Mono NY; do
        curl -fsSL -o "$tmp/$name.dmg" "https://devimages-cdn.apple.com/design/resources/download/$name.dmg"
        mnt=$(hdiutil attach -nobrowse -readonly -mountrandom "$tmp" "$tmp/$name.dmg" | awk '/\/Volumes|\/private/ {print $NF}' | tail -1)
        pkgutil --expand-full "$mnt"/*.pkg "$tmp/$name"
        hdiutil detach "$mnt" -quiet
        find "$tmp/$name" -type f \( -name '*.otf' -o -name '*.ttf' \) -exec cp -f {} ~/Library/Fonts/ \;
    done
    echo "installed: $(ls ~/Library/Fonts | grep -cE '^(SF-|NewYork)')" fonts
