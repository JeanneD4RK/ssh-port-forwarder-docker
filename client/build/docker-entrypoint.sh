#!/bin/bash

function connect {
	/usr/bin/ssh -R "0.0.0.0:$REMOTE_LISTEN:$LOCAL_HOST:$LOCAL_PORT" -o "ServerAliveInterval=5" -o "ServerAliveCountMax=2" -o "ConnectTimeout=10" -o "ExitOnForwardFailure=True" -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i id_rsa.pem -p "$REMOTE_PORT" -N "root@$REMOTE_HOST" 2>/dev/null 1>&2 &
	SSH_PID=$!
	sleep 5
	return $SSH_PID
}

function alive {
	if kill -0 $1 2>/dev/null; then
		return 0
	fi
	return 1
}

function monitor {
	SSH_PID=$1
	if alive $SSH_PID; then
		echo "Connected to $REMOTE_HOST:$REMOTE_PORT. Forwarding port $REMOTE_LISTEN to $LOCAL_HOST:$LOCAL_PORT"
	fi

	while alive $SSH_PID; do
		sleep 1
	done
}

echo "Starting ssh client..."

# Generate the user private key if not exist
if [ ! -f "/root/id_rsa.pem" ]
then
	printf "%s\n\n%s\n\n%s" "#################################################################" "Generating a new keypair" "#################################################################"
	ssh-keygen -q -N "" -f /root/id_rsa.pem
	chmod 400 id_rsa.pem
	printf "\n\n\n%s\n\n%s\n\n%s\n\n" "The public key is :" "$(cat id_rsa.pem.pub)" "#################################################################"
fi

if [ -z "$REMOTE_HOST" ]; then
	echo "Remote host argument missing"
	exit 1
fi

if [ -z "$REMOTE_PORT" ]; then
	echo "Remote port argument missing"
	exit 1
fi

if [ -z "$REMOTE_LISTEN" ]; then
	echo "Remote listen argument missing"
	exit 1
fi

if [ -z "$LOCAL_HOST" ]; then
	echo "Local host argument missing"
	exit 1
fi

if [ -z "$LOCAL_PORT" ]; then
	echo "Local port argument missing"
	exit 1
fi

while true; do
	connect
	SSH_PID=$!
	monitor $SSH_PID
	echo "$(date) : SSH crashed. Retrying..."
	sleep 2
done
