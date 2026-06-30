{ linux, ... }:
linux.override (old: {
  kernelPatches = (old.kernelPatches or [ ]) ++ [
    {
      name = "mlx-stuff";
      patch = null;
      extraConfig = ''
        MELLANOX_PLATFORM y
        MLXREG_HOTPLUG m
        MLXREG_IO m
        MLXREG_LC m
        NVSW_SN2201 m
        SENSORS_MLXREG_FAN m
      '';
    }
  ];
})
