{
  description = "Generate Kysely type definitions from Atlas schemas";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      mkPkgs = system:
        import nixpkgs { inherit system; };
      mkAtlasToKysely = pkgs: pkgs.callPackage ./package.nix { };
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.go
              pkgs.golangci-lint
              pkgs.just
            ];
          };
        }
      );

      packages = forEachSystem (
        system:
        let
          atlas-to-kysely = mkAtlasToKysely (mkPkgs system);
        in
        {
          inherit atlas-to-kysely;
          default = atlas-to-kysely;
        }
      );

      overlays.default = _final: prev: {
        atlas-to-kysely = self.packages.${prev.stdenv.hostPlatform.system}.atlas-to-kysely;
      };
    };
}
