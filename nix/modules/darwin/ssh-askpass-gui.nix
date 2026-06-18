{ ... }: {
  config = {
    homebrew.brews = [
      "ssh-askpass"
    ];

    environment.variables = {
      "SSH_ASKPASS" = "/opt/homebrew/opt/ssh-askpass/bin/ssh-askpass";
    };
  };
}
