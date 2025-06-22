FROM node:14.21.3-bullseye-slim AS builder

LABEL maintainer="marcel@marquez.fr"
LABEL description="Pegascape Docker container for Nintendo Switch deja-vu exploit"
LABEL version="1.0"

WORKDIR /opt/app

# Install curl for health checks
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Clone pegascape repository
RUN git clone https://github.com/Ramzus/pegascape.git .

# Install npm dependencies
RUN npm install && npm cache clean --force

# Copy startup and health check scripts
COPY pegascape.sh healthcheck.sh /opt/app/
RUN chmod +x /opt/app/pegascape.sh /opt/app/healthcheck.sh

FROM node:14.21.3-bullseye-slim

# Create non-root user for security
RUN groupadd -r pegascape && useradd --no-log-init -r -g pegascape pegascape

WORKDIR /opt/app

# Copy application from builder stage
COPY --from=builder /opt/app ./

# Set proper ownership
RUN chown -R pegascape:pegascape /opt/app

# Environment variables
ARG HOST_IP=192.168.1.100
ENV HOST_IP=${HOST_IP}
ENV NODE_ENV=production

# Expose required ports
EXPOSE 80
EXPOSE 53/udp
EXPOSE 8100

# Add health check using custom script
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ./healthcheck.sh

# Switch to non-root user
USER pegascape

# Use exec form for better signal handling
ENTRYPOINT ["./pegascape.sh"]