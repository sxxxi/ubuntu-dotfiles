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
sudo dnf update -y;
sudo dnf install -y neovim flatpak curl tmux zsh ripgrep git stow kitty;
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo;

# Link config files
cd $(dirname $0)/../config && stow -t ~ .;

# Change user shell to zsh
if [ "$SHELL" != "/bin/zsh" ]; then
    sudo usermod -s /bin/zsh $USER;
    echo "Rebooting to change your shell to zsh. ABORT NOW IF YOU DONT WANNA!" && sleep 5;
    sudo reboot;
    exit 1;
fi;

# Docker
if promptbool "Install Docker engine?" && [ -z $(command -v docker) ]; then
    # Remove old versions
    sudo dnf remove -y docker docker-client docker-client-latest docker-common \
        docker-latest docker-latest-logrotate docker-logrotate docker-selinux \
        docker-engine-selinux docker-engine;

    # Setup the repository
    sudo dnf -y install dnf-plugins-core;
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo;

    # Install the engine
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;

    # Start docker service
    sudo systemctl enable --now docker;

    # add user to docker group
    if [ -z $(groups $USER | grep "docker") ]; then
        sudo groupadd docker;
        sudo usermod -aG docker $USER;
        echo "Reboot after the script to add the user to the docker group." && sleep 10;
    fi;
else
    echo "Docker already installed or you just didn't wanna install. IDK";
fi;

if promptbool "Install PHP and Laravel?" [ ! -s $HOME/.config/herd-lite ]; then
    /bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.4)";
    zsh -c "source ~/.zshrc && composer global require laravel/installer";
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

if promptbool "Modify GNOME settings?"; then
    # GNOME settings
    # Mess with the settings app while running `dconf watch /` to see the changes
    # Run this outside of tmux and make sure the $DISPLAY variable is not empty when you echo it
    gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true;                                               # Show hidden files in the file explorer
    gsettings set org.gnome.system.location enabled false;                                                          # Location sharing
    gsettings set org.gnome.desktop.session idle-delay 0;                                                           # Turn off screen timeout
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark;                                             # Dark mode
    gsettings set org.gnome.desktop.interface accent-color "purple";                                                # SLAAAAYY!
    gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/gnome/blobs-l.svg";      # Set my favourite wallpaper as default
    gsettings set org.gnome.desktop.screensaver primary-color "#241f31";                                            # IDK
    gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat;                                           # Mouse acceleration off
    gsettings set org.gnome.desktop.peripherals.mouse speed 0;                                                      # Mouse speed
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 40;
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false;
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-purple-dark';
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-purple';
    gsettings set org.gnome.shell.extensions.dash-to-dock.dock-fixed true;
    gsettings set org.gnome.shell.extensions.dash-to-dock.dock-fixed false;
    gsettings set org.gnome.shell.extensions.dash-to-dock.extend-height true;
    gsettings set org.gnome.shell.extensions.dash-to-dock.extend-height false;
    gsettings set org.gnome.shell.extensions.dash-to-dock.dock-position 'LEFT';
    gsettings set org.gnome.shell.extensions.dash-to-dock.dock-position 'BOTTOM';
    gsettings set org.gnome.shell.extensions.dash-to-dock.show-mounts true;
    gsettings set org.gnome.shell.extensions.dash-to-dock.show-mounts false;
    gsettings set org.gnome.shell.extensions.dash-to-dock.show-trash true;
    gsettings set org.gnome.shell.extensions.dash-to-dock.show-trash false;
fi;

promptreboot;
