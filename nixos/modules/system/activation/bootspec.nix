# Note that these schemas are defined by RFC-0125.
# This document is considered a stable API, and is depended upon by external tooling.
# Changes to the structure of the document, or the semantics of the values should go through an RFC.
#
# See: https://github.com/NixOS/rfcs/pull/125
{ config, pkgs, lib, children }:
let
  schemas = {
    v1 = rec {
      json =
        pkgs.writeText "boot.json"
          (builtins.toJSON
            {
              kernel = "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
              kernelParams = config.boot.kernelParams;
              initrd = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
              initrdSecrets = "${config.system.build.initialRamdiskSecretAppender}/bin/append-initrd-secrets";
              label = "NixOS ${config.system.nixos.codeName} ${config.system.nixos.label} (Linux ${config.boot.kernelPackages.kernel.modDirVersion})";
            });

      generator =
        let
          specialisationLoader = (lib.mapAttrsToList
            (childName: childToplevel: lib.escapeShellArgs [ "--slurpfile" childName "${childToplevel}/boot.json" ])
            children);
        in
        ''
          ${pkgs.jq}/bin/jq '
            .toplevel = $toplevel |
            .init = $init
            ' \
            --sort-keys \
            --arg toplevel "$out" \
            --arg init "$out/init" \
            < ${json} \
            | ${pkgs.jq}/bin/jq '
              .specialisation = (
                $ARGS.named | map_values(. | first | .v1)
              ) |
              { v1: . }
              ' \
              --sort-keys \
              ${lib.concatStringsSep " " specialisationLoader} \
              > $out/boot.json
        '';
    };
  };
in
rec {
  # This will be run as a part of the `systemBuilder` in ./top-level.nix. This
  # means `$out` points to the output of `config.system.build.toplevel` and can
  # be used for a variety of things (though, for now, it's only used to report
  # the path of the `toplevel` itself and the `init` executable).
  writer = schemas.v1.generator;

  validator = "${pkgs.bootspec}/bin/validate $out/boot.json";
}
