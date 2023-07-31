## Build image

Build pegascape image is as simple as using docker build.

`docker build .`

## Launch container

`docker run -p 80:80 -p 53:53/udp -p 8100:8100 -e HOST_IP=<YOUR_DOCKER_HOST_IP> -d -t ramdockerapp/pegascape:1.0.0`

Pegascape must be exposed on
 - port 80 in order to reach frontend
 - port 53 in order to expose a DNS server which forbidden access to nintendo services, and redirect switch to this container
 - port 8100 for exploit to work

_**-t** options is needed to attach a tty to container, in order to keep alive the node command_

## Configure SWITCH to access pegascape

Modify your internet configuration on switch to use as primary and secondary the host IP of the machine which is used to launch pegascape.
You won't be able to access to internet with this configuration, but pegascape will still be available in order to launch the deja-vu exploit.