# dotfiles
## TODO
- [ ] automatically install homebrew
- [ ] automatically install fish (chsh currently breaks because fish isn't pre-installed)
- [ ] automatically select node version (18)
- [ ] automatically install Packer (neovim), and install all deps specified in Neovim
- [ ] multi-OS support? (e.g. support for Mac / Linux)

## Installing a new machine from flake
```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:rv32ima/dotfiles#fadeoutz

sudo nixos-install --no-root-password --flake github:rv32ima/dotfiles#fadeoutz
nixos-enter
ssh-keygen -t rsa -f /persist/etc/ssh/ssh_host_rsa_key
ssh-keygen -t ed25519 -f /persist/etc/ssh/ssh_host_ed25519_key
cat /persist/etc/ssh/ssh_host_ed25519_key.pub | nix run nixpkgs#ssh-to-age
```