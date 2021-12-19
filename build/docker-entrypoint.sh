#!/bin/bash

function getTunnel {
	IFS=":" read -a arr <<< "${1}"
	HOST="${arr[0]}"
	PORT="${arr[1]}"
	LISTEN="${arr[2]}"
	FORWARDHOST="${arr[3]}"
	FORWARDPORT="${arr[4]}"
}

# If not args are passed to docker-entrypoint.sh, running normally.
if [ "$#" -eq 0 ]; then
	if [ -z "$MODE" ]; then
		echo "[INFO ] : $(date) : MODE not specified. Running as server"
		MODE="server"
	fi
	if [ "$MODE" == "server" ]; then
		echo "[INFO ] : $(date) : Starting forwarder as server mode"
		# Change root password at every boot to prevent SSH login. We use private key so it's not a problem.
		echo "root:$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | rev | cut -b 2- | rev)" | chpasswd 1>/dev/null 2>&1
		# Generate server key on first run
		if [ ! -f "/etc/ssh/ssh_host_key" ]; then
			/usr/bin/ssh-keygen -A 1>/dev/null 2>&1
			/usr/bin/ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key 1>/dev/null 2>&1
		fi
		# Run sshd service foreground
		echo "[OK   ] : $(date) : SSH service started"
		/usr/sbin/sshd -D
	elif [ "$MODE" == "client" ]; then
		if [ -z "$CONF" ]; then
		        echo "ERROR: CONF variable is not set."
			exit
		fi
		if [ ! -r "$CONF" ]; then
	        	echo "ERROR: File $CONF does not exist or is not readable."
			exit
		fi

		echo "[INFO ] : $(date) : Starting forwarder as client mode"
		
		# Generate the user private key if not exist
		if [ ! -f "/root/id_rsa.pem" ]; then
			printf "%s\n\n%s\n\n%s" "################################################################" "Generating a new keypair" "################################################################"
			/usr/bin/ssh-keygen -q -N "" -f /root/id_rsa.pem
			chmod 400 /root/id_rsa.pem
			printf "\n\n\n%s\n\n%s\n\n%s\n\n" "The public key is :" "$(cat /root/id_rsa.pem.pub)" "################################################################"
		fi
	
		TUNNELS=()
		COUNT=1
		# Init tunnels array
		while read LINE; do
			getTunnel "$LINE"
			if [ -z "$HOST" ] || 
				[ -z "$PORT" ] || 
				[ -z "$LISTEN" ] || 
				[ -z "$FORWARDHOST" ] || 
				[ -z "$FORWARDPORT" ] ||
				! [ "$PORT" -eq "$PORT" ] 2>/dev/null ||
				! [ "$LISTEN" -eq "$LISTEN" ] 2>/dev/null ||
				! [ "$FORWARDPORT" -eq "$FORWARDPORT" ] 2>/dev/null ||
				[ "$PORT" -le 0 ] 2>/dev/null ||
				[ "$LISTEN" -le 0 ] 2>/dev/null ||
				[ "$FORWARDPORT" -le 0 ] 2>/dev/null; then
				echo "ERROR: Line $LINE is not a valid configuration."
				exit
			fi
			./run_tunnel.sh "$COUNT" "$HOST" "$PORT" "$LISTEN" "$FORWARDHOST" "$FORWARDPORT" &
			COUNT=$((COUNT+1))
		done < "$CONF"

		# Keep alive
		while true; do
			sleep 1
		done
	fi
else
	eval "$@"
fi
