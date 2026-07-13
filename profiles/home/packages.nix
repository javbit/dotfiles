{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      awscli2
      swi-prolog
      scryer-prolog
      zmx

      nixos-rebuild

      my-agda # Keep Emacs mode & package together.
    ];
  };
}
