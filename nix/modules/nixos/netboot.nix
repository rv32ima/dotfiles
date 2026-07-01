{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];

  config.system.build.netboot =
    let
      autoexec = pkgs.writeTextDir "autoexec.ipxe" ''
        #!ipxe
        # Use the cmdline variable to allow the user to specify custom kernel params
        # when chainloading this script from other iPXE scripts like netboot.xyz
        imgfree
        kernel bzImage
        initrd initrd
        imgargs bzImage init=${config.system.build.toplevel}/init initrd=initrd nohibernate loglevel=4 lsm=landlock,yama,bpf
        boot
      '';
    in
    pkgs.stdenv.mkDerivation {
      name = "netboot";
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out
        cp ${config.system.build.netbootRamdisk}/* $out
        cp ${config.system.build.kernel}/* $out
        cp ${autoexec}/* $out
      '';
    };
}
