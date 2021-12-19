#!/bin/bash

function alive {
        if kill -0 "$1" 2>/dev/null; then
                return 0
        fi
        return 1
}

function startTunnel {
	/usr/bin/ssh -R "0.0.0.0:$LISTEN:$FORWARDHOST:$FORWARDPORT" -o "ServerAliveInterval=5" -o "ServerAliveCountMax=2" -o "ConnectTimeout=10" -o "ExitOnForwardFailure=True" -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "id_rsa.pem" -p "$PORT" -N "root@$HOST" 1>&2 2>/dev/null &
	SSH_PID=$!
	# Sleep 5 to let SSH crash if connect fails
	sleep 5
}

TUNNELID="$1"
HOST="$2"
PORT="$3"
LISTEN="$4"
FORWARDHOST="$5"
FORWARDPORT="$6"

SSH_PID=-1

echo "[INFO ] $(date) : SSH client #$TUNNELID started (connecting to $HOST:$PORT to forward port $LISTEN to $FORWARDHOST:$FORWARDPORT)" 

startTunnel
while true; do
	# Try to connect until it's successful
	while ! alive $SSH_PID; do
		startTunnel
	done

	# While is over, SSH is connected.
	echo "[OK   ] $(date) : Tunnel #$TUNNELID : Connected to $HOST:$PORT (PID $SSH_PID). Forwarding TCP :$LISTEN to $FORWARDHOST:$FORWARDPORT"

	# Infinite while to monitor PID
	while alive $SSH_PID; do
		sleep 1
	done

	# At this point SSH tunnel is down
	echo "[ERROR] $(date) : Tunnel #$TUNNELID crashed. Retrying..."
done	
