#!/bin/sh
#
# FUNCTIONS
prompt() {
    local OUTPUT_VAR="$1";
    local PROMPT_MESSAGE="$2";
    local DEFAULT_VALUE="$3";
    local INPUT="";

    # Loop until valid input is provided
    while true; do
        # If default value is provided, display it as a suggestion
        if [ -n "$DEFAULT_VALUE" ]; then
            read -p "$PROMPT_MESSAGE [$DEFAULT_VALUE]: " INPUT;
        else
            read -p "$PROMPT_MESSAGE: " INPUT;
        fi;

        # If input is empty and default value is provided, use default value
        if [ -z "$INPUT" ] && [ -n "$DEFAULT_VALUE" ]; then
            INPUT="$DEFAULT_VALUE";
            break;
        # If input is non-empty, accept it
        elif [ -n "$INPUT" ]; then
            break;
        else
            echo "This is required, sir! 😢";
        fi;
    done;

    # Assign the validated input value to the variable passed as the first argument
    eval "$OUTPUT_VAR=\"$INPUT\"";
}

promptreboot() {
    prompt SHOULD_REBOOT "Reboot now?" "y";
    if [ "$SHOULD_REBOOT" = "y" ]; then
        sudo reboot;
    fi;
}

promptbool() {
    local PROMPT=$1;

    prompt SHOULD "$PROMPT" "Y";

    if [ "$SHOULD" = "y" ] || [ "$SHOULD" = "Y" ]; then
        return 0;
    else
        return 1;
    fi;
}

# ENTRYPOINT
sudo apt update -y;
sudo apt install -y snapd flatpak build-essential gnome-software-plugin-flatpak curl tmux zsh ripgrep git stow alacritty;
sudo systemctl enable --now snapd;
sudo snap install nvim --classic;

# Link config files
cd $(dirname $0)/../config && stow -t ~ .;

# Change user shell to zsh
if [ "$SHELL" != "/bin/zsh" ]; then
    sudo usermod -s /bin/zsh $USER;
    echo "Rebooting to change your shell to zsh. ABORT NOW IF YOU DONT WANNA!" && sleep 5;
    sudo reboot;
    exit 1;
fi;

# TPM
if promptbool "Clone TPM for tmux?" && [ ! -s $HOME/.tmux ]; then
    echo "Cloning TPM for tmux...";
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm;
fi;

# Node Version Manager
if promptbool "Install Node Version Manager?" && [ ! -s $HOME/.nvm ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash;
    zsh -c "source ~/.zshrc && nvm install --lts";
fi;

if promptbool "Perform GIT configuration?"; then
    # Setup git key
    SSH_DIR="$HOME/.ssh";
    prompt KEY_NAME "Enter Github SSH key name to search" "gitkey";
    ABS_KEY_FILE="$SSH_DIR/$KEY_NAME";

    if [ ! -f $ABS_KEY_FILE ]; then
        prompt KEY_COMMENT "Enter comment";
        ssh-keygen -t ed25519 -C $KEY_COMMENT -f $ABS_KEY_FILE;
        eval "$(ssh-agent -s)";
        ssh-add $ABS_KEY_FILE;
    fi;

    echo "Public key: $(cat $ABS_KEY_FILE.pub)\n";

    clear;

    echo "Configure Git:";

    prompt GIT_DEFAULT_BRANCH "Default branch" "main";
    prompt GIT_USER_EMAIL "Email" "$(git config --global user.email)";
    prompt GIT_USER_NAME "Name" "$(git config --global user.name)";

    git config --global init.defaultBranch "$GIT_DEFAULT_BRANCH";
    git config --global user.email "$GIT_USER_EMAIL";
    git config --global user.name "$GIT_USER_NAME";
fi;

promptreboot;

