{
  description = "Jav's system configurations";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f:
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
        ] (system: f nixpkgs.legacyPackages.${system});
    in {
    }
  ;
}
