{
  description = "Python kernel for VS Code notebooks named \"select this one for tft data\"";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          ipykernel
          notebook
          pandas
          pip
          # optionally add numpy, pandas, matplotlib, etc.
        ]);
      in {
        devShells.default = pkgs.mkShell {
          name = "test";
          packages = [ pythonEnv ];
          shellHook = ''
            # Register the kernel under the name "test" each time you enter the shell
            ${pythonEnv.interpreter} -m ipykernel install --user --name=test --display-name "select this one for tft data"
          '';
        };
      });
}
