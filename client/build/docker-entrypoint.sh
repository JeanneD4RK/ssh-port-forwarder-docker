#!/bin/bash

echo "Starting ssh client..."

# Generate the user private key if not exist
if [ ! -f "/root/id_rsa.pem" ]
then
	ssh-keygen -q -N "" -f /root/id_rsa.pem
	chmod 400 id_rsa.pem
	printf "%s\n\n%s\n\n%s\n\n\n%s\n\n%s\n\n%s\n\n" "#################################################################" "A new privatekey has been generated." "#################################################################" "The public key is :" "$(cat id_rsa.pem.pub)" "#################################################################"
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
	/usr/bin/ssh -R "0.0.0.0:$REMOTE_LISTEN:$LOCAL_HOST:$LOCAL_PORT" -o "ExitOnForwardFailure=True" -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i id_rsa.pem -p "$REMOTE_PORT" -N "root@$REMOTE_HOST" 2>/dev/null 1>&2
	echo "$(date) : SSH crashed. Retrying..."
	sleep 1
done

