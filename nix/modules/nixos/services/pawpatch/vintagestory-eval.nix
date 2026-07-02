{ pkgs, ... }:
let
  evalServer = pkgs.writers.writePython3Bin "vintagestory-eval" { doCheck = false; } ''
    import os
    import subprocess
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

    FIFO = "/run/vintagestory.stdin"

    HTML = b"""<!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8">
    <title>vs eval</title>
    <style>
    * { box-sizing: border-box; }
    body { background: #0d0d0d; color: #c8c8c8; font-family: monospace; margin: 0;
           display: flex; flex-direction: column; height: 100vh; padding: 0.75em; gap: 0.5em; }
    #log { flex: 1; overflow-y: auto; white-space: pre-wrap; word-break: break-all;
           border: 1px solid #2a2a2a; padding: 0.5em; }
    form { display: flex; gap: 0.5em; }
    input { flex: 1; background: #1a1a1a; color: #c8c8c8; border: 1px solid #333;
            padding: 0.4em 0.6em; font-family: monospace; font-size: 1em; }
    button { background: #1a1a1a; color: #c8c8c8; border: 1px solid #444;
             padding: 0.4em 1em; cursor: pointer; font-family: monospace; }
    button:hover { background: #2a2a2a; }
    footer { color: #444; font-size: 0.8em; text-align: center; }
    </style>
    </head>
    <body>
    <div id="log"></div>
    <form id="f">
    <input type="text" id="cmd" placeholder="/" autocomplete="off">
    <button type="submit">send</button>
    </form>
    <footer>made with love by a trans puppygirl and a trans catgirl &hearts;</footer>
    <script>
    const log = document.getElementById("log");
    const es = new EventSource("/logs");
    es.onmessage = e => {
      const atBottom = log.scrollHeight - log.scrollTop <= log.clientHeight + 4;
      const line = document.createElement("div");
      line.innerHTML = e.data;
      log.appendChild(line);
      if (atBottom) log.scrollTop = log.scrollHeight;
    };
    document.getElementById("f").addEventListener("submit", e => {
      e.preventDefault();
      const cmd = document.getElementById("cmd");
      fetch("/send", { method: "POST", body: cmd.value });
      cmd.value = "";
    });
    </script>
    </body>
    </html>"""

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_): pass

        def do_GET(self):
            if self.path == "/":
                self.send_response(200)
                self.send_header("Content-Type", "text/html")
                self.send_header("Content-Length", str(len(HTML)))
                self.end_headers()
                self.wfile.write(HTML)
            elif self.path == "/logs":
                self.send_response(200)
                self.send_header("Content-Type", "text/event-stream")
                self.send_header("Cache-Control", "no-cache")
                self.send_header("X-Accel-Buffering", "no")
                self.end_headers()
                proc = subprocess.Popen(
                    ["journalctl", "-fu", "vintagestory", "--output=cat"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                )
                try:
                    for line in proc.stdout:
                        text = line.decode(errors="replace").rstrip()
                        self.wfile.write(("data: " + text + "\n\n").encode())
                        self.wfile.flush()
                except (BrokenPipeError, ConnectionResetError):
                    pass
                finally:
                    proc.kill()
            else:
                self.send_error(404)

        def do_POST(self):
            if self.path == "/send":
                length = int(self.headers.get("Content-Length", 0))
                body = self.rfile.read(length).decode(errors="replace").strip()
                try:
                    fd = os.open(FIFO, os.O_WRONLY | os.O_NONBLOCK)
                    os.write(fd, (body + "\n").encode())
                    os.close(fd)
                    self.send_response(200)
                    self.end_headers()
                except OSError as e:
                    msg = str(e).encode()
                    self.send_response(500)
                    self.send_header("Content-Length", str(len(msg)))
                    self.end_headers()
                    self.wfile.write(msg)
            else:
                self.send_error(404)


    ThreadingHTTPServer(("", 4242), Handler).serve_forever()
  '';
in
{
  systemd.services."vintagestory-eval" = {
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      User = "vintagestory";
      SupplementaryGroups = "systemd-journal";
      ExecStart = "${evalServer}/bin/vintagestory-eval";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    bindsTo = [ "vintagestory.service" ];
    after = [ "vintagestory.service" ];
    wants = [
      "vintagestory.service"
    ];
  };

  rv32ima.machine.tailscale.services.pawpatch-vs-eval = {
    targetUnit = "vintagestory-eval.service";
    port = 4242;
  };
}
