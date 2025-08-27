alias s := switch
alias b := build

flake := `jj workspace root`

switch:
    su -l javadmin -c "sudo darwin-rebuild switch --flake {{flake}}"

build:
    darwin-rebuild build --flake {{flake}}
