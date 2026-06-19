{ ... }: {
  config = {
    services.victoriametrics.enable = true;
    services.victoriametrics.retentionPeriod = "30d";

    services.vmagent.enable = true;
    services.vmagent.remoteWrite.url = "http://localhost:8428/api/v1/write";
    services.vmagent.prometheusConfig = {
      scrape_configs = [
        {
          job_name = "restic-exporter";
          static_configs = [
            {
              targets = [
                "http://sisterhood.tail09d5b.ts.net:9753"
              ];
            }
          ];
        }
      ];
    };

  };
}
