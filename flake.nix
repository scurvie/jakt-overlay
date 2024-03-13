{
  description = "jakt overlay";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }: let
    inherit (flake-utils.lib) defaultSystems;
    forAllSystems = nixpkgs.lib.genAttrs defaultSystems;
  in {
    overlays = {
      jakt = (final: prev:
        let
          buildInputs = with prev; [
            clang_16
            python3
          ];
          nativeBuildInputs = with prev; [
            pkg-config
            cmake
            ninja
          ];
        in {
          jakt = final.callPackage ./jakt.nix {
            inherit buildInputs nativeBuildInputs;
          };
        });
      default = self.overlays.jakt;
    };

    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.jakt
          ];
        };
        jakt = pkgs.jakt;
        default = jakt;
      in {
        inherit default jakt;
      }
    );

    devShells = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        thing = self.packages.${system}.default;
      in {
        default = pkgs.mkShell {
          inherit (thing) buildInputs nativeBuildInputs;
        };
      });
  };
}
