alias s := switch
alias r := rollback
alias b := build

flake := `jj workspace root`

switch:
    su -l javadmin -c "sudo darwin-rebuild switch --flake {{flake}}"

rollback:
    su -l javadmin -c "sudo darwin-rebuild switch --rollback"

build:
    darwin-rebuild build --flake {{flake}}

clean:
    rm result
