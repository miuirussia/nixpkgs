{ lib
, fetchFromGitHub
, rustPlatform
}:
rustPlatform.buildRustPackage {
  pname = "bootspec";
  version = "unstable-2022-05-31";

  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "bootspec";
    rev = "308253d2d1057ae217eabdaa3af269010435edce";
    sha256 = "sha256-LYhbRoujzR2sl5d4ew9oH+EFiqYjgzE/gwl1eAODcMU=";
  };

  cargoSha256 = "sha256-7r3K/h4q3dkRhPDRJG9t7J8tJU9XUbfHrPfylVnqWKE=";

  meta = with lib; {
    description = "Implementation of RFC-0125's datatype and synthesis tooling";
    homepage = "https://github.com/DeterminateSystems/bootspec";
    license = licenses.mit;
    maintainers = teams.determinatesystems.members;
  };
}
