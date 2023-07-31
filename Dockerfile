FROM node:14.21.3-bullseye-slim as builder

LABEL maintainer="marcel@marquez.fr"

WORKDIR /opt/app
RUN apt update && apt install git python build-essential -y
RUN git clone https://github.com/Ramzus/pegaswitch.git .
RUN npm install

COPY pegascape.sh /opt/app

FROM node:14.21.3-bullseye-slim

WORKDIR /opt/app
COPY --from=builder /opt/app ./

ARG HOST_IP=192.168.0.1
ENV HOST_IP $HOST_IP

EXPOSE 80
EXPOSE 53
EXPOSE 8100

ENTRYPOINT ["/bin/sh", "pegascape.sh", "&"]