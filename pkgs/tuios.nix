{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tuios";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    rev = "v0.7.0";
    hash = "sha256-XPcgUDlIbwp278Kc9B0aXxxIX2XnsJpFzxHDaop9cLs=";
  };

  vendorHash = "sha256-98XZe60gcRWyP0ApUV+qCJ0UoAExx7X0FPtFL0Tr0a4=";

  # Build the tuios command
  subPackages = [ "cmd/tuios" ];

  meta = with lib; {
    description = "A TUI for managing iOS devices";
    homepage = "https://github.com/Gaurav-Gosain/tuios";
    license = licenses.mit;
    maintainers = [ ];
  };
}
