{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
        gspread-df =    pkgs.python313Packages.buildPythonPackage rec {
            pname = "gspread-dataframe";
            version = "4.0.0"; # check PyPI for latest
            src = pkgs.fetchPypi {
              inherit pname version;
              sha256 = "sha256-XKVJNHjsrkm4M2ZKBrrI4XtbTtC9939VHJSPMFRYYOY=";
            };
            doCheck = false;
            format = "setuptools"; # <-- this is usually what you need
          };
    in
      rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python313.withPackages(ps: with ps; [
              jupyter
              ipykernel
              numpy
              pandas
              oauth2client
              gspread
              gspread-df 
              
            ]))
          ];
          shellHook = "
            ./run-nb
          ";
        };
      }
    );
}   