{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = final: prev: {

      llzk_llvmPackages = (import ./packages/llzk_llvm/default.nix {
        llvmPackages = final.llvmPackages_20;
      }) final;

      llzk_llvmPackages_debug = (import ./packages/llzk_llvm/default.nix {
        llvmPackages = final.llvmPackages_20;
        cmakeBuildType = "RelWithDebInfo";
      }) final;

      mlir = final.llzk_llvmPackages.mlir;
      mlir_debug = final.llzk_llvmPackages_debug.mlir;
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
        inherit (pkgs) mlir mlir_debug;
      };

      formatter = pkgs.nixpkgs-fmt;

      checks = {
        using-mlir-release = pkgs.callPackage ./examples/using-mlir {
          mlir_pkg = pkgs.mlir;
        };
        using-mlir-debug = pkgs.callPackage ./examples/using-mlir {
          mlir_pkg = pkgs.mlir_debug;
        };
      };
    }
  ));
}
