{ callPackage
, kernel ? null
, stdenv
, linuxKernel
, removeLinuxDRM ? false
, ...
} @ args:

let
  stdenv' = if kernel == null then stdenv else kernel.stdenv;
in
callPackage ./generic.nix args {
  # check the release notes for compatible kernels
  kernelCompatible = if stdenv'.isx86_64 || removeLinuxDRM
    then kernel.kernelOlder "6.5"
    else kernel.kernelOlder "6.2";

  latestCompatibleLinuxPackages = linuxKernel.packages.linux_6_4;

  # this package should point to a version / git revision compatible with the latest kernel release
  # IMPORTANT: Always use a tagged release candidate or commits from the
  # zfs-<version>-staging branch, because this is tested by the OpenZFS
  # maintainers.
  version = "2.1.13-unstable-2023-07-26";
  rev = "1abf68b7aea298d6335d64e2e2bcf24681c84a9e";

  sha256 = "o73OZv9liDJPTED4uAYEn6TG2Ek+74sqVuT7oGL8Rms=";

  isUnstable = true;
}
