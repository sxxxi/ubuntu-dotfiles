OS_NAME=$(uname -s)

# SSH agent
if [ -z $SSH_AUTH_SOCK ] && [ ! pgrep -u $USER ssh-agent > /dev/null ]; then
    eval $(ssh-agent -s);
fi
