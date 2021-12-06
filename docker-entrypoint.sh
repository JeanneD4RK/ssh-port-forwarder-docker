#!/bin/bash
if [ "$#" -eq 0 ]; then
	if [ -z "$MODE" ]; then
		echo "MODE not specified. Running as server"
		MODE="server"
	fi
	if [ "$MODE" == "server" ]; then
		echo "Starting forwarder as server mode"
		# Change root password at every boot to prevent SSH login. We use private key so it's not a problem.
		echo "root:$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | rev | cut -b 2- | rev)" | chpasswd 1>/dev/null 2>&1
		# Generate server key on first run
		if [ ! -f "/etc/ssh/ssh_host_key" ]; then
			/usr/bin/ssh-keygen -A 1>/dev/null 2>&1
			/usr/bin/ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key 1>/dev/null 2>&1
		fi
		# Run sshd service foreground
		echo "OK: SSH service started"
		/usr/sbin/sshd -D
	elif [ "$MODE" == "client" ]; then
		echo "Starting forwarder as client mode"
		# Check if the process is still running. Returns 0 if the process is alive, 1 if the process is dead (SSH crashed)
		function alive {
			if kill -0 "$1" 2>/dev/null; then
				return 0
			fi
			return 1
		}
		# Generate the user private key if not exist
		if [ ! -f "/root/id_rsa.pem" ]; then
			printf "%s\n\n%s\n\n%s" "#################################################################" "Generating a new keypair" "#################################################################"
			/usr/bin/ssh-keygen -q -N "" -f /root/id_rsa.pem
			chmod 400 /root/id_rsa.pem
			printf "\n\n\n%s\n\n%s\n\n%s\n\n" "The public key is :" "$(cat /root/id_rsa.pem.pub)" "#################################################################"
		fi
		if [ -z "$REMOTE_HOST" ]; then
			echo "REMOTE_HOST argument missing"
			exit 1
		fi
		if [ -z "$REMOTE_PORT" ]; then
			echo "REMOTE_PORT argument missing"
			exit 1
		fi
		if [ -z "$REMOTE_LISTEN" ]; then
			echo "REMOTE_LISTEN argument missing"
			exit 1
		fi
		if [ -z "$FORWARD_HOST" ]; then
			echo "FORWARD_HOST argument missing"
			exit 1
		fi
		if [ -z "$FORWARD_PORT" ]; then
			echo "FORWARD_PORT argument missing"
			exit 1
		fi
	
		echo "OK: SSH client started" 
		echo "INFO: Trying to connect to $REMOTE_HOST:$REMOTE_PORT"
		while true; do
			# Init SSH pid to inexistent PID to make sure the while will run once.
			SSH_PID=-1
			while ! (alive $SSH_PID); do
				/usr/bin/ssh -R "0.0.0.0:$REMOTE_LISTEN:$FORWARD_HOST:$FORWARD_PORT" -o "ServerAliveInterval=5" -o "ServerAliveCountMax=2" -o "ConnectTimeout=10" -o "ExitOnForwardFailure=True" -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i id_rsa.pem -p "$REMOTE_PORT" -N "root@$REMOTE_HOST" 2>/dev/null 1>&2 &
				SSH_PID=$!
				# Sleep 5 to let SSH crash if connect fails
				sleep 5
			done
			# While is over, SSH is connected.
			echo "$(date) : Connected to $REMOTE_HOST:$REMOTE_PORT (PID $SSH_PID). Forwarding TCP $REMOTE_HOST:$REMOTE_LISTEN to $FORWARD_HOST:$FORWARD_PORT"
			# Infinite while to monitor PID
			while alive $SSH_PID; do
				sleep 1
			done
			# Notify crash in STDOUT and loop
			echo "$(date) : SSH crashed. Retrying..."
		done	
	fi
else
	eval "$@"
fi
