{
  description = "Minimal Python dev shell with requests";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.python310
          pkgs.python310Packages.requests
        ];
        shellHook = ''
          echo "Python $(python --version) with requests ready!"
        '';
      };
    };
}
