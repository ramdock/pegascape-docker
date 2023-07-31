## Why a docker image for Pegascape

Pegascape can sometimes be unavailable. And as nothing is eternal, it could be completely down in a near future.
To add more possibilities for users who still use deja-vu exploit to hack their switch, this container image aims to make pegascape easily self-hostable.
As a bonus, the execution of deja-vu exploit is quicker and more stable when used from a local appliance.

## Build image

Build pegascape image is as simple as using docker build.

`docker build .`

## Launch container

`docker run -p 80:80 -p 53:53/udp -p 8100:8100 -e HOST_IP=<YOUR_DOCKER_HOST_IP> --name pegascape -d -t ramdockerapp/pegascape:latest`

Pegascape must be exposed on
 - port 80 in order to reach frontend
 - port 53 in order to expose a DNS server which forbidden access to nintendo services, and redirect switch to this container
 - port 8100 for exploit to work

_**-t** options is needed to attach a tty to container, in order to keep alive the node command_

## Configure switch to access pegascape

Modify your internet configuration on switch to use as primary and secondary the host IP of the machine which is used to launch pegascape.
You won't be able to access to internet with this configuration, but pegascape will still be available in order to launch the deja-vu exploit.