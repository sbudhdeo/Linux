#!/bin/bash

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
user="ansible"
ssh_key_length='2048'

# Check if the sudoers file for the user already exists
if [[ ! -e /etc/sudoers.d/dont-prompt-$user-for-sudo-password ]]; then
    cp /etc/sudoers /tmp/sudoers.bak-"${current_time}" && echo "/etc/sudoers backup file created"
    echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | EDITOR='tee' visudo -f /etc/sudoers.d/dont-prompt-$user-for-sudo-password
else
    echo "sudoers file for $user already exists"
fi

# Execute commands as the specified user
sudo -i -u ${user} bash <<EOF 
if ! [ -d /home/${user}/.ssh ] ;then
    mkdir -p /home/${user}/.ssh
    touch /home/${user}/.ssh/authorized_keys
    chmod 700 /home/${user}/.ssh
    chmod 600 /home/${user}/.ssh/authorized_keys
    chown -R ${user}:${user} /home/${user}/.ssh

    # Check if the SSH key already exists before generating a new one
    if [ ! -f /home/${user}/.ssh/${user}-id_rsa ]; then
        ssh-keygen -t rsa -f /home/${user}/.ssh/${user}-id_rsa -b ${ssh_key_length} -N ''
    fi

    cat /home/${user}/.ssh/${user}-id_rsa.pub >> /home/${user}/.ssh/authorized_keys
fi
EOF
