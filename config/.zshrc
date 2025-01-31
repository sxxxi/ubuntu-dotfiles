[ -f /etc/zshrc ] && source /etc/zshrc

# Configure shell UI and shit
. $HOME/.dotfiles/config/.config/.myshell

export PATH="/snap/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/home/seiji/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/seiji/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
