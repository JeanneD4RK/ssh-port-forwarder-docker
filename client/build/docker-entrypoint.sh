#!/bin/bash

function alive {
	if kill -0 $1 2>/dev/null; then
		return 0
	fi
	return 1
}

# Generate the user private key if not exist
if [ ! -f "/root/id_rsa.pem" ]
then
	printf "%s\n\n%s\n\n%s" "#################################################################" "Generating a new keypair" "#################################################################"
	ssh-keygen -q -N "" -f /root/id_rsa.pem
	chmod 400 id_rsa.pem
	printf "\n\n\n%s\n\n%s\n\n%s\n\n" "The public key is :" "$(cat id_rsa.pem.pub)" "#################################################################"
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

if [ -z "$LOCAL_HOST" ]; then
	echo "LOCAL_HOST argument missing"
	exit 1
fi

if [ -z "$LOCAL_PORT" ]; then
	echo "LOCAL_PORT argument missing"
	exit 1
fi

echo "Starting SSH client..."
while true; do
	# Init SSH pid to inexistent PID to make sure the while will run once.
	SSH_PID=-1
	while !(alive $SSH_PID); do
		/usr/bin/ssh -R "0.0.0.0:$REMOTE_LISTEN:$LOCAL_HOST:$LOCAL_PORT" -o "ServerAliveInterval=5" -o "ServerAliveCountMax=2" -o "ConnectTimeout=10" -o "ExitOnForwardFailure=True" -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i id_rsa.pem -p "$REMOTE_PORT" -N "root@$REMOTE_HOST" 2>/dev/null 1>&2 &
		SSH_PID=$!
		# Sleep 5 to let SSH crash if connect fails
		sleep 5
	done
	# While is over, SSH is connected.
	echo "$(date) : Connected to $REMOTE_HOST:$REMOTE_PORT (PID $SSH_PID). Forwarding port $REMOTE_LISTEN to $LOCAL_HOST:$LOCAL_PORT"

	# Now wait for the PID to crash, notify it to the logs and loop.
	while alive $SSH_PID; do
		sleep 1
	done
	echo "$(date) : SSH crashed. Retrying..."
done
