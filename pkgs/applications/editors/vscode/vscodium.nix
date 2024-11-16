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
    x86_64-linux = "0wixk4rhkj3cxbzbb5r9wrzn9rnzydfwp8afg54jb024s1k531al";
    x86_64-darwin = "1bk14y09dcgnqblfrxqmn647bx6wfsz046b3hy9jza5wadkrj5kg";
    aarch64-linux = "1b17yr3qgaivjygz4pah7bkzpvjbv1f51w7vk9vb51a2sp162hdi";
    aarch64-darwin = "1cygkgw5qz8z6xk2f81z1488nx940vxazgxqi5wvafgapsnlw6k5";
    armv7l-linux = "0aagszvc2n04fvv1zpbmyxm5lmxjbqypf2jpxcpwp0nnj4aiwssq";
  }.${system} or throwSystem;

  sourceRoot = lib.optionalString (!stdenv.hostPlatform.isDarwin) ".";
in
  callPackage ./generic.nix rec {
    inherit sourceRoot commandLineArgs useVSCodeRipgrep;

    # Please backport all compatible updates to the stable release.
    # This is important for the extension ecosystem.
    version = "1.95.3.24320";
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
