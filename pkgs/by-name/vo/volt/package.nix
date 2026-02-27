{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "volt";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "hqnna";
    repo = "volt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o/wMeZca7ttTwRSqp5l6XmurDT1oClq7nvfv6WgnSj8=";
  };

  cargoHash = "sha256-HIae9ZpFsa/XCkoesAaiWaotNloYCz+Km9cICM6r4qE=";

  meta = {
    description = "Ergonomic terminal settings editor for the Amp coding agent";
    homepage = "https://github.com/hqnna/volt";
    license = lib.licenses.blueOak100;
    maintainers = with lib.maintainers; [ qweered ];
    mainProgram = "volt";
  };
})
