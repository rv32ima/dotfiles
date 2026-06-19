{ ... }: {
  config = {
    services.tsidp = {
      enable = true;
      settings = {
        hostName = "tsidp";
      };
    };
  };
}
