{
  lib,
  stdenv,
  fetchzip,
  firefox-bin,
  suffix,
  revision,
  system,
  throwSystem,
}:
let
  firefox-linux = stdenv.mkDerivation {
    name = "playwright-firefox";
    src = fetchzip {
      url = "https://playwright.azureedge.net/builds/firefox/${revision}/firefox-${
        "ubuntu-22.04" + (lib.removePrefix "linux" suffix)
      }.zip";
      hash =
        {
          x86_64-linux = "sha256-8rzJzvlCyDWjXFexoyleVTFBI1f9B99g6nM24Kf0xnw=";
          aarch64-linux = "sha256-pPj1HturXVcMUGqDA1gC8OjCQbcZTWtHrQjFTSljvvY=";
        }
        .${system} or throwSystem;
    };

    inherit (firefox-bin.unwrapped)
      nativeBuildInputs
      buildInputs
      runtimeDependencies
      appendRunpaths
      patchelfFlags
      ;

    buildPhase = ''
      mkdir -p $out/firefox
      cp -R . $out/firefox
    '';
  };
  firefox-darwin = fetchzip {
    url = "https://playwright.azureedge.net/builds/firefox/${revision}/firefox-${suffix}.zip";
    stripRoot = false;
    hash =
      {
        x86_64-darwin = "sha256-EHGo9LxTbz9m4eTLw0qrItDpAZ29hwiXK9r7H4Q40q4=";
        aarch64-darwin = "sha256-CN1Ok+6FvYPO8Tspjs2VNifuGpKx/pETmJO+GGaehBw=";
      }
      .${system} or throwSystem;
  };
in
{
  x86_64-linux = firefox-linux;
  aarch64-linux = firefox-linux;
  x86_64-darwin = firefox-darwin;
  aarch64-darwin = firefox-darwin;
}
.${system} or throwSystem
