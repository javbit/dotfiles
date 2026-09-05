# Dotfiles managed by Nix

## Getting Started

Run `nix develop` to start a development shell with `just`.
Then run `just --list` to see what commands you can run.

## Privilege model (macOS)

Two accounts, split so that the account running untrusted code is
never the one that can change the system.

| | `jav` (daily, standard) | `javadmin` (admin) |
|---|---|---|
| Owns | `/opt/homebrew`, `~/Applications`, everything you use | `~/Sources/dotfiles` (this repo) |
| Runs | browser, casks, dev tooling, `brew` | almost nothing |
| sudo | Touch ID, only the `SYSMGMT` commands in `configuration.nix` | full, via `%admin` |

- **Switching:** as `jav`, from `/Users/javadmin/Sources/dotfiles`, run
  `just switch`. The sudoers rule matches that exact path. Because `jav`
  cannot write the repo, the rule applies a configuration `jav` cannot
  change, so it is not a root-code-execution primitive.
- **Editing:** `su -l javadmin`, then edit and `jj` in `~/Sources/dotfiles`.
  `just update` (writes `flake.lock`) must run as `javadmin`.
- **Apps:** casks install to `~/Applications` as `jav`; nothing writes
  `/Applications`. Casks that ship a `.pkg` need root and are not declared
  here. `homebrew.masApps` is out too: `mas` escalates via sudo to
  install. Tailscale is installed by hand from the App Store as `jav`.
- **Recovery:** `javadmin` always has full sudo. If a sudoers change is
  wrong, fix it from that account.

What this does not cover: flake inputs (nixpkgs, overlays) still evaluate
and activate as root. Read the `flake.lock` diff on `just update`.

## Caveats

This project assumes a particular undocumented MacOS
configuration.  Work is in progress to document this and
modularlize components to be more reusable.
