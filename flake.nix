{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        rust-stable = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
            "rustfmt"
          ];
        };
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rust-stable;
          rustc = rust-stable;
        };
        synap2p = rustPlatform.buildRustPackage {
          pname = "synap2p";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          cargoBuildFlags = [
            "-p"
            "synap2p"
          ];
          doCheck = false;
        };
      in
      {
        packages.synap2p = synap2p;
        packages.default = synap2p;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rust-stable
            cargo-edit
            cargo-watch
            nodejs
            pnpm
          ];
        };
      }
    );
}
