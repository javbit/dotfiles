alias s := switch
alias r := rollback
alias b := build
alias u := upgrade
alias c := clean

flake := `jj workspace root`

switch:
    su -l javadmin -c "sudo darwin-rebuild switch --flake {{flake}}"

rollback:
    su -l javadmin -c "sudo darwin-rebuild switch --rollback"

build:
    darwin-rebuild build --flake {{flake}}

upgrade:
    su -l javadmin -c 'sudo determinate-nixd upgrade && brew upgrade'

clean:
    rm result
