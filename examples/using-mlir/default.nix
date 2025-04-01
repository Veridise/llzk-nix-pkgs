{ stdenv
, lib
, cmake
, ninja
, mlir
}:

stdenv.mkDerivation {
  pname = "using-mlir-example";
  version = "0.0.0";

  src = lib.cleanSource ./.;

  buildInputs = [ mlir ];
  nativeBuildInputs = [ cmake ninja ];

  postInstall = ''touch "$out"'';
}
