# docker-ssh-port-forwarder


This project provides an easy and reliable solution to create a SSH remote port forwarding.

Typical use case: 

You are not allowed / not able to create input NAT rules on your network and you wish to make a local service available from another network (internet or another subnet).

The client runs on your LAN, for two reasons :
- the client initiates the SSH connection used for port forwarding, therefore it's allowed through the firewall.
- if you're running on a home network and your IP changes, it will reconnect automatically asap.

## General information

The client container requires 6 environment variables :

- `MODE=client`, otherwise the container will run as server mode

- `REMOTE_HOST` is the remote server the client will connect to

- `REMOTE_PORT` is the port SSH listens on on the remote

- `REMOTE_LISTEN` is the port the server will listen on to forward traffic

- `FORWARD_HOST` is the host address where the traffic must be forwarded

- `FORWARD_PORT` is the host port where the traffic must be forwarded

All the examples below are based on this diagram :

![diagram](https://github.com/IsThisUsernameFree/ssh-port-forwarder-docker/blob/master/diagram.png?raw=true)

## Docker compose

The `docker-compose.yml` example will configure the service to send all the traffic received on 1.2.3.4:80 to myserver.lan:8080
This file should help you get started. Simply remove the part you don't need (client or server, depending on what component you're deploying) and personalize the variables.

## Manual usage

### Build
`docker build -t ssh-port-forwarder .`
### Usage

#### Server

The server does not require any configuration to run. You only need to forward the desired public port to the container's port 22

`docker run -d -p 2222:22 --name my-forwarder-server ssh-port-forwarder`

#### Client

The following example will send all the traffic on 1.2.3.4:80 to myserver.lan:80

`docker run -d -e MODE=client -e REMOTE_HOST=1.2.3.4 -e REMOTE_PORT=2222 -e REMOTE_LISTEN=80 -e FORWARD_HOST=myserver.lan -e FORWARD_PORT=8080 --name my-forwarder-client ssh-port-forwarder`

In case of connection failure, the client will try to reconnect every seconds.

## Private keys

When first booting, the client will generate the private key it will use to connect to the server. The public key is displayed in the logs.

```
Starting ssh client...
#################################################################

A new privatekey has been generated.

#################################################################


The public key is :

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqudH4LBkwqVqLTbri2TOajRnvqoUDWi7k4ptefHCoUe3fjHjRfblp5HPA6oZX8spgMXnWBwURcYyuReyJPQ0uKXJ7fzIOh5zan2Pu721mbH6N74R4tPWpTrUQyFv10d78Bl/qefkfW2R6KmJfBU3S2jWACgM161MwI4uAigEBw0X+0XLmp/gUB1bXJw8WdN9m+Tpfzv+hJxECqUn1qN4uxwRDQbFa+dPNj1mgBnYULkh73P+Ku7HdgAorgtT38mfPT6T7lU3A9/HplSqMEyf7wvWEUZvzBCkgkgqCyYo1OwXDBXWHOXackUkrAt21rA3QntPR18kwIHAStcnVREYUJXvh+RFcl/snsJ7ATc8YHUxnn4/y3y+Ibfd5OEPFQW7PNZyN+KRSfI2XSCLYaVSINJJLFHf2BDnBfdfiMSbE4waxtpmRTQE3QfXQ/pbQiStKzlkFn4bEd2iPD9w+fCLIySm/O6Mu29TssP6oY5rSYebMuIM7GfQ+Despd0UOdyM= root@c15defeb6607

#################################################################
```

Once you have the public key, you need to inject it in the server container (don't forget the quotes) : 


```
docker exec <container name> add_key.sh "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqudH4LBkwqVqLTbri2TOajRnvqoUDWi7k4ptefHCoUe3fjHjRfblp5HPA6oZX8spgMXnWBwURcYyuReyJPQ0uKXJ7fzIOh5zan2Pu721mbH6N74R4tPWpTrUQyFv10d78Bl/qefkfW2R6KmJfBU3S2jWACgM161MwI4uAigEBw0X+0XLmp/gUB1bXJw8WdN9m+Tpfzv+hJxECqUn1qN4uxwRDQbFa+dPNj1mgBnYULkh73P+Ku7HdgAorgtT38mfPT6T7lU3A9/HplSqMEyf7wvWEUZvzBCkgkgqCyYo1OwXDBXWHOXackUkrAt21rA3QntPR18kwIHAStcnVREYUJXvh+RFcl/snsJ7ATc8YHUxnn4/y3y+Ibfd5OEPFQW7PNZyN+KRSfI2XSCLYaVSINJJLFHf2BDnBfdfiMSbE4waxtpmRTQE3QfXQ/pbQiStKzlkFn4bEd2iPD9w+fCLIySm/O6Mu29TssP6oY5rSYebMuIM7GfQ+Despd0UOdyM= root@c15defeb6607"
```

Your client, if running, should connect right away.
