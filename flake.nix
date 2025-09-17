{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/e9b7f2f";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = final: prev: {

      llzk_llvmPackages = (import ./packages/llzk_llvm/default.nix {
        llvmPackages = final.llvmPackages_20;
      }) final;

      mlir = final.llzk_llvmPackages.mlir;
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      packages = flake-utils.lib.flattenTree {
        inherit (pkgs.llzk_llvmPackages) mlir;
      };

      formatter = pkgs.nixpkgs-fmt;

      checks = {
        using-mlir = pkgs.callPackage ./examples/using-mlir {};
      };
    }
  ));
}
