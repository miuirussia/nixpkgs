{ config, pkgs, lib, children }:
let
  schemas = {
    v1 = rec {
      filename = "boot.v1.json";
      json =
        pkgs.writeText filename
          (builtins.toJSON
            {
              schemaVersion = 1;

              kernel = "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
              kernelParams = config.boot.kernelParams;
              kernelVersion = config.boot.kernelPackages.kernel.modDirVersion;
              initrd = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
              initrdSecrets = "${config.system.build.initialRamdiskSecretAppender}/bin/append-initrd-secrets";
              systemVersion = config.system.nixos.label;

              specialisation = lib.mapAttrs
                (childName: childToplevel: {
                  bootspec = "${childToplevel}/${filename}";
                  toplevel = childToplevel;
                })
                children;
            });

      generator = ''
        ${pkgs.jq}/bin/jq '
          .toplevel = $toplevel |
          .init = $init
          ' \
          --sort-keys \
          --arg toplevel "$out" \
          --arg init "$out/init" \
          < ${json} \
          > $out/${filename}
      '';
    };
  };
in
{
  # This will be run as a part of the `systemBuilder` in ./top-level.nix. This
  # means `$out` points to the output of `config.system.build.toplevel` and can
  # be used for a variety of things (though, for now, it's only used to report
  # the path of the `toplevel` itself and the `init` executable).
  writer = schemas.v1.generator;
}
