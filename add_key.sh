#!/bin/bash

KEY="$1"

if [ -z "$KEY" ]
then
	echo "No key provided. Exiting."
	exit 2
fi

if echo "$KEY" | grep "ssh-rsa" 1>2 2>/dev/null
then
	# ssh-rsa key dectected
	echo "$KEY" > /root/.ssh/authorized_keys
	echo "Key added successfully"
	exit 0
else
	echo "Argument is not a ssh-rsa key."
	exit 1
fi