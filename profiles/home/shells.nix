{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config = {
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
    programs.fish.enable = true;
    programs.nushell = {
      enable = true;
      envFile.text =
        let
          systemPath =
            builtins.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ]
              osConfig.environment.systemPath;
          systemPath' = lib.splitString ":" systemPath;
          nupath = "[ ${builtins.concatStringsSep ", " systemPath'} ]";
        in
        ''
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
  };
}
