{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  nixosTests,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      x86_64-linux = "linux-x64";
      x86_64-darwin = "darwin-x64";
      aarch64-linux = "linux-arm64";
      aarch64-darwin = "darwin-arm64";
      armv7l-linux = "linux-armhf";
    }
    .${system} or throwSystem;

  archive_fmt = if stdenv.hostPlatform.isDarwin then "zip" else "tar.gz";

  sha256 =
    {
      x86_64-linux = "sha256-KmU44ORDUlKIwREdWeN+RBLmiB078vOSM2TCcxA+P5Q=";
      x86_64-darwin = "sha256-Ohw/e5sj/cK8jEQd3I9KWXydO/r0YAuEwypPHYgw/b4=";
      aarch64-linux = "sha256-MSzaILkX9x+MRd0qW7w0eeuXZjQMYNQXyfUASwYX8j4=";
      aarch64-darwin = "sha256-djUef0XPSiFNmDRsAo7k3LZMajXt9tbP/Hr3pWduRxU=";
      armv7l-linux = "sha256-kUuaVbnPqvutGKL/7RGtM0DFoFmweoqCJnzrArswQOA=";
    }
    .${system} or throwSystem;

  sourceRoot = lib.optionalString (!stdenv.hostPlatform.isDarwin) ".";
in
callPackage ./generic.nix rec {
  inherit sourceRoot commandLineArgs useVSCodeRipgrep;

  # Please backport all compatible updates to the stable release.
  # This is important for the extension ecosystem.
  version = "1.97.0.25037";
  pname = "vscodium";

  executableName = "codium";
  longName = "VSCodium";
  shortName = "vscodium";

  src = fetchurl {
    url = "https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-${plat}-${version}.${archive_fmt}";
    inherit sha256;
  };

  tests = nixosTests.vscodium;

  updateScript = ./update-vscodium.sh;

  # Editing the `codium` binary (and shell scripts) within the app bundle causes the bundle's signature
  # to be invalidated, which prevents launching starting with macOS Ventura, because VSCodium is notarized.
  # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
  dontFixup = stdenv.hostPlatform.isDarwin;

  meta = with lib; {
    description = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS (VS Code without MS branding/telemetry/licensing)
    '';
    longDescription = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS. It includes support for debugging, embedded Git
      control, syntax highlighting, intelligent code completion, snippets,
      and code refactoring. It is also customizable, so users can change the
      editor's theme, keyboard shortcuts, and preferences
    '';
    homepage = "https://github.com/VSCodium/vscodium";
    downloadPage = "https://github.com/VSCodium/vscodium/releases";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [
      synthetica
      bobby285271
      ludovicopiero
    ];
    mainProgram = "codium";
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
    ];
  };
}
