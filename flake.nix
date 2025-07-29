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
           (pkgs.python311Packages.buildPythonPackage rec {
            pname = "gspread";
            version = "6.1.2"; # check PyPI for latest
            src = pkgs.fetchPypi {
              inherit pname version;
              sha256 = "sha256-sUdoi4x6GMmDXV+ZiZfsF8l8BHC6vKsX9lrCs6MkArc=";
            };
            doCheck = false;
            format = "setuptools"; # <-- this is usually what you need
          })
          # oauth2client
          numpy
          pip
          # optionally add numpy, pandas, matplotlib, etc.
        ]);
      in {
        packages.default = pythonEnv; # needs this line to be "nix build"-able
        devShells.default = pkgs.mkShell {
          name = "test";
          packages = [ pythonEnv ];
          # echo "${builtins.concatStringsSep " " (map (p: p.pname or p.name) pythonEnv)}"
          shellHook = ''
          echo "${pythonEnv}  <-- 2select this in notebook"
            # jupyter kernelspec remove -f tft-data >/dev/null 2>&1 || true
            # Register the kernel under the name "test" each time you enter the shell
            ${pythonEnv.interpreter} -m ipykernel install --user --name=test --display-name "${pythonEnv}"
          '';
        };
      });
}
