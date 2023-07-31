FROM node:14.21.3-bullseye-slim AS builder

LABEL maintainer="marcel@marquez.fr"

WORKDIR /opt/app
RUN apt update && apt install git python build-essential -y
RUN git clone https://github.com/Ramzus/pegascape.git .
RUN npm install

COPY pegascape.sh /opt/app

FROM node:14.21.3-bullseye-slim

RUN groupadd -r pegascape && useradd --no-log-init -r -g pegascape pegascape

WORKDIR /opt/app
COPY --from=builder /opt/app ./

RUN chown -R pegascape:pegascape /opt/app

ARG HOST_IP=192.168.0.1
ENV HOST_IP $HOST_IP

EXPOSE 80
EXPOSE 53/UDP
EXPOSE 8100

USER pegascape

ENTRYPOINT ["/bin/sh", "pegascape.sh", "&"]