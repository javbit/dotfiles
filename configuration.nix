{
  inputs,
  config,
  lib,
  ...
}:

{
  networking.computerName = "Jav’s MacBook Air";
  networking.hostName = "Javs-MacBook-Air";
  users.users = {
    # Normal account.
    jav = {
      description = "Javed Mohamed";
      home = "/Users/jav";
    };
    # Admin account.
    javadmin = {
      description = "Javed Mohamed (Admin)";
      home = "/Users/javadmin";
    };
  };
  system.primaryUser = config.users.users.javadmin.name;
  home-manager.backupFileExtension = "bak";
  home-manager.users = {
    jav = { config, osConfig, pkgs, ... }: {
      imports = [
        ./modules/home/services/emacs.nix
      ];
      config = {
        # TODO: Inherit the OS's nixpkgs.
        nixpkgs.overlays = [
          inputs.emacs-overlay.overlays.default
          (import ./packages/ghostty-themes/overlay.nix)
          (import ./packages/emacs/overlay.nix)
          (final: prev: {
            my-agda = final.agda.withPackages (p: [ p.standard-library ]);
          })
        ];
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "claude-code"
        ];
        home.packages = with pkgs; [
          awscli2
          eza
          yt-dlp

          my-agda               # Keep Emacs mode & package together.

          # AI coding agents.
          claude-code
          codex
        ];
        programs.zsh = {
          enable = true;
          autocd = true;
          autosuggestion.enable = true;
          envExtra = ''
            [[ -n "$EAT_SHELL_INTEGRATION" ]] && source "$EAT_SHELL_INTEGRATION"

            case "$TERM" in
              "xterm-ghostty")
                export TERMINFO="/Applications/Ghostty.app/Contents/Resources/terminfo"
                ;;
              "eat*")
                export TERMINFO=$(emacsclient -e 'eat-term-terminfo-directory' | tr -d \")
                ;;
            esac
          '';
        };
        programs.nushell = {
          enable = true;
          envFile.text =
            let
              systemPath = builtins.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ] osConfig.environment.systemPath;
              systemPath' = lib.splitString ":" systemPath;
              nupath = "[ ${builtins.concatStringsSep ", " systemPath'} ]";
            in ''
              $env.PATH = ${nupath}
              $env.config.buffer_editor = [ "emacsclient", "--alternate-editor=hx", "--create-frame" ]
              $env.config.show_banner = false
              $env.config = {
                hooks: {
                  pre_prompt: [{ ||
                    if (which direnv | is-empty) {
                      return
                    }

                    direnv export json | from json | default {} | load-env
                    if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
                      $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
                    }
                  }]
                }
              }
            '';
        };
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            character = {
              success_symbol = "[❯](bold green)";
              error_symbol = "[✘](bold red)";
            };
            nix_shell = {
              symbol = "❄️ ";
              heuristic = true;
            };
            aws.symbol = "☁️ ";
          };
        };
        programs.helix.enable = true;
        programs.git = {
          enable = true;
          userName = "Javed Mohamed";
          userEmail = "jav@deadbeef.moe";
          difftastic = {
            enable = true;
            enableAsDifftool = true;
          };
          ignores = [
            "*~"
            "*.swp"
            "result*"
            ".direnv"
          ];
        };
        programs.mergiraf.enable = true;
        programs.jujutsu = {
          enable = true;
          settings = {
            user = {
              name = "Javed Mohamed";
              email = "jav@deadbeef.moe";
            };
            ui.pager = ":builtin";
            ui.diff-formatter = [
              (lib.meta.getExe config.programs.git.difftastic.package)
              "--color=always"
              "$left"
              "$right"
            ];
          };
        };
        programs.ghostty = {
          enable = true;
          package = null; # App managed by homebrew.
          enableZshIntegration = true;
          settings = {
            config-file = "config.custom";
          };
        };
        xdg.configFile."ghostty/themes" = {
          enable = true;
          force = true;
          recursive = true;
          source = "${pkgs.ghostty-themes}/themes";
        };
        programs.emacs = {
          enable = true;
          package = pkgs.my-emacs;
          extraPackages = epkgs: with epkgs; [
            exec-path-from-shell
            envrc
            # Themes
            standard-themes
            doric-themes
            modus-themes
            ef-themes
            # Movement
            avy
            # AI
            gptel
            # Completion
            corfu
            vertico
            orderless
            marginalia
            # Utilities
            eat
            # Programming
            ## Lisp
            paredit
            paren-face
            ## Nix
            nix-ts-mode
            ## Agda
            agda2-mode
            ## Haskell
            haskell-mode
            ## OCaml
            tuareg
            ocaml-eglot
            ## Scheme
            geiser
            geiser-racket
            racket-mode
            # Treesitter
            treesit-grammars.with-all-grammars
            tree-sitter-langs
          ];
        };
        services.emacs' = {
          enable = true;
          defaultEditor = true;
          executable = "Applications/Emacs.app/Contents/MacOS/Emacs";
        };
        programs.aria2.enable = true;
        home.stateVersion = "25.05";
      };
    };
    javadmin = { ... }: {
      programs.zsh = {
        enable = true;
        autocd = true;
        autosuggestion.enable = true;
        envExtra = ''
          eval $(/opt/homebrew/bin/brew shellenv)
          export TERMINFO=/Applications/Ghostty.app/Contents/Resources/terminfo
        '';
      };
      home.stateVersion = "25.05";
    };
  };
  homebrew.enable = true;
  homebrew.casks = [
    "anki"
    "audacity"
    "font-new-york"
    "font-sf-mono"
    "font-sf-pro"
    "ghostty"
    "iina"
    "mullvad-browser"
    "notion"
    "obsidian"
    "orion"
    "pareto-security"
    "racket"
    "signal"
    "tailscale-app"
    "tor-browser"
    "utm"
  ];
  environment.systemPath = [
    "/opt/homebrew/bin"
  ];
  programs.direnv.enable = true;
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
