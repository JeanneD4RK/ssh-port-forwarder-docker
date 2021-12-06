FROM alpine:3.11

RUN apk add --no-cache openssh bash

WORKDIR /root/
COPY docker-entrypoint.sh /root/
COPY add_key.sh /root/
RUN sed -ir 's/#PermitRootLogin.*/PermitRootLogin\ yes/' /etc/ssh/sshd_config; sed -ir 's/#Port 22/Port 22/g' /etc/ssh/sshd_config; sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config; sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config; sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config; sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config; sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config; sed -ir 's/#ClientAliveInterval 0/ClientAliveInterval 5/g' /etc/ssh/sshd_config; sed -ir 's/#ClientAliveCountMax 3/ClientAliveCountMax 1/g' /etc/ssh/sshd_config; sed -ir 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config; sed -ir 's/GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config; echo "ServerAliveInterval 5" >> /etc/ssh/ssh_config; echo "ServerAliveCountMax 2" >> /etc/ssh/ssh_config; echo "ConnectTimeout 10" >> /etc/ssh/ssh_config; echo "ExitOnForwardFailure True" >> /etc/ssh/ssh_config; echo "UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config; echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config; chmod +x /root/docker-entrypoint.sh; chmod +x /root/add_key.sh; mkdir /root/.ssh; touch /root/.ssh/authorized_keys
EXPOSE 22
ENTRYPOINT ["/root/docker-entrypoint.sh"]
