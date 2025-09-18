{ llvmPackages
, cmakeBuildType ? "Release"
}:

let
  mkPackageBase = pkgs: {
    tools = llvmPackages.tools.extend (tpkgs: tpkgsOld: {
      libllvm = tpkgsOld.libllvm.overrideAttrs (attrs: {
        inherit cmakeBuildType;
        cmakeFlags = attrs.cmakeFlags ++ [
          # Skip irrelevant targets
          "-DLLVM_TARGETS_TO_BUILD=host"
          "-DLLVM_INCLUDE_BENCHMARKS=OFF"
          "-DLLVM_INCLUDE_EXAMPLES=OFF"
          "-DLLVM_INCLUDE_TESTS=OFF"
          # Need the following to enable exceptions
          "-DLLVM_ENABLE_EH=ON"
          # Assertions are very useful for debugging
          "-DLLVM_ENABLE_ASSERTIONS=ON"
          # Enable Z3 Solver for SMTSolver usage
          "-DLLVM_ENABLE_Z3_SOLVER=ON"
        ];
        propagatedBuildInputs = attrs.propagatedBuildInputs ++ [pkgs.z3];
        # Skip tests since they take a long time to build and run
        doCheck = false;

        postInstall = pkgs.lib.optionalString (cmakeBuildType != "Release") ''
          ln -s $dev/lib/cmake/llvm/LLVMExports-${pkgs.lib.toLower cmakeBuildType}.cmake $dev/lib/cmake/llvm/LLVMExports-release.cmake
        '' + attrs.postInstall;
      });

      mlir = pkgs.callPackage ./mlir/default.nix {
        inherit cmakeBuildType;
        inherit (tpkgs.libllvm) monorepoSrc version;
        buildLlvmTools = tpkgs;
        llvm_meta = llvmPackages.libllvm.meta;
        inherit (tpkgs) libllvm;
      };
    });
  };

  mkPackage = pkgs:
    let base = mkPackageBase pkgs;
    in base // { inherit (base) tools; } // (pkgs.lib.attrsets.removeAttrs base.tools [ "extend" ]);
in
mkPackage
