{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let

  doom-emacs = pkgs.callPackage ../../../test/shell.nix {};
  rust = import ./test/rust.nix;

in pkgs.stdenv.mkDerivation {
  name = "rust-shell";
  buildInputs = rust.buildInputs;

  shellHook = doom-emacs.shellHook;
  }

