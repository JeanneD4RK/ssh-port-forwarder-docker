# docker-ssh-port-forwarder


This project provides an easy and reliable solution to create a SSH remote port forwarding.

Typical use case: 

You are not allowed / not able to create NAT rules on your network and you wish to be able to reach some services hosted at home throught your public server.

## Usage

### Client

Client container requires 5 variables :

`REMOTE_HOST` is the server the client will connect to
`REMOTE_PORT` is the SSH port the client will connect to
`REMOTE_LISTEN` is the port the server will listen on to forward traffic
`LOCAL_HOST` is the host where the traffic must be forwarded
`LOCAL_PORT` is the host port where the traffic must be forwarded

`docker run -d -e REMOTE_HOST=1.2.3.4 -e REMOTE_PORT=2222 -e REMOTE_LISTEN=80 -e LOCAL_HOST=myserver.lan -e LOCAL_PORT=80 --name my-forwarder-client ssh-port-forwarder-client`

When first booting, the client will generate a keypair that it will use to connect to the server. The public key is displayed in the logs, copy it and save it for later...

```
Starting ssh client...
#################################################################

A new privatekey has been generated.

#################################################################


The public key is :

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqudH4LBkwqVqLTbri2TOajRnvqoUDWi7k4ptefHCoUe3fjHjRfblp5HPA6oZX8spgMXnWBwURcYyuReyJPQ0uKXJ7fzIOh5zan2Pu721mbH6N74R4tPWpTrUQyFv10d78Bl/qefkfW2R6KmJfBU3S2jWACgM161MwI4uAigEBw0X+0XLmp/gUB1bXJw8WdN9m+Tpfzv+hJxECqUn1qN4uxwRDQbFa+dPNj1mgBnYULkh73P+Ku7HdgAorgtT38mfPT6T7lU3A9/HplSqMEyf7wvWEUZvzBCkgkgqCyYo1OwXDBXWHOXackUkrAt21rA3QntPR18kwIHAStcnVREYUJXvh+RFcl/snsJ7ATc8YHUxnn4/y3y+Ibfd5OEPFQW7PNZyN+KRSfI2XSCLYaVSINJJLFHf2BDnBfdfiMSbE4waxtpmRTQE3QfXQ/pbQiStKzlkFn4bEd2iPD9w+fCLIySm/O6Mu29TssP6oY5rSYebMuIM7GfQ+Despd0UOdyM= root@c15defeb6607

#################################################################
```

In case of failure, the client will try to reconnect every seconds.


### Server

The server does not require any configuration to run. You only need to forward the desired public port to the container's port 22

`docker run -d -p 2222:22 --name my-forwarder-server ssh-port-forwarder-server`

Once you have the public key, you need to inject it in the server container : 

`docker exec my-forwarder-server sh -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqudH4LBkwqVqLTbri2TOajRnvqoUDWi7k4ptefHCoUe3fjHjRfblp5HPA6oZX8spgMXnWBwURcYyuReyJPQ0uKXJ7fzIOh5zan2Pu721mbH6N74R4tPWpTrUQyFv10d78Bl/qefkfW2R6KmJfBU3S2jWACgM161MwI4uAigEBw0X+0XLmp/gUB1bXJw8WdN9m+Tpfzv+hJxECqUn1qN4uxwRDQbFa+dPNj1mgBnYULkh73P+Ku7HdgAorgtT38mfPT6T7lU3A9/HplSqMEyf7wvWEUZvzBCkgkgqCyYo1OwXDBXWHOXackUkrAt21rA3QntPR18kwIHAStcnVREYUJXvh+RFcl/snsJ7ATc8YHUxnn4/y3y+Ibfd5OEPFQW7PNZyN+KRSfI2XSCLYaVSINJJLFHf2BDnBfdfiMSbE4waxtpmRTQE3QfXQ/pbQiStKzlkFn4bEd2iPD9w+fCLIySm/O6Mu29TssP6oY5rSYebMuIM7GfQ+Despd0UOdyM= root@c15defeb6607" > /root/.ssh/authorized_keys'`

Your client, if running, should connect right away.