# https://github.com/NixOS/hydra/issues/682
{
  description = "Local hydra";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default =
        pkgs.mkShell {
          name = "test-shell";
          buildInputs = [ pkgs.hydra_unstable ];
        };
    };
}
