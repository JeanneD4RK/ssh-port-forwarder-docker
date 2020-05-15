#!/bin/bash

# Change root password at every boot. We use private key so it's not a problem.
echo "root:$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | rev | cut -b 2- | rev)" | chpasswd

# Generate server key on first boot
if [ ! -f "/etc/ssh/ssh_host_key" ]; then
	/usr/bin/ssh-keygen -A
	/usr/bin/ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key
fi

# Run sshd service foreground
printf "\n\n%s\n\n" "Starting SSH service"
/usr/sbin/sshd -D
