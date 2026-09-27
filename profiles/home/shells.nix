{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config = {
    home.packages = with pkgs; [
      eza
    ];
    programs.zsh = {
      enable = true;
      autocd = true;
      autosuggestion.enable = true;
      envExtra = ''
        case "$TERM" in
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          "xterm-ghostty")
            export TERMINFO="/Applications/Ghostty.app/Contents/Resources/terminfo"
            ;;
        ''}
        esac
      '';
    };
    programs.fish.enable = true;
    programs.bash = {
      enable = true;
      # Trampoline: bash stays the login shell so anything non-interactive
      # (scp/rsync, `ssh host cmd`, provisioning) keeps a POSIX shell, but
      # top-level interactive sessions exec into fish. Guards: skip when the
      # parent is already fish (no loops), when running `bash -c` (execution
      # string), and in nested shells (SHLVL) so a deliberate `bash` from
      # fish still gives bash. home-manager places initExtra after its
      # interactive-shell check, so login `ssh host cmd` never reaches this.
      initExtra = ''
        if [[ $(ps -p $PPID -o comm=) != *fish* && -z "''${BASH_EXECUTION_STRING}" && "''${SHLVL}" == 1 ]]; then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${lib.getExe config.programs.fish.package} $LOGIN_OPTION
        fi
      '';
    };
    programs.nushell = {
      enable = true;
      envFile.text =
        let
          # nix-darwin exposes the system PATH as a single string; NixOS builds
          # it from profiles instead, so only seed $env.PATH where available.
          # On NixOS nushell inherits PATH from the login/systemd session.
          pathLine =
            lib.optionalString (osConfig.environment ? systemPath) (
              let
                systemPath =
                  builtins.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ]
                    osConfig.environment.systemPath;
                systemPath' = lib.splitString ":" systemPath;
                nupath = "[ ${builtins.concatStringsSep ", " systemPath'} ]";
              in
              "$env.PATH = ${nupath}\n"
            );
        in
        ''
          ${pathLine}$env.config.buffer_editor = [ "emacsclient", "--alternate-editor=hx", "--create-frame" ]
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
        env_var.ZMX_SESSION = {
          symbol = " ";
          format = "in [$symbol$env_value]($style) ";
          description = "zmx session name";
          style = "bold purple";
        };
      };
    };
  };
}
