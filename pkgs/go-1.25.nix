{ stdenv, fetchurl, lib, go_1_24 }:

stdenv.mkDerivation rec {
  pname = "go";
  version = "1.25.1";

  src = fetchurl {
    url = "https://dl.google.com/go/go${version}.src.tar.gz";
    hash = "sha256-0BDBCc7pTYDv5oHqtGvepJGskGv0ZYPDLp8NuwvRpZQ=";
  };

  nativeBuildInputs = [ go_1_24 ];

  hardeningDisable = [ "all" ];

  prePatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    export GOROOT_BOOTSTRAP=${go_1_24}/share/go
    export GOCACHE=$TMPDIR/go-cache
    export GOMODCACHE=$TMPDIR/go-mod-cache
    export HOME=$TMPDIR
    mkdir -p $GOCACHE $GOMODCACHE
    cd src
    ./make.bash
  '';

  installPhase = ''
    cd ..
    mkdir -p $out/share/go $out/bin
    cp -r bin pkg src lib misc api test $out/share/go
    ln -s $out/share/go/bin/* $out/bin/
  '';

  meta = with lib; {
    description = "The Go Programming Language";
    homepage = "https://golang.org/";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}