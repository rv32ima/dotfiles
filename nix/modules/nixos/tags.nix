{ self, ... }:

{
  # Tag every generation with the repo commit hash:
  system.nixos.tags = [
    "rev-${if self ? rev then builtins.substring 0 7 self.rev else "unknown"}"
  ];
}
