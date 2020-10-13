{ pkgs ? import nixpkgsSrc nixpkgsArgs
, haskellNixSrc ? builtins.fetchTarball {
    # master as of 2020-10-13
    url = "https://github.com/input-output-hk/haskell.nix/archive/ab2f5a9b6d8cb1b18810194d9f4a6208710c358c.tar.gz";
    sha256 = "1j3zwrrmnigl44lqdiyywwhj5m0wb4v6bpl89v1wp31vxwyyf7rv";
  }
, haskellNix ? import haskellNixSrc {}
, nixpkgsSrc ? haskellNix.sources.nixpkgs-2009 
, nixpkgsArgs ? haskellNix.nixpkgsArgs
# ghc version. ghc8102 won't build. ghc884 and ghc865 will.
, compiler-nix-name ? "ghc884"
# , compiler-nix-name ? "ghc865"
}:

let
  inherit (pkgs) lib;

  ghc = pkgs.haskell-nix.compiler.${compiler-nix-name};

  hlsPkgs = pkgs.haskell-nix.cabalProject {
    src = pkgs.fetchFromGitHub {
      name = "haskell-language-server";
      owner = "haskell";
      repo = "haskell-language-server";
      rev = "0.5.0";
      sha256 = "0vkh5ff6l5wr4450xmbki3cfhlwf041fjaalnwmj7zskd72s9p7p";
      fetchSubmodules = true;
    };

    # Fix source info of brittany dep
    lookupSha256 = { location, tag, ... } : {
      "https://github.com/bubba/brittany.git"."c59655f10d5ad295c2481537fc8abf0a297d9d1c" = "1rkk09f8750qykrmkqfqbh44dbx1p8aq1caznxxlw8zqfvx39cxl";
      }."${location}"."${tag}";

    # Use same GHC as the project
    inherit compiler-nix-name;

    # # Materialization voodoo (disabled for now).
    # inherit index-state checkMaterialization;
    # Invalidate and update if you change the version
    # plan-sha256 = "144p19wpydc6c56f0zw5b7c17151n0cghimr9wd8rlhifymmky2h";
  };

  ghcidePkgs = pkgs.haskell-nix.cabalProject {
    src = pkgs.fetchFromGitHub {
      name = "ghcide";
      owner = "haskell";
      repo = "ghcide";
      rev = "10dbde048e8ac028e80f607445776c8375722f75";
      sha256 = "0ygh6xikzqak2d185j2fgs7pd81ymzqb35grv092cf2mpxgp38xf";
    };

    # Use same GHC as the project
    inherit compiler-nix-name;
  };

in
  pkgs.mkShell rec {
    buildInputs = [
      pkgs.cabal-install
      pkgs.pkgconfig
      pkgs.zlib
      ghc

      hlsPkgs.haskell-language-server.components.exes.haskell-language-server
      hlsPkgs.hie-bios.components.exes.hie-bios
      ghcidePkgs.ghcide.components.exes.ghcide
    ];

    # Ensure that libz.so and other libraries are available to TH
    # splices, cabal repl, etc.
    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

    passthru = {
      inherit pkgs ghc hlsPkgs ghcidePkgs;
    };

    # Prevents the evaluation-time dependencies from being garbage-collected
    # roots = haskell-nix.roots compiler-nix-name;
    # roots = { hls = hlsPkgs.roots; ghcide = ghcidePkgs.roots; };
  }
