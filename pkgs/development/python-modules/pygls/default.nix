{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  lsprotocol2023,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  typeguard,
  websockets,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "pygls";
  version = "1.3.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = "pygls";
    tag = "v${version}";
    hash = "sha256-AvrGoQ0Be1xKZhFn9XXYJpt5w+ITbDbj6NFZpaDPKao=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    lsprotocol2023
    typeguard
  ];

  optional-dependencies = {
    ws = [ websockets ];
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  # Fixes hanging tests on Darwin
  __darwinAllowLocalNetworking = true;

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Darwin issue: OSError: [Errno 24] Too many open files
    ulimit -n 1024
  '';

  pythonImportsCheck = [ "pygls" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # Skips pre-releases
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = with lib; {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    changelog = "https://github.com/openlawlibrary/pygls/blob/${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
