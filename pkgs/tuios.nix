{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tuios";
  version = "latest";

  src = fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    rev = "main";  # or specify a specific commit/tag
    hash = "sha256-Ra9n1LayjRnDv1BQj+DgbgZb54pn+XumBkbDd1+VCP4=";
  };

  vendorHash = "sha256-kDZRT/Ua+SaxyZ6RI9ZY2tqBgQBWo755fvQVRupBsUc=";

  # Build the tuios command
  subPackages = [ "cmd/tuios" ];

  meta = with lib; {
    description = "A TUI for managing iOS devices";
    homepage = "https://github.com/Gaurav-Gosain/tuios";
    license = licenses.mit;
    maintainers = [ ];
  };
}
