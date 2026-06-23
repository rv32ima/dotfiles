# nix-sshd-proxy: bypass ai-sandbox restrictions!!
# runs a user-level sshd on port 3939 so sandboxed shells can reach nix-daemon via ssh-ng

{
  config,
  pkgs,
  ...
}:

let
  proxyDir = "/tmp/ds-nix-proxy-${config.system.primaryUser}";
  proxyPort = 3939;
  startScript = pkgs.writeShellScript "start-nix-sshd-proxy" ''
    set -euo pipefail

    PROXY_DIR="${proxyDir}"
    PROXY_PORT=${toString proxyPort}
    SSHD_CONFIG="$PROXY_DIR/sshd_config"
    KEY_FILE="$PROXY_DIR/key"
    PUB_FILE="$PROXY_DIR/key.pub"
    AUTH_KEYS="$PROXY_DIR/authorized_keys"
    KNOWN_HOSTS="$PROXY_DIR/known_hosts"
    ENV_FILE="$PROXY_DIR/env"

    echo "setting up nix ssh proxy on port $PROXY_PORT..."

    # create proxy dir
    mkdir -p "$PROXY_DIR"
    chmod 700 "$PROXY_DIR"

    # generate client keypair if it doesnt exist
    if [ ! -f "$KEY_FILE" ]; then
        echo "generating client ssh keypair..."
        ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -C "ds-nix-proxy-${config.system.primaryUser}" -f "$KEY_FILE"
        chmod 600 "$KEY_FILE"
    fi

    # generate host keys 4 th sshd server
    if [ ! -f "$PROXY_DIR/ssh_host_ed25519_key" ]; then
        echo "generating host ed25519 key..."
        ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -f "$PROXY_DIR/ssh_host_ed25519_key"
        chmod 600 "$PROXY_DIR/ssh_host_ed25519_key"
    fi

    if [ ! -f "$PROXY_DIR/ssh_host_rsa_key" ]; then
        echo "generating host rsa key..."
        ${pkgs.openssh}/bin/ssh-keygen -q -t rsa -b 2048 -N "" -f "$PROXY_DIR/ssh_host_rsa_key"
        chmod 600 "$PROXY_DIR/ssh_host_rsa_key"
    fi

    # create authorized_keys w th proxy key
    echo "setting up authorized_keys..."
    cat "$PUB_FILE" > "$AUTH_KEYS"
    chmod 600 "$AUTH_KEYS"

    # generate sshd config w actual paths
    echo "generating sshd config..."
    cat > "$SSHD_CONFIG" <<EOF
    # minimal sshd config 4 nix-proxy on non-standard port
    Port $PROXY_PORT
    ListenAddress 127.0.0.1

    # use our own host keys!!
    HostKey $PROXY_DIR/ssh_host_ed25519_key
    HostKey $PROXY_DIR/ssh_host_rsa_key

    # authentication
    PubkeyAuthentication yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    UsePAM no

    # authorization - only allow th proxy key
    AuthorizedKeysFile $AUTH_KEYS

    # security restrictions
    PermitRootLogin no
    StrictModes no
    X11Forwarding no
    AllowTcpForwarding no
    AllowAgentForwarding no
    PermitTunnel no
    GatewayPorts no

    # logging
    LogLevel INFO
    SyslogFacility AUTH

    # no subsystems needed 4 just nix
    Subsystem sftp /usr/libexec/sftp-server
    EOF
    chmod 600 "$SSHD_CONFIG"

    # create empty known_hosts file - ssh will populate it on first connection!!
    touch "$KNOWN_HOSTS"
    chmod 600 "$KNOWN_HOSTS"

    # create env file 4 sandbox
    cat > "$ENV_FILE" <<EOF
    export NIX_REMOTE='ssh-ng://${config.system.primaryUser}@localhost?ssh-key=$KEY_FILE&port=$PROXY_PORT'
    export NIX_SSHOPTS='-o UserKnownHostsFile=$KNOWN_HOSTS -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes -o IdentityAgent=none -o BatchMode=yes -o Port=$PROXY_PORT'
    EOF

    echo ""
    echo "nix ssh proxy ready!!"
    echo "  port: $PROXY_PORT"
    echo "  key:  $KEY_FILE"
    echo "  env:  source $ENV_FILE"
    echo ""

    # run sshd in foreground (launchd manages it)
    exec /usr/sbin/sshd -D -f "$SSHD_CONFIG"
  '';
in
{
  launchd.user.agents.nix-sshd-proxy = {
    serviceConfig = {
      ProgramArguments = [ "${startScript}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${proxyDir}/launchd.stdout.log";
      StandardErrorPath = "${proxyDir}/launchd.stderr.log";
    };
  };
}
