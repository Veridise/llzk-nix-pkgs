{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = final: prev: {

      llzk_llvmPackages = (import ./packages/llzk_llvm/default.nix {
        llvmPackages = final.llvmPackages_18;
      }) final;

      mlir = final.llzk_llvmPackages.mlir;
      libllvm = final.llzk_llvmPackages.libllvm;
      llvm = final.llzk_llvmPackages.llvm;
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
        inherit (pkgs.llzk_llvmPackages) mlir libllvm llvm;
      };

      formatter = pkgs.nixpkgs-fmt;

      checks = {
        using-mlir = pkgs.callPackage ./examples/using-mlir {};
      };
    }
  ));
}
