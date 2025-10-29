{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tuios";
  version = "latest";

  src = fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    rev = "main";  # or specify a specific commit/tag
    hash = "sha256-cN8jubDeK+w8E6Mii6kyi2b/ugmqqfDk+sz1U4akBJc=";
  };

  vendorHash = "sha256-0hxj6EUTCV7R59XJheHj9PR/oWQH+2uzYOPhVQWa0hU=";

  # Build the tuios command
  subPackages = [ "cmd/tuios" ];

  meta = with lib; {
    description = "A TUI for managing iOS devices";
    homepage = "https://github.com/Gaurav-Gosain/tuios";
    license = licenses.mit;
    maintainers = [ ];
  };
}
