{ lib, stdenv, callPackage, fetchurl, nixosTests, commandLineArgs ? "", useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin }:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat = {
    x86_64-linux = "linux-x64";
    x86_64-darwin = "darwin-x64";
    aarch64-linux = "linux-arm64";
    aarch64-darwin = "darwin-arm64";
    armv7l-linux = "linux-armhf";
  }.${system} or throwSystem;

  archive_fmt = if stdenv.hostPlatform.isDarwin then "zip" else "tar.gz";

  sha256 = {
    x86_64-linux = "1dn0yz3y2vhw5sisv152qpbk9ghbbg45ncx75zzza1k6dwn5gwjm";
    x86_64-darwin = "1h9xz27y3ijnyjwchy1j8jxiri4l96rlh35zg6gd9kkih5jszynf";
    aarch64-linux = "13pi9vnl59ff5k7qncp8nj7zg9z18nxbq8jhnrrvz5pfsfakb5iq";
    aarch64-darwin = "0w6y767y5245g6fi5fmjzlvxn0aqb6bvmlqrqzvdrfhkyll35rca";
    armv7l-linux = "1vkfqv5i5limfwasw57rnyq2b2mvaqsw1qw1m8vn25akfsl9764r";
  }.${system} or throwSystem;

  sourceRoot = lib.optionalString (!stdenv.hostPlatform.isDarwin) ".";
in
  callPackage ./generic.nix rec {
    inherit sourceRoot commandLineArgs useVSCodeRipgrep;

    # Please backport all compatible updates to the stable release.
    # This is important for the extension ecosystem.
    version = "1.95.1.24307";
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
      maintainers = with maintainers; [ synthetica bobby285271 ludovicopiero ];
      mainProgram = "codium";
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" "armv7l-linux" ];
    };
  }
