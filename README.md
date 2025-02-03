# Dotfiles

## Setup
```sh
git clone https://github.com/sxxxi/fedora-dotfiles $HOME/.dotfiles
cd $HOME/.dotfiles/config && stow -t ~ .
```
### WSL
Place `.dotfiles/etc/wsl.conf` to the WSL2 VM's `/etc` directory and run the following commands with admin priveleges to enable port-forwarding.
```sh
$ports = 5173, 3000, 8000, 8080
foreach ($port in $ports) {
    netsh interface portproxy add v4tov4 listenport=$port listenaddress=0.0.0.0 connectport=$port connectaddress=127.0.0.1
}
netsh interfade show all
```

## Notes
- `dconf watch /` shows configuration changes. Really cool.

## Dependencies
* Alacritty
* zsh
* nvim
* ripgrep
* fd
* tmux
* stow
