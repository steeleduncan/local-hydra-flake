# https://github.com/NixOS/hydra/issues/682
# https://gist.github.com/jvolkman/6e61c52d953677f66f32d8f77b157e61
{
  description = "Local hydra";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      #
      # TODO create data dir
      # initdb -D postgres
      # createuser hydra
      #
      blank_pg_database = pkgs.stdenv.mkDerivation {
          name = "test-shell";

          # Avoid passing any sources in
          unpackPhase = "true";

          buildInputs = [
            pkgs.postgresql_16
          ];

          buildPhase = ''
                export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
                mkdir -p data-folder
                initdb -D data-folder
          '';
        
          installPhase = ''
                 mkdir -p $out
                 cp -r data-folder/* $out/
          '';
      };
    in {
      packages.x86_64-linux.blankdb = blank_pg_database;

      devShells.x86_64-linux.default =
        pkgs.mkShell {
          name = "test-shell";
          buildInputs = [
            pkgs.hydra_unstable
            pkgs.postgresql_16
          ];
        };
    };
}
