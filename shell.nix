{ pkgs ? import <nixpkgs> { } }:
with pkgs; mkShell {
  nativeBuildInputs = [
  ];
  buildInputs = [
    nodejs_20
  ];
}
