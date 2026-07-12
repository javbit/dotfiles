alias s := switch
alias r := rollback
alias b := build
alias u := upgrade
alias c := clean
alias d := deploy

flake := `jj workspace root`

switch:
    su -l javadmin -c "sudo darwin-rebuild switch --flake {{flake}}"

rollback:
    su -l javadmin -c "sudo darwin-rebuild switch --rollback"

build:
    darwin-rebuild build --flake {{flake}}

deploy target:
    nixos-rebuild switch --build-host root@{{target}} --target-host root@{{target}} --flake {{flake}}#{{target}} --no-reexec --use-substitutes

update:
    nix flake update

upgrade:
    su -l javadmin -c 'sudo determinate-nixd upgrade && brew upgrade'

clean:
    rm result
