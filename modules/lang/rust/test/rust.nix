let pkgs = import <nixpkgs> {};

in pkgs.stdenv.mkDerivation rec {
  name = "rust";
    buildInputs = with pkgs; [
      cargo rustc rustfmt clippy rust-analyzer rls
    ];
}
