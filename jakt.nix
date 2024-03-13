{ stdenv
, lib
, fetchFromGitHub
, buildInputs
, nativeBuildInputs
, clang_16
}:

stdenv.mkDerivation (finalAttrs: let
  serenity = fetchFromGitHub {
    owner = "SerenityOS";
    repo = "serenity";
    rev = "5da9f52b1ffd5b17a9fb8213a616287ffb427dca";
    hash = "sha256-BAh8J8AvP9GpP8mYtQ30Ata2ppP8evHx7omUdbRZsOE=";
  };
  src = fetchFromGitHub {
    owner = "SerenityOS";
    repo = "jakt";
    rev = "f7ab7725114538f0668c58973bab2cf52b8e121c";
    hash = "sha256-qGXeLoKPZ5qbgvtizMumnKFxf1bxF5BZa7SbTMWSHv0=";
  };
in {
  inherit buildInputs nativeBuildInputs src;

  name = "jakt";

  patches = [
    ./fix-cmake-copy-permissions.diff
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=${clang_16}/bin/clang++"
    "-DSERENITY_SOURCE_DIR=${serenity}"
    "-DCMAKE_INSTALL_BINDIR=bin"
  ];
})
