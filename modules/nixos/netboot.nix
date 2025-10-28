{
  config,
  pkgs,
  ...
}:
{
  config.system.build.netboot = pkgs.symlinkJoin {
    name = "netboot";
    paths = with config.system.build; [
      netbootRamdisk
      kernel
      (pkgs.writeTextDir "autoexec.ipxe" ''
        #!ipxe
        # Use the cmdline variable to allow the user to specify custom kernel params
        # when chainloading this script from other iPXE scripts like netboot.xyz
        imgfree
        kernel bzImage
        initrd initrd
        imgargs bzImage init=${config.system.build.toplevel}/init initrd=initrd nohibernate loglevel=4 lsm=landlock,yama,bpf
        boot
      '')
    ];
    preferLocalBuild = true;
  };
}
